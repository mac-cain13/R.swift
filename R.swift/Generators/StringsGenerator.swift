//
//  StringsGenerator.swift
//  R.swift
//
//  Created by Nolan Warner on 2016/02/23.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
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
      properties: params.map(StringsGenerator.stringLet),
      functions: params.map(StringsGenerator.stringFunction),
      structs: []
    )
  }

  // Ahem, this code is a bit of a mess. It might need cleaning up... ;-)
  // Maybe when we pick up this issue: https://github.com/mac-cain13/R.swift/issues/136
  private static func computeParams(filename: String, strings: [LocalizableStrings]) -> [StringValues] {

    var allParams: [String: [(Locale, LocalizableStrings.Entry)]] = [:]
    let baseKeys: Set<String>?
    let bases = strings.filter { $0.locale.isBase }
    if bases.isEmpty {
      baseKeys = nil
    }
    else {
      baseKeys = Set(bases.flatMap { $0.keys })
    }

    // Warnings about duplicates and empties
    for ls in strings {
      let filenameLocale = ls.locale.withFilename(filename)
      let groupedKeys = ls.keys.groupBySwiftNames { $0 }

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
      var byKey: [String: LocalizableStrings.Entry] = [:]
      for entry in ls.entries {
        byKey[entry.key] = entry
      }
      for key in groupedKeys.uniques {
        if let entry = byKey[key] {
          if let _ = allParams[key] {
            allParams[key]?.append((ls.locale, entry))
          }
          else {
            allParams[key] = [(ls.locale, entry)]
          }
        }
      }
    }

    // Warnings about missing translations
    for (locale, lss) in strings.groupBy({ $0.locale }) {
      let filenameLocale = locale.withFilename(filename)
      let sourceKeys = baseKeys ?? Set(allParams.keys)

      let missing = sourceKeys.subtract(lss.flatMap { $0.keys })

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
    for (key, keyParams) in allParams.filter({ includeTranslation($0.0) }).sortBy({ $0.0 }) {
      var params: [StringParam] = []
      var areCorrectFormatSpecifiers = true

      for (locale, entry) in keyParams {
        if entry.params.any({ $0.spec == FormatSpecifier.TopType }) {
          let name = locale.withFilename(filename)
          warn("Skipping string \(key) in \(name), not all format specifiers are consecutive")

          areCorrectFormatSpecifiers = false
        }
      }

      if !areCorrectFormatSpecifiers { continue }

      for (_, entry) in keyParams {
        if let unified = params.unify(entry.params) {
          params = unified
        }
        else {
          badFormatSpecifiersKeys.insert(key)

          areCorrectFormatSpecifiers = false
        }
      }

      if !areCorrectFormatSpecifiers { continue }

      let vals = keyParams.map { locale, entry in (locale, entry.val) }
      let comments = keyParams.map { locale, entry in (locale, entry.comment) }
      let values = StringValues(key: key, params: params, tableName: filename, values: vals, entryComments: comments)
      results.append(values)
    }

    for badKey in badFormatSpecifiersKeys.sort() {
      let fewParams = allParams.filter { $0.0 == badKey }.map { $0.1 }

      if let params = fewParams.first {
        let locales = params.flatMap { $0.0.localeDescription }.joinWithSeparator(", ")
        warn("Skipping string for key \(badKey) (\(filename)), format specifiers don't match for all locales: \(locales)")
      }
    }

    return results
  }

  private static func stringLet(values: StringValues) -> Let {
    let escapedKey = values.key.escapedStringLiteral
    let locales = values.values
      .map { $0.0 }
      .flatMap { $0.localeDescription }
      .map { "\"\($0)\"" }
      .joinWithSeparator(", ")
    let firstComment = values.entryComments
      .first?
      .1?
      .escapedStringLiteral
    let escapedComment = firstComment.map { "\"\($0)\"" } ?? "nil"

    return Let(
      comments: values.comments,
      isStatic: true,
      name: values.key,
      typeDefinition: .Inferred(Type.StringResource),
      value: "StringResource(key: \"\(escapedKey)\", tableName: \"\(values.tableName)\", locales: [\(locales)], comment: \(escapedComment))"
    )
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

    let params = values.params.enumerate().map { ix, param -> Function.Parameter in
      let valueName = "value\(ix + 1)"

      if let paramName = param.name {
        return Function.Parameter(name: paramName, localName: valueName, type: param.spec.type)
      }
      else {
        if ix == 0 {
          return Function.Parameter(name: valueName, type: param.spec.type)
        }
        else {
          return Function.Parameter(name: "_", localName: valueName, type: param.spec.type)
        }
      }
    }

    let args = params.map { $0.localName ?? $0.name }.joinWithSeparator(", ")

    return Function(
      comments: values.comments,
      isStatic: true,
      name: values.key,
      generics: nil,
      parameters: params,
      doesThrow: false,
      returnType: Type._String,
      body: "return String(format: \(values.localizedString), locale: _R.applicationLocale, \(args))"
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
  let params: [StringParam]
  let tableName: String
  let values: [(Locale, String)]
  let entryComments: [(Locale, String?)]

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
      let str = "Base translation: \(baseValue)".commentString
      results.append(str)
    }
    else if !containsBase {
      if let (locale, value) = values.first {
        if let localeDescription = locale.localeDescription {
          let str = "\(localeDescription) translation: \(value)".commentString
          results.append(str)
        }
        else {
          let str = "Value: \(value)".commentString
          results.append(str)
        }
      }
    }

    if !anyNone {
      if !results.isEmpty {
        results.append("")
      }

      let locales = values.flatMap { $0.0.localeDescription }
      results.append("Locales: \(locales.joinWithSeparator(", "))")
    }
    
    let baseEntryComment = entryComments.filter { $0.0.isBase }.flatMap { $0.1 }.first
    if let baseEntryComment = baseEntryComment {
      if !results.isEmpty {
        results.append("")
      }
      
      let lines = baseEntryComment.componentsSeparatedByString("\n")
      if lines.count == 1 {
        results.append("Comment: \(lines[0])")
      } else {
        results.append("Comment:")
        let indented = lines.map { "  \($0)" }
        results.appendContentsOf(indented)
      }
    }

    return results
  }
}
