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

  func generatedStruct(at externalAccessLevel: AccessLevel, prefix: SwiftIdentifier, bundle: BundleExpression) -> Struct {
    let structName: SwiftIdentifier = "string"
    let qualifiedName = prefix + structName
    let localized = localizableStrings.grouped(by: { $0.filename })
    let groupedLocalized = localized.grouped(bySwiftIdentifier: { $0.0 })

    groupedLocalized.printWarningsForDuplicatesAndEmpties(source: "strings file", result: "file")

    let structs = groupedLocalized.uniques.compactMap { arg -> Struct? in
      let (key, value) = arg
      return stringStructFromLocalizableStrings(filename: key, strings: value, at: externalAccessLevel, prefix: qualifiedName, bundle: bundle)
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

  private func stringStructFromLocalizableStrings(filename: String, strings: [LocalizableStrings], at externalAccessLevel: AccessLevel, prefix: SwiftIdentifier, bundle: BundleExpression) -> Struct? {

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
      properties: params.map { stringLet(values: $0, at: externalAccessLevel, bundle: bundle) },
      functions: params.map { stringFunction(values: $0, at: externalAccessLevel, bundle: bundle) },
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

  private func stringLet(values: StringValues, at externalAccessLevel: AccessLevel, bundle: BundleExpression) -> Let {
    let escapedKey = values.key.escapedStringLiteral
    let locales = values.values
      .map { $0.0 }
      .compactMap { $0.localeDescription }
      .map { "\"\($0)\"" }
      .joined(separator: ", ")

    return Let(
      comments: values.comments,
      accessModifier: externalAccessLevel,
      isStatic: true,
      name: SwiftIdentifier(name: values.key),
      typeDefinition: .inferred(Type.StringResource),
      value: "Rswift.StringResource(key: \"\(escapedKey)\", tableName: \"\(values.tableName)\", bundle: \(bundle), locales: [\(locales)], comment: nil)"
    )
  }

  private func stringFunction(values: StringValues, at externalAccessLevel: AccessLevel, bundle: BundleExpression) -> Function {
    if values.params.isEmpty {
      return stringFunctionNoParams(for: values, at: externalAccessLevel, bundle: bundle)
    }
    else {
      return stringFunctionParams(for: values, at: externalAccessLevel, bundle: bundle)
    }
  }

  private func stringFunctionNoParams(for values: StringValues, at externalAccessLevel: AccessLevel, bundle: BundleExpression) -> Function {
    
    let body: String
    
    switch bundle {
    case .hostingBundle:
      body = """
        guard let preferredLanguages = preferredLanguages else {
          return \(values.swiftCode(bundle: "\(bundle)"))
        }

        guard let (_, foundBundle) = localeBundle(parentBundle: \(bundle), tableName: "\(values.tableName)", preferredLanguages: preferredLanguages) else {
          return "\(values.key.escapedStringLiteral)"
        }

        return \(values.swiftCode(bundle: "foundBundle"))
        """
    case .customBundle:
      body = """
        guard let bundle = \(bundle) else {
          return "\(values.key.escapedStringLiteral)"
        }

        guard let preferredLanguages = preferredLanguages else {
          return \(values.swiftCode(bundle: "bundle"))
        }

        guard let (_, foundBundle) = localeBundle(parentBundle: bundle, tableName: "\(values.tableName)", preferredLanguages: preferredLanguages) else {
          return "\(values.key.escapedStringLiteral)"
        }

        return \(values.swiftCode(bundle: "foundBundle"))
        """
    }

    return Function(
      availables: [],
      comments: values.comments,
      accessModifier: externalAccessLevel,
      isStatic: true,
      name: SwiftIdentifier(name: values.key),
      generics: nil,
      parameters: [
        Function.Parameter(
          name: "preferredLanguages",
          type: Type._Array.withGenericArgs([Type._String]).asOptional(),
          defaultValue: "nil"
        )
      ],
      doesThrow: false,
      returnType: Type._String,
      body: body,
      os: []
    )
  }

  private func stringFunctionParams(for values: StringValues, at externalAccessLevel: AccessLevel, bundle: BundleExpression) -> Function {

    var params = values.params.enumerated().map { arg -> Function.Parameter in
      let (ix, param) = arg
      let argumentLabel = param.name ?? "_"
      let valueName = "value\(ix + 1)"

      return Function.Parameter(name: argumentLabel, localName: valueName, type: param.spec.type)
    }

    let args = params.map { $0.localName ?? $0.name }.joined(separator: ", ")

    let prefereredLanguages = Function.Parameter(
      name: "preferredLanguages",
      type: Type._Array.withGenericArgs([Type._String]).asOptional(),
      defaultValue: "nil"
    )
    params.append(prefereredLanguages)
    
    let body: String
    
    switch bundle {
    case .hostingBundle:
      body = """
        guard let preferredLanguages = preferredLanguages else {
          let format = \(values.swiftCode(bundle: "\(bundle)"))
          return String(format: format, locale: applicationLocale, \(args))
        }

        guard let (locale, foundBundle) = localeBundle(parentBundle: \(bundle), tableName: "\(values.tableName)", preferredLanguages: preferredLanguages) else {
          return "\(values.key.escapedStringLiteral)"
        }

        let format = \(values.swiftCode(bundle: "foundBundle"))
        return String(format: format, locale: locale, \(args))
        """
    case .customBundle:
      body = """
        guard let bundle = \(bundle) else {
          return "\(values.key.escapedStringLiteral)"
        }

        guard let preferredLanguages = preferredLanguages else {
          let format = \(values.swiftCode(bundle: "bundle"))
          return String(format: format, locale: applicationLocale, \(args))
        }

        guard let (locale, foundBundle) = localeBundle(parentBundle: bundle, tableName: "\(values.tableName)", preferredLanguages: preferredLanguages) else {
          return "\(values.key.escapedStringLiteral)"
        }

        let format = \(values.swiftCode(bundle: "foundBundle"))
        return String(format: format, locale: locale, \(args))
        """
    }

    return Function(
      availables: [],
      comments: values.comments,
      accessModifier: externalAccessLevel,
      isStatic: true,
      name: SwiftIdentifier(name: values.key),
      generics: nil,
      parameters: params,
      doesThrow: false,
      returnType: Type._String,
      body: body,
      os: []
    )
  }

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

  func swiftCode(bundle: String) -> String {
    let escapedKey = key.escapedStringLiteral

    var valueArgument: String = ""
    if let value = baseLanguageValue {
      valueArgument = ", value: \"\(value.escapedStringLiteral)\""
    }

    if tableName == "Localizable" {
      return "NSLocalizedString(\"\(escapedKey)\", bundle: \(bundle)\(valueArgument), comment: \"\")"
    }
    else {
      return "NSLocalizedString(\"\(escapedKey)\", tableName: \"\(tableName)\", bundle: \(bundle)\(valueArgument), comment: \"\")"
    }
  }

  var baseLanguageValue: String? {
    return values.filter { $0.0.isBase }.map { $0.1 }.first
  }

  private var primaryLanguageValues:  [(Locale, String)] {
    return values.filter { $0.0.isBase } + values.filter { $0.0.language == developmentLanguage }
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
