//
//  Bundle+Extensions.swift
//  
//
//  Created by Tom Lokhorst on 2022-07-30.
//

import Foundation

extension Bundle {
    public var firstPreferredLocale: Foundation.Locale {
        self.preferredLocalizations.first.flatMap { Foundation.Locale(identifier: $0) } ?? Foundation.Locale.current
    }

    /// Find first bundle and locale for which the table exists
    public func firstBundleAndLocale(tableName: String, preferredLanguages: [String]) -> (bundle: Foundation.Bundle, locale: Foundation.Locale)? {
        let hostingBundle = self

        // Filter preferredLanguages to localizations, use first locale
        var languages = preferredLanguages
            .map { Foundation.Locale(identifier: $0) }
            .prefix(1)
            .flatMap { locale -> [String] in
                if hostingBundle.localizations.contains(locale.identifier) {
                    if let language = locale.languageCode, hostingBundle.localizations.contains(language) {
                        return [locale.identifier, language]
                    } else {
                        return [locale.identifier]
                    }
                } else if let language = locale.languageCode, hostingBundle.localizations.contains(language) {
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

        if strings != nil || stringsdict != nil {
            return (hostingBundle, hostingBundle.firstPreferredLocale)
        }

        // If table is not found for requested languages, key will be shown
        return nil
    }
}
