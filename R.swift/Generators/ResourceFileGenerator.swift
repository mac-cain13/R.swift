//
//  ResourceFile.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 10-12-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import Foundation

struct ResourceFileGenerator: Generator {
  let externalStruct: Struct?
  let internalStruct: Struct? = nil

  init(resourceFiles: [ResourceFile]) {

    let localized = resourceFiles.groupBy { $0.fullname }
    let groupedLocalized = localized.groupBySwiftIdentifiers { $0.0 }

    groupedLocalized.printWarningsForDuplicatesAndEmpties(source: "resource file", result: "file")

    // For resource files, the contents of the different locales don't matter, so we just use the first one
    let firstLocales = groupedLocalized.uniques.map { ($0.0, Array($0.1.prefix(1))) }

    externalStruct = Struct(
      comments: ["This `R.file` struct is generated, and contains static references to \(firstLocales.count) files."],
      type: Type(module: .host, name: "file"),
      implements: [],
      typealiasses: [],
      properties: firstLocales.flatMap(ResourceFileGenerator.propertiesFromResourceFiles),
      functions: firstLocales.flatMap(ResourceFileGenerator.functionsFromResourceFiles),
      structs: []
    )
  }

  private static func propertiesFromResourceFiles(_ fullname: String, resourceFiles: [ResourceFile]) -> [Property] {

    return resourceFiles
      .map {
        let pathExtensionOrNilString = $0.pathExtension.map { "\"\($0)\"" } ?? "nil"
        return Let(
          comments: ["Resource file `\($0.fullname)`."],
          isStatic: true,
          name: SwiftIdentifier(name: $0.fullname),
          typeDefinition: .inferred(Type.FileResource),
          value: "FileResource(bundle: _R.hostingBundle, name: \"\($0.filename)\", pathExtension: \(pathExtensionOrNilString))"
        )
    }
  }

  private static func functionsFromResourceFiles(_ fullname: String, resourceFiles: [ResourceFile]) -> [Function] {

    return resourceFiles
      .flatMap { resourceFile -> [Function] in
        let fullname = resourceFile.fullname
        let filename = resourceFile.filename
        let pathExtension = resourceFile.pathExtension.map { ext in "\"\(ext)\"" } ?? "nil"

        return [
          Function(
            comments: ["`bundle.url(forResource: \"\(filename)\", withExtension: \(pathExtension))`"],
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
