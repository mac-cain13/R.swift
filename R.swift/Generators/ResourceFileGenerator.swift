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
  let internalStruct: Struct?

  init(resourceFiles: [ResourceFile]) {
    let groupedResourceFiles = resourceFiles.groupUniquesAndDuplicates { sanitizedSwiftName($0.fullname) }

    for duplicate in groupedResourceFiles.duplicates {
      let names = duplicate.map { $0.fullname }.sort().joinWithSeparator(", ")
      warn("Skipping \(duplicate.count) resource files because symbol '\(sanitizedSwiftName(duplicate.first!.fullname))' would be generated for all of these files: \(names)")
    }

    let resourceStructs = groupedResourceFiles
      .uniques
      .map(ResourceFileGenerator.structFromResourceFile)

    let resourceLets: [Property] = resourceStructs
      .map {
        Let(isStatic: true, name: $0.type.name, type: nil, value: "_R.file.\($0.type.name)()")
      }

    externalStruct = Struct(
      type: Type(module: .Host, name: "file"),
      implements: [],
      typealiasses: [],
      properties: resourceLets,
      functions: [],
      structs: []
    )

    internalStruct = Struct(
      type: Type(module: .Host, name: "file"),
      implements: [],
      typealiasses: [],
      properties: [],
      functions: [],
      structs: resourceStructs
    )
  }

  private static func structFromResourceFile(resourceFile: ResourceFile) -> Struct {
    let pathExtensionOrNilString = resourceFile.pathExtension.map { "\"\($0)\"" } ?? "nil"

    return Struct(
      type: Type(module: .Host, name: sanitizedSwiftName(resourceFile.fullname)),
      implements: [Type.FileResourceProtocol],
      typealiasses: [],
      properties: [
        Let(isStatic: false, name: "bundle", type: nil, value: "_R.hostingBundle"),
        Let(isStatic: false, name: "name", type: nil, value: "\"\(resourceFile.filename)\""),
        Let(isStatic: false, name: "pathExtension", type: nil, value: pathExtensionOrNilString),
      ],
      functions: [],
      structs: []
    )
  }
}
