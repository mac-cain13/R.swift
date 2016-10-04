//
//  ResourceFile.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 10-12-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import Foundation

struct ResourceFileGenerator: StructGenerator {
  private let resourceFiles: [ResourceFile]

  init(resourceFiles: [ResourceFile]) {
    self.resourceFiles = resourceFiles
  }

  func generateStruct(at externalAccessLevel: AccessModifier) -> Struct? {
    let localized = resourceFiles.groupBy { $0.fullname }
    let groupedLocalized = localized.groupedBySwiftIdentifier { $0.0 }

    groupedLocalized.printWarningsForDuplicatesAndEmpties(source: "resource file", result: "file")

    // For resource files, the contents of the different locales don't matter, so we just use the first one
    let firstLocales = groupedLocalized.uniques.map { ($0.0, Array($0.1.prefix(1))) }

    return Struct(
      comments: ["This `R.file` struct is generated, and contains static references to \(firstLocales.count) files."],
      accessModifier: externalAccessLevel,
      type: Type(module: .host, name: "file"),
      implements: [],
      typealiasses: [],
      properties: firstLocales.flatMap { propertiesFromResourceFiles(resourceFiles: $0.1, at: externalAccessLevel) },
      functions: firstLocales.flatMap { functionsFromResourceFiles(resourceFiles: $0.1, at: externalAccessLevel) },
      structs: []
    )
  }

  private func propertiesFromResourceFiles(resourceFiles: [ResourceFile], at externalAccessLevel: AccessModifier) -> [Let] {

    return resourceFiles
      .map {
        return Let(
          comments: ["Resource file `\($0.fullname)`."],
          accessModifier: externalAccessLevel,
          isStatic: true,
          name: SwiftIdentifier(name: $0.fullname),
          typeDefinition: .inferred(Type.FileResource),
          value: "Rswift.FileResource(bundle: _R.hostingBundle, name: \"\($0.filename)\", pathExtension: \"\($0.pathExtension)\")"
        )
    }
  }

  private func functionsFromResourceFiles(resourceFiles: [ResourceFile], at externalAccessLevel: AccessModifier) -> [Function] {

    return resourceFiles
      .flatMap { resourceFile -> [Function] in
        let fullname = resourceFile.fullname
        let filename = resourceFile.filename
        let pathExtension = resourceFile.pathExtension

        return [
          Function(
            comments: ["`bundle.url(forResource: \"\(filename)\", withExtension: \"\(pathExtension)\")`"],
            accessModifier: externalAccessLevel,
            isStatic: true,
            name: SwiftIdentifier(name: fullname),
            generics: nil,
            parameters: [
              Function.Parameter(name: "_", type: Type._Void, defaultValue: "()")
            ],
            doesThrow: false,
            returnType: Type._URL.asOptional(),
            body: "let fileResource = R.file.\(SwiftIdentifier(name: fullname))\nreturn fileResource.bundle.url(forResource: fileResource)"
          )
        ]
    }
  }
}
