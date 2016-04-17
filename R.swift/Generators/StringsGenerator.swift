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

    var allKeys: [String: [Type]] = [:]

    for ls in strings {
      let locale = ls.locale ?? "???"
      let groupedKeys = ls.dictionary.keys.groupBySwiftNames { $0 }

      for (sanitizedName, duplicates) in groupedKeys.duplicates {
        warn("Skipping \(duplicates.count) strings in locale '\(locale)' because symbol '\(sanitizedName)' would be generated for all of these keys: \(duplicates.joinWithSeparator(", "))")
      }

      let empties = groupedKeys.empties
      if let empty = empties.first where empties.count == 1 {
        warn("Skipping 1 string locale '\(locale)' because no swift identifier can be generated for key: \(empty)")
      }
      else if empties.count > 1 {
        warn("Skipping \(empties.count) strings in locale '\(locale)' because no swift identifier can be generated for all of these keys: \(empties.joinWithSeparator(", "))")
      }

      for key in groupedKeys.uniques {
        if let _ = allKeys[key] {
          // TODO check if existing matches current params
        }
        else {
          if let (_, params) = ls.dictionary[key] {
            allKeys[key] = params
          }
        }
      }
    }

    for ls in strings {
      let locale = ls.locale ?? "???"

      let missing = Set(allKeys.keys).subtract(ls.dictionary.keys)

      if missing.isEmpty {
        continue
      }

      let paddedKeys = missing.sort().map { "'\($0)'" }
      let paddedKeysString = paddedKeys.joinWithSeparator(", ")

      warn("Locale '\(locale)' is missing translations for keys: \(paddedKeysString)")
    }

    externalStruct = Struct(
      type: Type(module: .Host, name: "string"),
      implements: [],
      typealiasses: [],
      properties: [],
      functions: allKeys.map(StringsGenerator.stringFunction),
      structs: []
    )
  }

  private static func stringFunction(key: String, params: [Type]) -> Function {
    if params.isEmpty {
      return stringFunctionNoParams(key)
    }
    else {
      return stringFunctionParams(key, params: params)
    }
  }

  private static func stringFunctionNoParams(key: String) -> Function {
    return Function(
      comments: [],
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

  private static func stringFunctionParams(key: String, params: [Type]) -> Function {

    let params = params.enumerate().map { ix, type -> Function.Parameter in
      let name = "value\(ix + 1)"

      if ix == 0 {
        return Function.Parameter(name: name, type: type)
      }
      else {
        return Function.Parameter(name: "_", localName: name, type: type)
      }
    }

    let args = params.enumerate().map { ix, _ in "value\(ix + 1)" }.joinWithSeparator(", ")

    return Function(
      comments: [],
      isStatic: true,
      name: key,
      generics: nil,
      parameters: params,
      doesThrow: false,
      returnType: Type._String,
      body: "return String(format: NSLocalizedString(\"\(key)\", comment: \"\"), locale: NSLocale.currentLocale(), \(args))"
    )
  }

}
