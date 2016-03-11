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
    let groupedResourceFiles = resourceFiles
      .groupUniquesAndDuplicates { sanitizedSwiftName($0.fullname) }

    for duplicate in groupedResourceFiles.duplicates {
      let names = duplicate.map { $0.fullname }.sort().joinWithSeparator(", ")
      warn("Skipping \(duplicate.count) resource files because symbol '\(sanitizedSwiftName(duplicate.first!.fullname))' would be generated for all of these files: \(names)")
    }

    let resourceFileProperties: [Property] = groupedResourceFiles
      .uniques
      .map {
        let pathExtensionOrNilString = $0.pathExtension.map { "\"\($0)\"" } ?? "nil"
        return Let(isStatic: true, name: $0.fullname, typeDefinition: .Inferred(Type.FileResource), value: "FileResource(bundle: _R.hostingBundle, name: \"\($0.filename)\", pathExtension: \(pathExtensionOrNilString))")
      }
    let resourceFileFunctions: [Function] = groupedResourceFiles
      .uniques
      .flatMap {
        [
          Function(
            isStatic: true,
            name: $0.fullname,
            generics: nil,
            parameters: [
              Function.Parameter(name: "_", type: Type._Void)
            ],
            doesThrow: false,
            returnType: Type._NSURL.asOptional(),
            body: "let fileResource = R.file.\(sanitizedSwiftName($0.fullname))\nreturn fileResource.bundle?.URLForResource(fileResource)"
          ),
          Function(
            isStatic: true,
            name: $0.fullname,
            generics: nil,
            parameters: [
              Function.Parameter(name: "_", type: Type._Void)
            ],
            doesThrow: false,
            returnType: Type._String.asOptional(),
            body: "let fileResource = R.file.\(sanitizedSwiftName($0.fullname))\nreturn fileResource.bundle?.pathForResource(fileResource)"
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
