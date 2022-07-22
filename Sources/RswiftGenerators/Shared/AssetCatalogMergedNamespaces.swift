//
//  AssetCatalogMergedNamespaces.swift
//  R.swift
//
//  Created by Tom Lokhorst on 2017-06-06.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation
import RswiftResources

struct AssetCatalogMergedNamespaces {
    let namespaces: [AssetCatalog.Namespace]
    let duplicates: [(SwiftIdentifier, String)]

    init(all namespaces: [AssetCatalog.Namespace], otherIdentifiers: [SwiftIdentifier]) {
        var dict: [SwiftIdentifier: AssetCatalog.Namespace] = [:]

        for namespace in namespaces {
            let id = SwiftIdentifier(name: namespace.name)
            dict[id] = dict[id]?.merging(namespace) ?? namespace
        }

        self.namespaces = dict.compactMap { (id, ns) in !otherIdentifiers.contains(id) ? ns : nil }
        self.duplicates = dict.compactMap { (id, ns) in otherIdentifiers.contains(id) ? (id, ns.name) : nil }
    }

    func printWarningsForDuplicates(result: String, warning: (String) -> Void) {
        for (name, identifier) in duplicates {
            warning("Skipping asset namespace '\(name)' because symbol '\(identifier)' would conflict with \(result): \(identifier)")
        }
    }
}

