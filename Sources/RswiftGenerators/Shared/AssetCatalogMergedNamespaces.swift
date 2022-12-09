//
//  AssetCatalogMergedNamespaces.swift
//  R.swift
//
//  Created by Tom Lokhorst on 2017-06-06.
//

import Foundation
import RswiftResources

struct AssetCatalogMergedNamespaces {
    var namespaces: [SwiftIdentifier: AssetCatalog.Namespace] = [:]
    var duplicates: [(SwiftIdentifier, String)] = []

    init(all: [String: AssetCatalog.Namespace], otherIdentifiers: [SwiftIdentifier]) {
        for (name, namespace) in all {
            let id = SwiftIdentifier(name: name)
            if otherIdentifiers.contains(id) {
                duplicates.append((id, name))
            } else {
                namespaces[id, default: .init()].merge(namespace)
            }
        }
    }

    func printWarningsForDuplicates(result: String, warning: (String) -> Void) {
        for (identifier, name) in duplicates {
            warning("Skipping asset namespace '\(name)' because symbol '\(identifier.value)' would conflict with \(result): \(identifier.value)")
        }
    }
}
