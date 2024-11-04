//
//  StringsTable+Generator.swift
//  
//
//  Created by Tom Lokhorst on 2022-06-24.
//

import Foundation
import RswiftResources


extension Struct {
    public func generateBundleVarGetterForString() -> VarGetter {
        VarGetter(
            deploymentTarget: deploymentTarget,
            name: name,
            typeReference: TypeReference(module: .host, rawName: name.value),
            valueCodeString: ".init(bundle: bundle, preferredLanguages: nil, locale: nil)"
        )
    }

    public func generateBundleFunctionForString(name: String) -> Function {
        Function(
            comments: [],
            deploymentTarget: deploymentTarget,
            name: SwiftIdentifier(name: name),
            params: [.init(name: "bundle", localName: nil, typeReference: .bundle, defaultValue: nil)],
            returnType: TypeReference(module: .host, rawName: self.name.value),
            valueCodeString: ".init(bundle: bundle, preferredLanguages: nil, locale: nil)"
        )
    }

    public func generateLocaleFunctionForString(name: String) -> Function {
        Function(
            comments: [],
            deploymentTarget: deploymentTarget,
            name: SwiftIdentifier(name: name),
            params: [.init(name: "locale", localName: nil, typeReference: .locale, defaultValue: nil)],
            returnType: TypeReference(module: .host, rawName: self.name.value),
            valueCodeString: ".init(bundle: bundle, preferredLanguages: nil, locale: locale)"
        )
    }

    public func generatePreferredLanguagesFunctionForString(name: String) -> Function {
        Function(
            comments: [],
            deploymentTarget: deploymentTarget,
            name: SwiftIdentifier(name: name),
            params: [
                .init(name: "preferredLanguages", localName: nil, typeReference: .init(module: .stdLib, rawName: "[String]"), defaultValue: nil),
                .init(name: "locale", localName: nil, typeReference: .init(module: .stdLib, rawName: "Locale?"), defaultValue: "nil")
            ],
            returnType: TypeReference(module: .host, rawName: self.name.value),
            valueCodeString: ".init(bundle: bundle, preferredLanguages: preferredLanguages, locale: locale)"
        )
    }
}

extension StringsTable {

    public static func generateStruct(tables: [StringsTable], developmentLanguage: String?, prefix: SwiftIdentifier) -> Struct {
        let structName = SwiftIdentifier(name: "string", lowercaseStartingCharacters: false)
        let qualifiedName = prefix + structName
        let warning: (String) -> Void = { print("warning: [R.swift]", $0) }

        let localized = Dictionary(grouping: tables, by: \.filename)
        let groupedLocalized = localized.grouped(bySwiftIdentifier: \.key)

        groupedLocalized.reportWarningsForDuplicatesAndEmpties(source: "strings file", result: "file", warning: warning)

        let structs = groupedLocalized.uniques
            .compactMap { (filename, tables) -> Struct? in
                generateStruct(
                    filename: filename,
                    tables: tables,
                    developmentLanguage: developmentLanguage,
                    prefix: qualifiedName,
                    warning: warning
                )
            }

        let comments = ["This `\(qualifiedName.value)` struct is generated, and contains static references to \(groupedLocalized.uniques.count) localization tables."]

        return Struct(comments: comments, name: structName, additionalModuleReferences: [.rswiftResources]) {
            initBundlePreferredLanguages

            for name in groupedLocalized.uniques.map(\.0) {
                generateBundleLocaleVarGetter(name: SwiftIdentifier(name: name), tableName: name)
//                generateBundleLocaleFunction(name: SwiftIdentifier(name: name))
                generatePreferredLanguagesFunction(name: SwiftIdentifier(name: name), tableName: name)
            }
            structs
        }
    }

    private static var initBundlePreferredLanguages: Init {
        Init(
            comments: [],
            params: [
                .init(name: "bundle", localName: nil, typeReference: .bundle, defaultValue: nil),
                .init(name: "preferredLanguages", localName: nil, typeReference: .init(module: .stdLib, rawName: "[String]?"), defaultValue: "nil"),
                .init(name: "locale", localName: nil, typeReference: .init(module: .stdLib, rawName: "Locale?"), defaultValue: "nil"),
            ],
            valueCodeString: """
                self.bundle = bundle
                self.preferredLanguages = preferredLanguages
                self.locale = locale
                """
        )
    }

    private static func generateStruct(filename: String, tables: [StringsTable], developmentLanguage: String?, prefix: SwiftIdentifier, warning: (String) -> Void) -> Struct? {

        let structName = SwiftIdentifier(name: filename)
        let qualifiedName = prefix + structName

        let strings = computeStringsWithParams(filename: filename, tables: tables, developmentLanguage: developmentLanguage, warning: warning)
        let vargetters = strings.map { $0.generateVarGetter() }

        // only functions with named parameters
        let functions = strings
            .filter { $0.params.contains { $0.name != nil } }
            .flatMap { [$0.generateFunctionBlank(), $0.generateFunctionPreferredLanguages()] }

        let comments = ["This `\(qualifiedName.value)` struct is generated, and contains static references to \(vargetters.count) localization keys."]

        return Struct(comments: comments, name: structName) {
            initStringSource
            vargetters
            functions
        }
    }

    private static var initStringSource: Init {
        Init(
            comments: [],
            params: [
                .init(name: "source", localName: nil, typeReference: .init(module: .rswiftResources, rawName: "StringResource.Source"), defaultValue: nil),
            ],
            valueCodeString: """
                self.source = source
                """
        )
    }

    public static func generateBundleLocaleVarGetter(name: SwiftIdentifier, tableName: String) -> VarGetter {
        VarGetter(
            name: name,
            typeReference: TypeReference(module: .host, rawName: name.value),
            valueCodeString: #".init(source: .init(bundle: bundle, tableName: "\#(tableName.escapedStringLiteral)", preferredLanguages: preferredLanguages, locale: locale))"#
        )
    }

    public static func generateBundleLocaleFunction(name: SwiftIdentifier) -> Function {
        Function(
            comments: [],
            name: name,
            params: [
                .init(name: "bundle", localName: nil, typeReference: .bundle, defaultValue: nil),
                .init(name: "locale", localName: nil, typeReference: .locale, defaultValue: nil),
            ],
            returnType: TypeReference(module: .host, rawName: name.value),
            valueCodeString: ".init(source: .selected(bundle, locale))"
        )
    }

    public static func generatePreferredLanguagesFunction(name: SwiftIdentifier, tableName: String) -> Function {
        Function(
            comments: [],
            name: name,
            params: [
                .init(name: "preferredLanguages", localName: nil, typeReference: TypeReference(module: .stdLib, rawName: "[String]"), defaultValue: nil),
            ],
            returnType: TypeReference(module: .host, rawName: name.value),
            valueCodeString: #".init(source: .init(bundle: bundle, tableName: "\#(tableName.escapedStringLiteral)", preferredLanguages: preferredLanguages, locale: locale))"#
        )
    }

    // Ahem, this code is a bit of a mess. It might need cleaning up... ;-)
    private static func computeStringsWithParams(filename: String, tables: [StringsTable], developmentLanguage: String?, warning: (String) -> Void) -> [StringWithParams] {

        var allParams: [String: [(LocaleReference, String, [StringParam])]] = [:]
        let primaryLanguage: String?
        let primaryKeys: Set<String>?
        let bases = tables.filter { $0.locale.isBase }
        let developments = tables.filter { $0.locale.localeDescription == developmentLanguage }

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
        for ls in tables {
            let filenameLocale = ls.locale.debugDescription(filename: filename)
            let groupedKeys = ls.dictionary.keys.grouped(bySwiftIdentifier: { $0 })

            groupedKeys.reportWarningsForDuplicatesAndEmpties(source: "string", container: "in \(filenameLocale)", result: "key", warning: warning)

            // Save uniques
            for key in groupedKeys.uniques {
                if let value = ls.dictionary[key] {
                    if let _ = allParams[key] {
                        allParams[key]?.append((ls.locale, value.originalValue, value.params))
                    }
                    else {
                        allParams[key] = [(ls.locale, value.originalValue, value.params)]
                    }
                }
            }
        }

        // Warnings about missing translations
        for (locale, lss) in Dictionary(grouping: tables, by: \.locale) {
            let filenameLocale = locale.debugDescription(filename: filename)
            let sourceKeys = primaryKeys ?? Set(allParams.keys)

            let missing = sourceKeys.subtracting(lss.flatMap { $0.dictionary.keys })

            if missing.isEmpty {
                continue
            }

            let paddedKeys = missing.sorted().map { "'\($0)'" }
            let paddedKeysString = paddedKeys.joined(separator: ", ")

            warning("Strings file \(filenameLocale) is missing translations for keys: \(paddedKeysString)")
        }

        // Warnings about extra translations
        for (locale, lss) in Dictionary(grouping: tables, by: \.locale) {
            let filenameLocale = locale.debugDescription(filename: filename)
            let sourceKeys = primaryKeys ?? Set(allParams.keys)

            let usedKeys = Set(lss.flatMap { $0.dictionary.keys })
            let extra = usedKeys.subtracting(sourceKeys)

            if extra.isEmpty {
                continue
            }

            let paddedKeys = extra.sorted().map { "'\($0)'" }
            let paddedKeysString = paddedKeys.joined(separator: ", ")

            if let primaryLanguage {
                warning("Strings file \(filenameLocale) has extra translations (not in \(primaryLanguage)) for keys: \(paddedKeysString)")
            } else {
                warning("Strings file \(filenameLocale) has extra translations for keys: \(paddedKeysString)")
            }
        }

        // Only include translation if it exists in the primary language
        func includeTranslation(_ key: String) -> Bool {
            if let primaryKeys = primaryKeys {
                return primaryKeys.contains(key)
            }

            return true
        }

        var results: [StringWithParams] = []
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
                    let name = locale.debugDescription(filename: filename)
                    warning("Skipping string \(key) in \(name), not all format specifiers are consecutive")

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
            let values = StringWithParams(key: key, params: params, tableName: filename, values: vals, developmentLanguage: developmentLanguage)
            results.append(values)
        }

        for badKey in badFormatSpecifiersKeys.sorted() {
            let fewParams = allParams.filter { $0.0 == badKey }.map { $0.1 }

            if let params = fewParams.first {
                let locales = params.compactMap { $0.0.localeDescription }.sorted().joined(separator: ", ")
                warning("Skipping string for key \(badKey) (\(filename)), format specifiers don't match for all locales: \(locales)")
            }
        }

        return results
    }

}

private struct StringWithParams {
    let key: String
    let params: [StringParam]
    let tableName: String
    let values: [(LocaleReference, String)]
    let developmentLanguage: String?

    func generateFunctionBlank() -> Function {
        let parameters: [Function.Parameter] = zip(params.indices, params).map { (ix, p) in
                .init(name: p.name ?? "_", localName: "value\(ix + 1)", typeReference: p.spec.typeReference, defaultValue: nil)
            }
        let arguments = parameters.map { $0.localName ?? $0.name }.joined(separator: ", ")
        return Function(
            comments: self.comments,
            name: SwiftIdentifier(name: key),
            params: parameters,
            returnType: .string,
            valueCodeString: "String(format: \(SwiftIdentifier(name: key).value), \(arguments))"
        )
    }

    func generateFunctionPreferredLanguages() -> Function {
        let parameters: [Function.Parameter] = zip(params.indices, params).map { (ix, p) in
                .init(name: p.name ?? "_", localName: "value\(ix + 1)", typeReference: p.spec.typeReference, defaultValue: nil)
            }
        let languages: Function.Parameter = .init(name: "preferredLanguages", localName: nil, typeReference: TypeReference(module: .stdLib, rawName: "[String]"), defaultValue: nil)
        let arguments = parameters.map { $0.localName ?? $0.name }.joined(separator: ", ")
        return Function(
            comments: self.comments,
            deprecated: "Use R.string(preferredLanguages:).*.* instead",
            name: SwiftIdentifier(name: key),
            params: parameters + [languages],
            returnType: .string,
            valueCodeString: "String(format: \(SwiftIdentifier(name: key).value), preferredLanguages: preferredLanguages, \(arguments))"
        )
    }

    func generateVarGetter() -> VarGetter {
        let developmentLanguageValue = values.filter { $0.0.localeDescription == developmentLanguage }.first?.1
        let developmentValue = developmentLanguageValue.map { "\"\($0.escapedStringLiteral)\"" } ?? "nil"

        let typeReference = TypeReference(module: .rswiftResources, name: "StringResource\(params.isEmpty ? "" : "\(params.count)")", genericArgs: params.map(\.spec.typeReference))

        let varValueCodeString = #".init(key: "\#(key.escapedStringLiteral)", tableName: "\#(tableName)", source: source, developmentValue: \#(developmentValue), comment: nil)"#

        return VarGetter(
            comments: self.comments,
            name: SwiftIdentifier(name: key),
            typeReference: typeReference,
            valueCodeString: varValueCodeString
        )
    }

    private var primaryLanguageValues: [(LocaleReference, String)] {
        values.filter { $0.0.isBase } + values.filter { $0.0.localeDescription == developmentLanguage }
    }

    private var comments: [String] {
        var results: [String] = []

        let anyNone = values.contains { $0.0.isNone }
        let vs = primaryLanguageValues + values

        // Value
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

        // Key
        if !results.isEmpty {
            results.append("")
        }
        results.append("Key: \(key)".commentString)

        // Locales
        if !anyNone {
            if !results.isEmpty {
                results.append("")
            }

            let locales = values.compactMap { $0.0.localeDescription }
            results.append("Locales: \(locales.sorted().joined(separator: ", "))")
        }

        return results
    }
}
