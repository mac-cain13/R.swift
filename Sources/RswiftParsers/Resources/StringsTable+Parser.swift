//
//  LocalizableStrings.swift
//  R.swift
//
//  Created by Tom Lokhorst on 2016-04-24.
//

import Foundation
import RswiftResources

extension StringsTable: SupportedExtensions {
    static public let supportedExtensions: Set<String> = ["strings", "stringsdict", "xcstrings"]

    static public func parse(url: URL) throws -> StringsTable {
        if url.pathExtension == "xcstrings" {
            return try parseStringCatalog(url: url)
        } else {
            return try parseStringsFileOrStringsDict(url: url)
        }
    }
}

private func parseStringCatalog(url: URL) throws -> StringsTable {
    guard let basename = url.filenameWithoutExtension else {
        throw ResourceParsingError("Couldn't extract filename from URL: \(url)")
    }
    let data = try Data(contentsOf: url)
    let decoder = JSONDecoder()
    let stringCatalog = try decoder.decode(StringCatalog.self, from: data)
    let locale = LocaleReference.language(stringCatalog.sourceLanguage)
    let source = locale.debugDescription(filename: "\(basename).xcstrings")
    let dictionary = try parseStrings(strings: stringCatalog.strings, source: source)
    return StringsTable(filename: basename, locale: locale, dictionary: dictionary)
}

private func parseStrings(
    strings: [StringCatalog.Key : StringCatalog.Translation],
    source: String
) throws -> [StringsTable.Key: StringsTable.Value] {
    var dictionary: [StringsTable.Key: StringsTable.Value] = [:]
    for (key, translation) in strings {
        for (_, localization) in translation.localizations {
            if let stringUnit = localization.stringUnit {
                dictionary[key] = try parseStringUnit(key: key, val: stringUnit.value, source: source)
            } else if let variations = localization.variations {
                if let plural = variations.plural {
                    dictionary[key] = try parseStringVariations(key: key, variations: plural, source: source)
                }
                if let device = variations.device {
                    dictionary[key] = try parseStringVariations(key: key, variations: device, source: source)
                }
            }
        }
    }
    return dictionary
}

private func parseStringVariations(
    key: String,
    variations: [String : StringCatalog.Localization],
    source: String
) throws -> StringsTable.Value {
    let stringValues = variations.values.compactMap(\.stringUnit).map(\.value).sorted()
    guard let stringValue = stringValues.first else {
        throw ResourceParsingError("No variations given for string \(key) from \(source)")
    }
    let result = try parseStringUnit(key: key, val: stringValue, source: source)

    for stringValue in stringValues {
        let other = try parseStringUnit(key: key, val: stringValue, source: source)
        if other.params != result.params {
            throw ResourceParsingError("Parameters don't match in variations for string \(key) from \(source)")
        }
    }

    return result
}

private func parseStringsFileOrStringsDict(url: URL) throws -> StringsTable {
    guard let basename = url.filenameWithoutExtension else {
        throw ResourceParsingError("Couldn't extract filename from URL: \(url)")
    }

    // Get locale from url (second to last component)
    let locale = LocaleReference(url: url)

    // Check to make sure url can be parsed as a dictionary
    let nsDictionary = try NSDictionary(contentsOf: url, error: ())

    // Parse dicts from NSDictionary
    let dictionary: [StringsTable.Key: StringsTable.Value]
    switch url.pathExtension {
    case "strings":
        dictionary = try parseStrings(nsDictionary, source: locale.debugDescription(filename: "\(basename).strings"))
    case "stringsdict":
        let warning: (String) -> Void = { print("warning: [R.swift]", $0) }
        dictionary = try parseStringsdict(nsDictionary, source: locale.debugDescription(filename: "\(basename).stringsdict"), warning: warning)
    default:
        throw ResourceParsingError("File could not be parsed as a strings file: \(url.absoluteString)")
    }

    return StringsTable(filename: basename, locale: locale, dictionary: dictionary)
}

private func parseStrings(_ nsDictionary: NSDictionary, source: String) throws -> [StringsTable.Key: StringsTable.Value] {
    var dictionary: [StringsTable.Key: StringsTable.Value] = [:]

    for (key, obj) in nsDictionary {
        if let
            key = key as? String,
           let val = obj as? String
        {
            dictionary[key] = try parseStringUnit(key: key, val: val, source: source)
        }
        else {
            throw ResourceParsingError("Non-string value in \(source): \(key) = \(obj)")
        }
    }

    return dictionary
}

private func parseStringUnit(key: String, val: String, source: String) throws -> StringsTable.Value {
    var params: [StringParam] = []

    for part in FormatPart.formatParts(formatString: val) {
        switch part {
        case .reference:
            throw ResourceParsingError("Non-specifier reference in \(source): \(key) = \(val)")

        case .spec(let formatSpecifier):
            params.append(StringParam(name: nil, spec: formatSpecifier))
        }
    }
    return StringsTable.Value(params: params, originalValue: val)
}

private func parseStringsdict(_ nsDictionary: NSDictionary, source: String, warning: (String) -> Void) throws -> [StringsTable.Key: StringsTable.Value] {
    var dictionary: [StringsTable.Key: StringsTable.Value] = [:]

    for (key, obj) in nsDictionary {
        if let
            key = key as? String,
           let dict = obj as? [String: AnyObject]
        {
            guard let localizedFormat = dict["NSStringLocalizedFormatKey"] as? String else {
                continue
            }

            do {
                let params = try parseStringsdictParams(localizedFormat, dict: dict)
                dictionary[key] = .init(params: params, originalValue: localizedFormat)
            } catch let error as ResourceParsingError {
                warning("\(error.description) in '\(key)' \(source)")
            }
        }
        else {
            throw ResourceParsingError("Non-dict value in \(source): \(key) = \(obj)")
        }
    }

    return dictionary
}

private func parseStringsdictParams(_ format: String, dict: [String: AnyObject]) throws -> [StringParam] {
    var params: [StringParam] = []

    let parts = FormatPart.formatParts(formatString: format)
    for part in parts {
        switch part {
        case .reference(let reference):
            params += try lookup(key: reference, in: dict)

        case .spec(let formatSpecifier):
            params.append(StringParam(name: nil, spec: formatSpecifier))
        }
    }

    return params
}

private func lookup(key: String, in dict: [String: AnyObject], processedReferences: [String] = []) throws -> [StringParam] {
    var processedReferences = processedReferences

    if processedReferences.contains(key) {
        throw ResourceParsingError("Cyclic reference '\(key)'")
    }

    processedReferences.append(key)

    guard let obj = dict[key], let nested = obj as? [String: AnyObject] else {
        throw ResourceParsingError("Missing reference '\(key)'")
    }

    guard let formatSpecType = nested["NSStringFormatSpecTypeKey"] as? String,
          let formatValueType = nested["NSStringFormatValueTypeKey"] as? String
            , formatSpecType == "NSStringPluralRuleType"
    else {
        throw ResourceParsingError("Incorrect reference '\(key)'")
    }
    guard let formatSpecifier = FormatSpecifier(formatString: formatValueType)
    else {
        throw ResourceParsingError("Incorrect reference format specifier \"\(formatValueType)\" for '\(key)'")
    }

    var results = [StringParam(name: nil, spec: formatSpecifier)]

    let stringValues = nested.values.compactMap { $0 as? String }.sorted()

    for stringValue in stringValues {
        var alternative: [StringParam] = []
        let parts = FormatPart.formatParts(formatString: stringValue)
        for part in parts {
            switch part {
            case .reference(let reference):
                alternative += try lookup(key: reference, in: dict, processedReferences: processedReferences)

            case .spec(let formatSpecifier):
                alternative.append(StringParam(name: key, spec: formatSpecifier))
            }
        }

        if let unified = results.unify(alternative) {
            results = unified
        }
        else {
            throw ResourceParsingError("Can't unify '\(key)'")
        }
    }

    return results
}
