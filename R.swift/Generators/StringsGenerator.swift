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
      comments: ["This `R.string` struct is generated, and contains static references to \(groupedLocalized.uniques.count) localization tables."],
      type: Type(module: .Host, name: "string"),
      implements: [],
      typealiasses: [],
      properties: [],
      functions: [],
      structs: groupedLocalized.uniques.flatMap(StringsGenerator.stringStructFromLocalizableStrings)
    )
  }

  private static func stringStructFromLocalizableStrings(filename: String, strings: [LocalizableStrings]) -> Struct? {

    let name = sanitizedSwiftName(filename)
    let params = computeParams(filename, strings: strings)

    return Struct(
      comments: ["This `R.string.\(name)` struct is generated, and contains static references to \(params.count) localization keys."],
      type: Type(module: .Host, name: name),
      implements: [],
      typealiasses: [],
      properties: [],
      functions: params.map(StringsGenerator.stringFunction),
      structs: []
    )
  }

  // Ahem, this code is a bit of a mess. It might need cleaning up... ;-)
  private static func computeParams(filename: String, strings: [LocalizableStrings]) -> [StringValues]
  {
    var allParams: [String: [(Locale, String, [FormatSpecifier])]] = [:]
    let baseKeys = strings
      .filter { $0.locale.isBase }
      .map { Set($0.dictionary.keys) }
      .first

    // Warnings about duplicates and empties
    for ls in strings {
      let filenameLocale = ls.locale.withFilename(filename)
      let groupedKeys = ls.dictionary.keys.groupBySwiftNames { $0 }

      for (sanitizedName, duplicates) in groupedKeys.duplicates {
        warn("Skipping \(duplicates.count) strings in \(filenameLocale) because symbol '\(sanitizedName)' would be generated for all of these keys: \(duplicates.map { "'\($0)'" }.joinWithSeparator(", "))")
      }

      let empties = groupedKeys.empties
      if let empty = empties.first where empties.count == 1 {
        warn("Skipping 1 string in \(filenameLocale) because no swift identifier can be generated for key: \(empty)")
      }
      else if empties.count > 1 {
        warn("Skipping \(empties.count) strings in \(filenameLocale) because no swift identifier can be generated for all of these keys: \(empties.joinWithSeparator(", "))")
      }

      // Save uniques
      for key in groupedKeys.uniques {
        if let (value, params) = ls.dictionary[key] {
          if let _ = allParams[key] {
            allParams[key]?.append((ls.locale, value, params))
          }
          else {
            allParams[key] = [(ls.locale, value, params)]
          }
        }
      }
    }

    // Warnings about missing translations
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

    // Only include translation if it exists in Base
    func includeTranslation(key: String) -> Bool {
      if let baseKeys = baseKeys {
        return baseKeys.contains(key)
      }

      return true
    }

    var results: [StringValues] = []
    var badFormatSpecifiersKeys = Set<String>()

    // Unify format specifiers
    for (key, params) in allParams.filter({ includeTranslation($0.0) }).sortBy({ $0.0 }) {
      var formatSpecifiers: [FormatSpecifier] = []
      var areCorrectFormatSpecifiers = true

      for (locale, _, fs) in params {
        if fs.contains(FormatSpecifier.TopType) {
          let name = locale.withFilename(filename)
          warn("Skipping string \(key) in \(name), not all format specifiers are consecutive")

          areCorrectFormatSpecifiers = false
        }
      }

      if !areCorrectFormatSpecifiers { continue }

      for (_, _, fs) in params {
        let length = min(formatSpecifiers.count, fs.count)

        if formatSpecifiers.prefix(length) == fs.prefix(length) {
          if fs.count > formatSpecifiers.count {
            formatSpecifiers = fs
          }
        }
        else {
          badFormatSpecifiersKeys.insert(key)

          areCorrectFormatSpecifiers = false
        }
      }

      if !areCorrectFormatSpecifiers { continue }

      let vals = params.map { ($0.0, $0.1) }
      let values = StringValues(key: key, params: formatSpecifiers, tableName: filename, values: vals )
      results.append(values)
    }

    for badKey in badFormatSpecifiersKeys.sort() {
      let fewParams = allParams.filter { $0.0 == badKey }.map { $0.1 }

      if let params = fewParams.first {
        let locales = params.map { $0.0.description }.joinWithSeparator(", ")
        warn("Skipping string for key \(badKey) (\(filename)), format specifiers don't match for all locales: \(locales)")
      }
    }

    return results
  }

  private static func stringFunction(values: StringValues) -> Function {
    if values.params.isEmpty {
      return stringFunctionNoParams(values)
    }
    else {
      return stringFunctionParams(values)
    }
  }

  private static func stringFunctionNoParams(values: StringValues) -> Function {

    return Function(
      comments: values.comments,
      isStatic: true,
      name: values.key,
      generics: nil,
      parameters: [
        Function.Parameter(name: "_", type: Type._Void)
      ],
      doesThrow: false,
      returnType: Type._String,
      body: "return \(values.localizedString)"
    )
  }

  private static func stringFunctionParams(values: StringValues) -> Function {

    let params = values.params.enumerate().map { ix, formatSpecifier -> Function.Parameter in
      let name = "value\(ix + 1)"

      if ix == 0 {
        return Function.Parameter(name: name, type: formatSpecifier.type)
      }
      else {
        return Function.Parameter(name: "_", localName: name, type: formatSpecifier.type)
      }
    }

    let args = params.enumerate().map { ix, _ in "value\(ix + 1)" }.joinWithSeparator(", ")

    return Function(
      comments: values.comments,
      isStatic: true,
      name: values.key,
      generics: nil,
      parameters: params,
      doesThrow: false,
      returnType: Type._String,
      body: "return String(format: \(values.localizedString), locale: NSLocale.currentLocale(), \(args))"
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

private struct StringValues {
  let key: String
  let params: [FormatSpecifier]
  let tableName: String
  let values: [(Locale, String)]

  var localizedString: String {
    let escapedKey = key.escapedStringLiteral

    if tableName == "Localizable" {
      return "NSLocalizedString(\"\(escapedKey)\", comment: \"\")"
    }
    else {
      return "NSLocalizedString(\"\(escapedKey)\", tableName: \"\(tableName)\", comment: \"\")"
    }
  }

  var comments: [String] {
    var results: [String] = []

    let containsBase = values.any { $0.0.isBase }
    let baseValue = values.filter { $0.0.isBase }.map { $0.1 }.first
    let anyNone = values.any { $0.0.isNone }

    if let baseValue = baseValue {
      let str = "Base translation: \(baseValue)".stringByReplacingOccurrencesOfString("\n", withString: " ")
      results.append(str)
    }
    else if !containsBase {
      if let (locale, value) = values.first {
        if locale.isNone {
          let str = "Value: \(value)".stringByReplacingOccurrencesOfString("\n", withString: " ")
          results.append(str)
        }
        else {
          let str = "\(locale.description) translation: \(value)".stringByReplacingOccurrencesOfString("\n", withString: " ")
          results.append(str)
        }
      }
    }

    if !anyNone {
      if !results.isEmpty {
        results.append("")
      }

      let locales = values.map { $0.0.description }
      results.append("Locales: \(locales.joinWithSeparator(", "))")
    }

    return results
  }
}
