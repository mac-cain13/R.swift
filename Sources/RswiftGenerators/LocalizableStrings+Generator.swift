//
//  LocalizableStrings+Generator.swift
//  
//
//  Created by Tom Lokhorst on 2022-06-24.
//

import Foundation
import RswiftResources

extension LocalizableStrings {
    public static func generateStruct(resources: [LocalizableStrings], developmentLanguage: String, prefix: SwiftIdentifier) -> Struct {
        let structName = SwiftIdentifier(name: "string")
        let qualifiedName = prefix + structName
        let warning: (String) -> Void = { print("warning:", $0) }

        let localized = Dictionary(grouping: resources, by: \.filename)
        let groupedLocalized = localized.grouped(bySwiftIdentifier: \.key)

        groupedLocalized.reportWarningsForDuplicatesAndEmpties(source: "strings file", result: "file", warning: warning)

        let structs = groupedLocalized.uniques
            .compactMap { (filename, resources) -> Struct? in
                generateStruct(
                    filename: filename,
                    resources: resources,
                    developmentLanguage: developmentLanguage,
                    prefix: qualifiedName,
                    warning: warning
                )
            }

        let comments = ["This `\(qualifiedName.value)` struct is generated, and contains static references to \(groupedLocalized.uniques.count) localization tables."]

        return Struct(comments: comments, name: structName) {
            structs
        }
    }

    private static func generateStruct(filename: String, resources: [LocalizableStrings], developmentLanguage: String, prefix: SwiftIdentifier, warning: (String) -> Void) -> Struct? {

        let structName = SwiftIdentifier(name: filename)
        let qualifiedName = prefix + structName

        let strings = computeStringsWithParams(filename: filename, resources: resources, developmentLanguage: developmentLanguage, warning: warning)
        let letbindings = strings.map { $0.generateLetBinding() }

        let comments = ["This `\(qualifiedName.value)` struct is generated, and contains static references to \(letbindings.count) localization keys."]

        return Struct(comments: comments, name: structName) {
            letbindings
        }
    }

    // Ahem, this code is a bit of a mess. It might need cleaning up... ;-)
    private static func computeStringsWithParams(filename: String, resources: [LocalizableStrings], developmentLanguage: String, warning: (String) -> Void) -> [StringWithParams] {

        var allParams: [String: [(LocaleReference, String, [StringParam])]] = [:]
        let primaryLanguage: String
        let primaryKeys: Set<String>?
        let bases = resources.filter { $0.locale.isBase }
        let developments = resources.filter { $0.locale.language == developmentLanguage }

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
        for ls in resources {
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
        for (locale, lss) in Dictionary(grouping: resources, by: \.locale) {
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
        for (locale, lss) in Dictionary(grouping: resources, by: \.locale) {
            let filenameLocale = locale.debugDescription(filename: filename)
            let sourceKeys = primaryKeys ?? Set(allParams.keys)

            let usedKeys = Set(lss.flatMap { $0.dictionary.keys })
            let extra = usedKeys.subtracting(sourceKeys)

            if extra.isEmpty {
                continue
            }

            let paddedKeys = extra.sorted().map { "'\($0)'" }
            let paddedKeysString = paddedKeys.joined(separator: ", ")

            warning("Strings file \(filenameLocale) has extra translations (not in \(primaryLanguage)) for keys: \(paddedKeysString)")
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
                let locales = params.compactMap { $0.0.localeDescription }.joined(separator: ", ")
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
    let developmentLanguage: String

    func generateLetBinding() -> LetBinding {
        LetBinding(
            comments: self.comments,
            name: SwiftIdentifier(name: key),
            valueCodeString: valueCodeString
        )
    }

    private var valueCodeString: String {
        #"\#(typeName)(key: "\#(key.escapedStringLiteral)", tableName: "\#(tableName)", developmentValue: "\#(developmentValue)", locales: \#(values.compactMap(\.0.language))"#
    }

    private var typeName: String {
        "StringResource"
        + (params.isEmpty ? "" : "\(params.count)<\(params.map(\.spec.typeReference.rawName).joined(separator: ", "))>")
    }

    private var developmentValue: String {
        values.first(where: { $0.0.localeDescription == developmentLanguage })?.1 ?? ""
    }

    private var primaryLanguageValues:  [(LocaleReference, String)] {
        return values.filter { $0.0.isBase } + values.filter { $0.0.language == developmentLanguage }
    }

    private var comments: [String] {
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
