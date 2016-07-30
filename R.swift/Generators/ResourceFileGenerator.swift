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
    let groupedResourceFiles = resourceFiles.groupBySwiftIdentifiers { $0.fullname }
    groupedResourceFiles.printWarningsForDuplicatesAndEmpties(source: "resource file", result: "file")

    let resourceFileProperties: [Property] = groupedResourceFiles
      .uniques
      .map {
        let pathExtensionOrNilString = $0.pathExtension.map { "\"\($0)\"" } ?? "nil"
        return Let(
          comments: ["Resource file `\($0.fullname)`."],
          isStatic: true,
          name: SwiftIdentifier(name: $0.fullname),
          typeDefinition: .Inferred(Type.FileResource),
          value: "FileResource(bundle: _R.hostingBundle, name: \"\($0.filename)\", pathExtension: \(pathExtensionOrNilString))"
          )
      }
    let resourceFileFunctions: [Function] = groupedResourceFiles
      .uniques
      .flatMap { resourceFile -> [Function] in
        let fullname = resourceFile.fullname
        let filename = resourceFile.filename
        let pathExtension = resourceFile.pathExtension.map { ext in "\"\(ext)\"" } ?? "nil"

        return [
          Function(
            comments: ["`bundle.URLForResource(\"\(filename)\", withExtension: \(pathExtension))`"],
            isStatic: true,
            name: SwiftIdentifier(name: fullname),
            generics: nil,
            parameters: [
              Function.Parameter(name: "_", type: Type._Void)
            ],
            doesThrow: false,
            returnType: Type._NSURL.asOptional(),
            body: "let fileResource = R.file.\(SwiftIdentifier(name: fullname))\nreturn fileResource.bundle.URLForResource(fileResource)"
          )
        ]
      }

    externalStruct = Struct(
      comments: ["This `R.file` struct is generated, and contains static references to \(resourceFileProperties.count) files."],
      type: Type(module: .Host, name: "file"),
      implements: [],
      typealiasses: [],
      properties: resourceFileProperties,
      functions: resourceFileFunctions,
      structs: []
    )
  }
}
