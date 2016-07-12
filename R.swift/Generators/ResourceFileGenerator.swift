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
    let groupedResourceFiles = resourceFiles.groupBySwiftNames { $0.fullname }

    for (name, duplicates) in groupedResourceFiles.duplicates {
      warn(warning: "Skipping \(duplicates.count) resource files because symbol '\(name)' would be generated for all of these files: \(duplicates.joined(separator: ", "))")
    }

    let empties = groupedResourceFiles.empties
    if let empty = empties.first where empties.count == 1 {
      warn(warning: "Skipping 1 resource file because no swift identifier can be generated for file: \(empty)")
    }
    else if empties.count > 1 {
      warn(warning: "Skipping \(empties.count) resource files because no swift identifier can be generated for all of these files: \(empties.joined(separator: ", "))")
    }

    let resourceFileProperties: [Property] = groupedResourceFiles
      .uniques
      .map {
        let pathExtensionOrNilString = $0.pathExtension.map { "\"\($0)\"" } ?? "nil"
        return Let(
          comments: ["Resource file `\($0.fullname)`."],
          isStatic: true,
          name: $0.fullname,
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
            comments: ["`bundle.URL(forResource: \"\(filename)\", withExtension: \(pathExtension))`"],
            isStatic: true,
            name: fullname,
            generics: nil,
            parameters: [
              Function.Parameter(name: "_", type: Type._Void)
            ],
            doesThrow: false,
            returnType: Type._URL.asOptional(),
            body: "let fileResource = R.file.\(sanitizedSwiftName(fullname))\nreturn fileResource.bundle.URL(forResource: fileResource)"
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
