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

  init(localizableStrings: [LocalizableStrings]) {

    let localized = localizableStrings.groupBy { $0.filename }
    let groupedLocalized = localized.groupBySwiftNames { $0.0 }

    for (sanitizedName, duplicates) in groupedLocalized.duplicates {
      warn("Skipping \(duplicates.count) strings files because symbol '\(sanitizedName)' would be generated for all of these filenames: \(duplicates.joinWithSeparator(", "))")
    }

    let empties = groupedLocalized.empties
    if let empty = empties.first where empties.count == 1 {
      warn("Skipping 1 strings file because no swift identifier can be generated for filename: \(empty)")
    }
    else if empties.count > 1 {
      warn("Skipping \(empties.count) strings files because no swift identifier can be generated for all of these filenames: \(empties.joinWithSeparator(", "))")
    }

    externalStruct = Struct(
      type: Type(module: .Host, name: "string"),
      implements: [],
      typealiasses: [],
      properties: [],
      functions: [],
      structs: groupedLocalized.uniques.flatMap(StringsGenerator.stringStructFromLocalizableStrings)
    )
  }

  private static func stringStructFromLocalizableStrings(filename: String, strings: [LocalizableStrings]) -> Struct? {

    var allParams: [String: [Type]] = [:]
    let baseKeys = strings
      .filter { $0.locale.isBase }
      .map { Set($0.dictionary.keys) }
      .first

    for ls in strings {
      let filenameLocale = ls.locale.withFilename(filename)
      let groupedKeys = ls.dictionary.keys.groupBySwiftNames { $0 }

      for (sanitizedName, duplicates) in groupedKeys.duplicates {
        warn("Skipping \(duplicates.count) strings in \(filenameLocale) because symbol '\(sanitizedName)' would be generated for all of these keys: \(duplicates.joinWithSeparator(", "))")
      }

      let empties = groupedKeys.empties
      if let empty = empties.first where empties.count == 1 {
        warn("Skipping 1 string in \(filenameLocale) because no swift identifier can be generated for key: \(empty)")
      }
      else if empties.count > 1 {
        warn("Skipping \(empties.count) strings in \(filenameLocale) because no swift identifier can be generated for all of these keys: \(empties.joinWithSeparator(", "))")
      }

      for key in groupedKeys.uniques {
        if let _ = allParams[key] {
          // TODO check if existing matches current params
        }
        else {
          if let (_, params) = ls.dictionary[key]  {
            allParams[key] = params
          }
        }
      }
    }

    for ls in strings {
      let filenameLocale = ls.locale.withFilename(filename)
      let sourceKeys = baseKeys ?? Set(allParams.keys)

      let missing = sourceKeys.subtract(ls.dictionary.keys)

      if missing.isEmpty {
        continue
      }

      let paddedKeys = missing.sort().map { "'\($0)'" }
      let paddedKeysString = paddedKeys.joinWithSeparator(", ")

      warn("Strings file \(filenameLocale) is missing translations for keys: \(paddedKeysString)")
    }

    return Struct(
      type: Type(module: .Host, name: sanitizedSwiftName(filename)),
      implements: [],
      typealiasses: [],
      properties: [],
      functions: allParams.map { ($0.0, $0.1, filename)}.map(StringsGenerator.stringFunction),
      structs: []
    )
  }

  private static func stringFunction(key: String, params: [Type], tableName: String) -> Function {
    if params.isEmpty {
      return stringFunctionNoParams(key, tableName: tableName)
    }
    else {
      return stringFunctionParams(key, params: params, tableName: tableName)
    }
  }

  private static func stringFunctionNoParams(key: String, tableName: String) -> Function {
    let body: String

    if tableName == "Localizable" {
      body = "return NSLocalizedString(\"\(key)\", comment: \"\")"
    }
    else {
      body = "return NSLocalizedString(\"\(key)\", tableName: \"\(tableName)\", comment: \"\")"
    }

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
      body: body
    )
  }

  private static func stringFunctionParams(key: String, params: [Type], tableName: String) -> Function {

    let params = params.enumerate().map { ix, type -> Function.Parameter in
      let name = "value\(ix + 1)"

      if ix == 0 {
        return Function.Parameter(name: name, type: type)
      }
      else {
        return Function.Parameter(name: "_", localName: name, type: type)
      }
    }

    let format: String

    if tableName == "Localizable" {
      format = "NSLocalizedString(\"\(key)\", comment: \"\")"
    }
    else {
      format = "NSLocalizedString(\"\(key)\", tableName: \"\(tableName)\", comment: \"\")"
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
      body: "return String(format: \(format), locale: NSLocale.currentLocale(), \(args))"
    )
  }

}

extension Locale {
  func withFilename(filename: String) -> String {
    switch self {
    case .None:
      return "'\(filename)'"
    case .Base:
      return "'\(filename)' (Base)"
    case .Language(let language):
      return "'\(filename)' (\(language))"
    }
  }
}
