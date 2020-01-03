//
//  StringsStructGenerator.swift
//  R.swift
//
//  Created by Nolan Warner on 2016/02/23.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

struct StringsStructGenerator: ExternalOnlyStructGenerator {
  private let localizableStrings: [LocalizableStrings]
  private let developmentLanguage: String

  init(localizableStrings: [LocalizableStrings], developmentLanguage: String) {
    self.localizableStrings = localizableStrings
    self.developmentLanguage = developmentLanguage
  }

  func generatedStruct(at externalAccessLevel: AccessLevel, prefix: SwiftIdentifier) -> Struct {
    let structName: SwiftIdentifier = "string"
    let qualifiedName = prefix + structName
    let localized = localizableStrings.grouped(by: { $0.filename })
    let groupedLocalized = localized.grouped(bySwiftIdentifier: { $0.0 })

    groupedLocalized.printWarningsForDuplicatesAndEmpties(source: "strings file", result: "file")

    let structs = groupedLocalized.uniques.compactMap { arg -> Struct? in
      let (key, value) = arg
      return stringStructFromLocalizableStrings(filename: key, strings: value, at: externalAccessLevel, prefix: qualifiedName)
    }

    return Struct(
      availables: [],
      comments: ["This `\(qualifiedName)` struct is generated, and contains static references to \(groupedLocalized.uniques.count) localization tables."],
      accessModifier: externalAccessLevel,
      type: Type(module: .host, name: structName),
      implements: [],
      typealiasses: [],
      properties: [],
      functions: [],
      structs: structs,
      classes: [],
      os: []
    )
  }

  private func stringStructFromLocalizableStrings(filename: String, strings: [LocalizableStrings], at externalAccessLevel: AccessLevel, prefix: SwiftIdentifier) -> Struct? {

    let structName = SwiftIdentifier(name: filename)
    let qualifiedName = prefix + structName

    let params = computeParams(filename: filename, strings: strings)

    return Struct(
      availables: [],
      comments: ["This `\(qualifiedName)` struct is generated, and contains static references to \(params.count) localization keys."],
      accessModifier: externalAccessLevel,
      type: Type(module: .host, name: structName),
      implements: [],
      typealiasses: [],
      properties: params.flatMap {[
        stringLet(values: $0, at: externalAccessLevel),
        resourceLet(values: $0),
        ]},
      functions: [],
      structs: [],
      classes: [],
      os: []
    )
  }

  // Ahem, this code is a bit of a mess. It might need cleaning up... ;-)
  // Maybe when we pick up this issue: https://github.com/mac-cain13/R.swift/issues/136
  private func computeParams(filename: String, strings: [LocalizableStrings]) -> [StringValues] {

    var allParams: [String: [(Locale, String, [StringParam])]] = [:]
    let primaryLanguage: String
    let primaryKeys: Set<String>?
    let bases = strings.filter { $0.locale.isBase }
    let developments = strings.filter { $0.locale.language == developmentLanguage }

    if !bases.isEmpty {
      primaryKeys = Set(bases.flatMap { $0.dictionary.keys })
      primaryLanguage = "Base"
    } else if !developments.isEmpty {
      primaryKeys = Set(developments.flatMap { $0.dictionary.keys })
      primaryLanguage = developmentLanguage
    } else {
      primaryKeys = nil
      primaryLanguage = developmentLanguage
    }

    // Warnings about duplicates and empties
    for ls in strings {
      let filenameLocale = ls.locale.withFilename(filename)
      let groupedKeys = ls.dictionary.keys.grouped(bySwiftIdentifier: { $0 })

      groupedKeys.printWarningsForDuplicatesAndEmpties(source: "string", container: "in \(filenameLocale)", result: "key")

      // Save uniques
      for key in groupedKeys.uniques {
        if let (params, commentValue) = ls.dictionary[key] {
          if let _ = allParams[key] {
            allParams[key]?.append((ls.locale, commentValue, params))
          }
          else {
            allParams[key] = [(ls.locale, commentValue, params)]
          }
        }
      }
    }

    // Warnings about missing translations
    for (locale, lss) in strings.grouped(by: { $0.locale }) {
      let filenameLocale = locale.withFilename(filename)
      let sourceKeys = primaryKeys ?? Set(allParams.keys)

      let missing = sourceKeys.subtracting(lss.flatMap { $0.dictionary.keys })

      if missing.isEmpty {
        continue
      }

      let paddedKeys = missing.sorted().map { "'\($0)'" }
      let paddedKeysString = paddedKeys.joined(separator: ", ")

      warn("Strings file \(filenameLocale) is missing translations for keys: \(paddedKeysString)")
    }

    // Warnings about extra translations
    for (locale, lss) in strings.grouped(by: { $0.locale }) {
      let filenameLocale = locale.withFilename(filename)
      let sourceKeys = primaryKeys ?? Set(allParams.keys)

      let usedKeys = Set(lss.flatMap { $0.dictionary.keys })
      let extra = usedKeys.subtracting(sourceKeys)

      if extra.isEmpty {
        continue
      }

      let paddedKeys = extra.sorted().map { "'\($0)'" }
      let paddedKeysString = paddedKeys.joined(separator: ", ")

      warn("Strings file \(filenameLocale) has extra translations (not in \(primaryLanguage)) for keys: \(paddedKeysString)")
    }

    // Only include translation if it exists in the primary language
    func includeTranslation(_ key: String) -> Bool {
      if let primaryKeys = primaryKeys {
        return primaryKeys.contains(key)
      }

      return true
    }

    var results: [StringValues] = []
    var badFormatSpecifiersKeys = Set<String>()

    let filteredSortedParams = allParams
      .map { $0 }
      .filter { includeTranslation($0.0) }
      .sorted(by: { $0.0 < $1.0 })

    // Unify format specifiers
    for (key, keyParams) in filteredSortedParams  {
      var params: [StringParam] = []
      var areCorrectFormatSpecifiers = true

      for (locale, _, ps) in keyParams {
        if ps.contains(where: { $0.spec == FormatSpecifier.topType }) {
          let name = locale.withFilename(filename)
          warn("Skipping string \(key) in \(name), not all format specifiers are consecutive")

          areCorrectFormatSpecifiers = false
        }
      }

      if !areCorrectFormatSpecifiers { continue }

      for (_, _, ps) in keyParams {
        if let unified = params.unify(ps) {
          params = unified
        }
        else {
          badFormatSpecifiersKeys.insert(key)

          areCorrectFormatSpecifiers = false
        }
      }

      if params.count > 5 {
        warn("Skipping string \(key), key has too many arguments (\(params.count)), maximum supported is 5")
        areCorrectFormatSpecifiers = false
      }

      if !areCorrectFormatSpecifiers { continue }

      let vals = keyParams.map { ($0.0, $0.1) }
      let values = StringValues(key: key, params: params, tableName: filename, values: vals, developmentLanguage: developmentLanguage)
      results.append(values)
    }

    for badKey in badFormatSpecifiersKeys.sorted() {
      let fewParams = allParams.filter { $0.0 == badKey }.map { $0.1 }

      if let params = fewParams.first {
        let locales = params.compactMap { $0.0.localeDescription }.joined(separator: ", ")
        warn("Skipping string for key \(badKey) (\(filename)), format specifiers don't match for all locales: \(locales)")
      }
    }

    return results
  }

  private func resourceLet(values: StringValues) -> Let {
    let escapedKey = values.key.escapedStringLiteral
    let locales = values.values
      .map { $0.0 }
      .compactMap { $0.localeDescription }
      .map { "\"\($0)\"" }
      .joined(separator: ", ")

    return Let(
      comments: [],
      accessModifier: .privateLevel,
      isStatic: true,
      name: resourceName(values: values),
      typeDefinition: .inferred(Type.StringResource),
      value: "Rswift.StringResource(key: \"\(escapedKey)\", tableName: \"\(values.tableName)\", bundle: R.hostingBundle, locales: [\(locales)], comment: nil)"
    )
  }

  private func stringLet(values: StringValues, at externalAccessLevel: AccessLevel) -> Let {
    let type: Type
    let argTypes = values.params.map { $0.spec.type }
    switch argTypes.count {
      case 0: type = .LocalizedStringNoArg
      case 1: type = .LocalizedStringOneArg
      case 2: type = .LocalizedStringTwoArgs
      case 3: type = .LocalizedStringThreeArgs
      case 4: type = .LocalizedStringFourArgs
      case 5: type = .LocalizedStringFiveArgs
      default: fatalError("Unhandled argument count. Maximum supported is 5")
    }

    return Let(
      comments: values.comments,
      accessModifier: externalAccessLevel,
      isStatic: true,
      name: SwiftIdentifier(name: values.key),
      typeDefinition: .specified(type.withGenericArgs(argTypes)),
      value: "\(type.name)(resource: \(resourceName(values: values)))"
    )
  }
}

private func resourceName(values: StringValues) -> SwiftIdentifier {
    return SwiftIdentifier(name: "_" + values.key)
}

extension Locale {
  func withFilename(_ filename: String) -> String {
    switch self {
    case .none:
      return "'\(filename)'"
    case .base:
      return "'\(filename)' (Base)"
    case .language(let language):
      return "'\(filename)' (\(language))"
    }
  }
}

private struct StringValues {
  let key: String
  let params: [StringParam]
  let tableName: String
  let values: [(Locale, String)]
  let developmentLanguage: String

  var localizedString: String {
    let escapedKey = key.escapedStringLiteral

    var valueArgument: String = ""
    if let value = primaryLanguageValue {
      valueArgument = ", value: \"\(value.escapedStringLiteral)\""
    }

    if tableName == "Localizable" {
      return "NSLocalizedString(\"\(escapedKey)\", bundle: R.hostingBundle\(valueArgument), comment: \"\")"
    }
    else {
      return "NSLocalizedString(\"\(escapedKey)\", tableName: \"\(tableName)\", bundle: R.hostingBundle\(valueArgument), comment: \"\")"
    }
  }

  private var primaryLanguageValues:  [(Locale, String)] {
    return values.filter { $0.0.isBase } + values.filter { $0.0.language == developmentLanguage }
  }

  private var primaryLanguageValue: String? {
    return primaryLanguageValues.map { $0.1 }.first
  }

  var comments: [String] {
    var results: [String] = []

    let anyNone = values.contains { $0.0.isNone }
    let vs = primaryLanguageValues + values

    if let (locale, value) = vs.first {
      if let localeDescription = locale.localeDescription {
        let str = "\(localeDescription) translation: \(value)".commentString
        results.append(str)
      }
      else {
        let str = "Value: \(value)".commentString
        results.append(str)
      }
    }

    if !anyNone {
      if !results.isEmpty {
        results.append("")
      }

      let locales = values.compactMap { $0.0.localeDescription }
      results.append("Locales: \(locales.joined(separator: ", "))")
    }

    return results
  }
}
