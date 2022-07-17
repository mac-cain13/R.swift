//
//  AssetCatalogSubfolders.swift
//  R.swift
//
//  Created by Tom Lokhorst on 2017-06-06.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation
import RswiftResources

struct AssetCatalogSubfolders {
    let folders: [AssetCatalog.Namespace]
    let duplicates: [AssetCatalog.Namespace]

    init(all subfolders: [AssetCatalog.Namespace], assetIdentifiers: [SwiftIdentifier]) {
        var dict: [SwiftIdentifier: AssetCatalog.Namespace] = [:]

        for subfolder in subfolders {
            let name = SwiftIdentifier(name: subfolder.name)
            dict[name] = dict[name]?.merging(subfolder) ?? subfolder
        }

        self.folders = dict.values.filter { !assetIdentifiers.contains(SwiftIdentifier(name: $0.name)) }
        self.duplicates = dict.values.filter { assetIdentifiers.contains(SwiftIdentifier(name: $0.name)) }
    }

    func printWarningsForDuplicates(warning: (String) -> Void) {
        for subfolder in duplicates {
            warning("Skipping asset subfolder because symbol '\(subfolder.name)' would conflict with image: \(subfolder.name)")
        }
    }
}

