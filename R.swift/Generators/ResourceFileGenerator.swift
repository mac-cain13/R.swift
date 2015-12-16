//
//  ResourceFile.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 10-12-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import Foundation

struct ResourceFileGenerator: Generator {
  let externalFunction: Function? = nil
  let externalStruct: Struct?
  let internalStruct: Struct? = nil

  init(resourceFiles: [ResourceFile]) {
    let groupedResourceFiles = resourceFiles.groupUniquesAndDuplicates { sanitizedSwiftName($0.fullname) }

    for duplicate in groupedResourceFiles.duplicates {
      let names = duplicate.map { $0.fullname }.sort().joinWithSeparator(", ")
      warn("Skipping \(duplicate.count) resource files because symbol '\(sanitizedSwiftName(duplicate.first!.fullname))' would be generated for all of these files: \(names)")
    }

    let resourceVars = groupedResourceFiles
      .uniques
      .map(ResourceFileGenerator.varFromResourceFile)

    externalStruct = Struct(
      type: Type(module: .Host, name: "file"),
      implements: [],
      typealiasses: [],
      vars: resourceVars,
      functions: [],
      structs: []
    )
  }

  private static func varFromResourceFile(resourceFile: ResourceFile) -> Var {
    let pathExtensionOrNilString = resourceFile.pathExtension ?? "nil"
    return Var(isStatic: true, name: resourceFile.fullname, type: Type._NSURL.asOptional(), getter: "return _R.hostingBundle?.URLForResource(\"\(resourceFile.filename)\", withExtension: \"\(pathExtensionOrNilString)\")")
  }
}
