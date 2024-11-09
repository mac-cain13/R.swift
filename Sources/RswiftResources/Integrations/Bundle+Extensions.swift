//
//  Bundle+Extensions.swift
//  R.swift
//
//  Created by Tom Lokhorst on 2022-07-30.
//

import Foundation

public protocol PlistPathComponent {
    typealias Key = String
    typealias Index = Int
}

extension PlistPathComponent.Key: PlistPathComponent {}
extension PlistPathComponent.Index: PlistPathComponent {}

extension Bundle {
    
    /// Returns the string associated with the specified path + key in the receiver's information property list.
    public func infoDictionaryString(path: [PlistPathComponent], key: PlistPathComponent.Key? = nil) -> String? {
        var currentObject: Any? = infoDictionary

        for step in path {
            if let currentDict = currentObject as? [String: Any], let key = step as? String {
                // If the current object is a dictionary, move to the next step using the dictionary key
                currentObject = currentDict[key]
            } else if let currentArray = currentObject as? [Any], let index = step as? Int, currentArray.indices.contains(index) {
                // If the current object is an array, and the step is a valid index, move to the array element
                currentObject = currentArray[index]
            } else {
                // If the path leads to an invalid object type or out of bounds index, return nil
                return nil
            }
        }

        // Attempt to extract a string from the final object using the provided key, else if key == nil, assume
        // we have arrived at a string value.
        if let dict = currentObject as? [String: Any], let key = key {
            return dict[key] as? String
        } else if key == nil, let value = currentObject as? String {
            return value
        }
        return nil
    }

    /// Find first bundle and locale for which the table exists
    internal func firstBundleAndLocale(tableName: String, preferredLanguages: [String]) -> (bundle: Foundation.Bundle, locale: Foundation.Locale)? {
        let hostingBundle = self

        // Filter preferredLanguages to localizations, use first locale
        var languages = preferredLanguages
            .map { Foundation.Locale(identifier: $0) }
            .prefix(1)
            .flatMap { locale -> [String] in
                let language: String?
                if #available(macOS 13, iOS 16, tvOS 16, watchOS 9, *) {
                    // Xcode 14 doesn't recognize `Locale.language`, Xcode 14.1 does know `Locale.language`
                    // Xcode 14.1 is first to ship with swift 5.7.1
                    #if swift(>=5.7.1) && !os(Linux)
                    language = locale.language.languageCode?.identifier
                    #else
                    language = locale.languageCode
                    #endif
                } else {
                    language = locale.languageCode
                }
                if hostingBundle.localizations.contains(locale.identifier) {
                    if let language = language, hostingBundle.localizations.contains(language) {
                        return [locale.identifier, language]
                    } else {
                        return [locale.identifier]
                    }
                } else if let language = language, hostingBundle.localizations.contains(language) {
                    return [language]
                } else {
                    return []
                }
            }

        if languages.isEmpty {
            // If there's no languages, use development language as backstop
            if let developmentLocalization = hostingBundle.developmentLocalization {
                languages = [developmentLocalization]
            }
        } else {
            // Insert Base as second item (between locale identifier and languageCode)
            languages.insert("Base", at: 1)

            // Add development language as backstop
            if let developmentLocalization = hostingBundle.developmentLocalization {
                languages.append(developmentLocalization)
            }
        }

        // Find first language for which table exists
        // Note: key might not exist in chosen language (in that case, key will be shown)
        for language in languages {
            if let lproj = hostingBundle.url(forResource: language, withExtension: "lproj"),
               let lbundle = Bundle(url: lproj)
            {
                let strings = lbundle.url(forResource: tableName, withExtension: "strings")
                let stringsdict = lbundle.url(forResource: tableName, withExtension: "stringsdict")

                if strings != nil || stringsdict != nil {
                    return (lbundle, Foundation.Locale(identifier: language))
                }
            }
        }

        // If table is available in main bundle, don't look for localized resources
        let strings = hostingBundle.url(forResource: tableName, withExtension: "strings", subdirectory: nil, localization: nil)
        let stringsdict = hostingBundle.url(forResource: tableName, withExtension: "stringsdict", subdirectory: nil, localization: nil)
        let hostingLocale = hostingBundle.preferredLocalizations.first.flatMap { Foundation.Locale(identifier: $0) }

        if let hostingLocale = hostingLocale, strings != nil || stringsdict != nil {
            return (hostingBundle, hostingLocale)
        }

        // If table is not found for requested languages, key will be shown
        return nil
    }
}
