//
//  Bundle+Extensions.swift
//  R.swift
//
//  Created by Tom Lokhorst on 2022-07-30.
//

import Foundation

extension Bundle {

    /// Returns the string associated with the specified path + key in the receiver's information property list.
    public func infoDictionaryString(path: [String], key: String) -> String? {
        var dict = infoDictionary
        for step in path {
            guard let obj = dict?[step] as? [String: Any] else { return nil }
            dict = obj
        }
        return dict?[key] as? String
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
                    language = locale.language.languageCode?.identifier
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
