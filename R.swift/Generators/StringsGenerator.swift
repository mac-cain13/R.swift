//
//  StringsGenerator.swift
//  R.swift
//
//  Created by Nolan Warner on 2016/02/23.
//  Copyright © 2016 Nolan Warner. All rights reserved.
//

import Foundation

struct StringsGenerator: Generator {
  let externalStruct: Struct?
  let internalStruct: Struct? = nil
  
  init(strings: [LocalizableStrings]) {

    var allKeys: Set<String> = Set()

    for ls in strings {
      let locale = ls.locale ?? "???"
      let groupedKeys = ls.dictionary.keys.groupBySwiftNames { $0 }

      for (sanitizedName, duplicates) in groupedKeys.duplicates {
        warn("Skipping \(duplicates.count) strings in locale '\(locale)' because symbol '\(sanitizedName)' would be generated for all of these keys: \(duplicates.joinWithSeparator(", "))")
      }

      allKeys = allKeys.union(groupedKeys.uniques)
    }

    for ls in strings {
      let locale = ls.locale ?? "???"

      let missing = allKeys.subtract(ls.dictionary.keys)

      if missing.isEmpty {
        continue
      }

      let paddedKeys = missing.sort().map { "'\($0)'" }
      let paddedKeysString = paddedKeys.joinWithSeparator(", ")

      warn("Locale '\(locale)' is missing translations for keys: \(paddedKeysString)")
    }

    let groupedKeys = allKeys.groupBySwiftNames { $0 }

    externalStruct = Struct(
      type: Type(module: .Host, name: "string"),
      implements: [],
      typealiasses: [],
      properties: [],
      functions: groupedKeys.uniques.map(StringsGenerator.stringFunction),
      structs: []
    )
  }

  private static func stringFunction(key: String) -> Function {
    return Function(
      isStatic: true,
      name: key,
      generics: nil,
      parameters: [
        Function.Parameter(name: "_", type: Type._Void)
      ],
      doesThrow: false,
      returnType: Type._String,
      body: "return NSLocalizedString(\"\(key)\", comment: \"\")"
    )
  }
}
