//
//  ResourceFileStructGenerator.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 10-12-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

struct ResourceFileStructGenerator: ExternalOnlyStructGenerator {
  private let resourceFiles: [ResourceFile]

  init(resourceFiles: [ResourceFile]) {
    self.resourceFiles = resourceFiles
  }

  func generatedStruct(at externalAccessLevel: AccessLevel, prefix: SwiftIdentifier) -> Struct {
    let structName: SwiftIdentifier = "file"
    let qualifiedName = prefix + structName
    let localized = resourceFiles.grouped(by: { $0.fullname })
    let groupedLocalized = localized.grouped(bySwiftIdentifier: { $0.0 })

    groupedLocalized.printWarningsForDuplicatesAndEmpties(source: "resource file", result: "file")

    // For resource files, the contents of the different locales don't matter, so we just use the first one
    let firstLocales = groupedLocalized.uniques.map { ($0.0, Array($0.1.prefix(1))) }

    return Struct(
      availables: [],
      comments: ["This `\(qualifiedName)` struct is generated, and contains static references to \(firstLocales.count) files."],
      accessModifier: externalAccessLevel,
      type: Type(module: .host, name: structName),
      implements: [],
      typealiasses: [],
      properties: firstLocales.flatMap { propertiesFromResourceFiles(resourceFiles: $0.1, at: externalAccessLevel) },
      functions: firstLocales.flatMap { functionsFromResourceFiles(resourceFiles: $0.1, at: externalAccessLevel) },
      structs: firstLocales.flatMap { directoryStructsFromResourceFiles(resourceFiles: $0.1, at: externalAccessLevel) },
      classes: [],
      os: []
    )
  }

  private func propertiesFromResourceFiles(resourceFiles: [ResourceFile], includeAllFileLet: Bool = false, at externalAccessLevel: AccessLevel) -> [Let] {
    let filteredFiles = resourceFiles.filter { !$0.isDirectory }
    let filteredFileLets = filteredFiles.map { propertyForResourceFile($0, at: externalAccessLevel) }
    
    guard includeAllFileLet && !filteredFiles.isEmpty else {
      return filteredFileLets
    }
    
    let allFilesLet = Let(comments: ["An array of all fileResources contained in this namespaced folder (not including subfolders)"],
                          accessModifier: externalAccessLevel,
                          isStatic: true,
                          name: "allFiles",
                          typeDefinition: .specified(Type._Array.withGenericArgs([Type.FileResource])),
                          value: "[" + filteredFileLets.map { $0.name.description }.joined(separator: ", ") + "]")
    return [allFilesLet] + filteredFileLets
  }
  
  private func propertyForResourceFile(_ resourceFile: ResourceFile, at externalAccessLevel: AccessLevel, overrideLabel: String? = nil) -> Let {
    Let(
      comments: ["Resource file `\(resourceFile.fullname)`."],
      accessModifier: externalAccessLevel,
      isStatic: true,
      name: SwiftIdentifier(name: overrideLabel ?? resourceFile.fullname),
      typeDefinition: .inferred(Type.FileResource),
      value: "Rswift.FileResource(bundle: R.hostingBundle, name: \"\(resourceFile.filenameWithNamespace)\", pathExtension: \"\(resourceFile.pathExtension)\")"
    )
  }

  private func functionsFromResourceFiles(resourceFiles: [ResourceFile], at externalAccessLevel: AccessLevel) -> [Function] {

    return resourceFiles
      .filter { !$0.isDirectory }
      .flatMap { functionsFromResourceFile($0, at: externalAccessLevel) }
  }
  
  private func functionsFromResourceFile(_ resourceFile: ResourceFile, at externalAccessLevel: AccessLevel, overrideLabel: String? = nil) -> [Function] {
    let fullname = resourceFile.fullname
    let filenameWithNamespace = resourceFile.filenameWithNamespace
    let pathExtension = resourceFile.pathExtension
    return [
      Function(
        availables: [],
        comments: ["`bundle.url(forResource: \"\(filenameWithNamespace)\", withExtension: \"\(pathExtension)\")`"],
        accessModifier: externalAccessLevel,
        isStatic: true,
        name: SwiftIdentifier(name: "\(overrideLabel ?? fullname)Url"),
        generics: nil,
        parameters: [],
        doesThrow: false,
        returnType: Type._URL.asOptional(),
        body: "Self.\(SwiftIdentifier(name: overrideLabel ?? fullname)).bundle.url(forResource: Self.\(SwiftIdentifier(name: overrideLabel ?? fullname)))",
        os: []
      )
    ]
  }
	
	private func directoryStructsFromResourceFiles(resourceFiles: [ResourceFile], at externalAccessLevel: AccessLevel) -> [Struct] {
		resourceFiles
      .filter { $0.isDirectory }
      .compactMap { resource in
			let structName = SwiftIdentifier(name: resource.filename)
			return Struct(
				availables: [],
				comments: ["This struct is generated, and contains static references to \(resource.subfiles.count) files."],
				accessModifier: externalAccessLevel,
				type: Type(module: .host, name: structName),
				implements: [],
				typealiasses: [],
				properties: propertiesFromResourceFiles(resourceFiles: resource.subfiles, includeAllFileLet: true, at: externalAccessLevel) + [propertyForResourceFile(resource, at: externalAccessLevel, overrideLabel: "directory")],
				functions: functionsFromResourceFiles(resourceFiles: resource.subfiles, at: externalAccessLevel) + functionsFromResourceFile(resource, at: externalAccessLevel, overrideLabel: "directory"),
				structs: [],
				classes: [],
				os: []
			)
		}
	}
}
