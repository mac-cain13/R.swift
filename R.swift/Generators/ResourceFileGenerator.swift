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
    let groupedResourceFiles = resourceFiles.groupUniquesAndDuplicates { sanitizedSwiftName($0.fullname) }

    for duplicate in groupedResourceFiles.duplicates {
      let names = duplicate.map { $0.fullname }.sort().joinWithSeparator(", ")
      warn("Skipping \(duplicate.count) resource files because symbol '\(sanitizedSwiftName(duplicate.first!.fullname))' would be generated for all of these files: \(names)")
    }

    let resourceStructs = groupedResourceFiles
      .uniques
      .map(ResourceFileGenerator.structFromResourceFile)

    externalStruct = Struct(
      type: Type(module: .Host, name: "file"),
      implements: [],
      typealiasses: [],
      properties: [],
      functions: [],
      structs: resourceStructs
    )
  }

  private static func structFromResourceFile(resourceFile: ResourceFile) -> Struct {
    let pathExtensionOrNilString = resourceFile.pathExtension ?? "nil"

    return Struct(
      type: Type(module: .Host, name: sanitizedSwiftName(resourceFile.fullname, lowercaseFirstCharacter: true)),
      implements: [],
      typealiasses: [],
      properties: [
        Let(isStatic: true, name: "url", type: nil, value: "_R.hostingBundle?.URLForResource(\"\(resourceFile.filename)\", withExtension: \"\(pathExtensionOrNilString)\")")
      ],
      functions: [],
      structs: []
    )
  }
}
