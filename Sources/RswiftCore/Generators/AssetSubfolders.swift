//
//  AssetSubfolders.swift
//  Spectre
//
//  Created by Tom Lokhorst on 2017-06-06.
//

import Foundation

struct AssetSubfolders {
  let folders: [NamespacedAssetSubfolder]
  let duplicates: [NamespacedAssetSubfolder]

  init(all subfolders: [NamespacedAssetSubfolder], assetIdentifiers: [SwiftIdentifier]) {
    var dict: [SwiftIdentifier: NamespacedAssetSubfolder] = [:]

    for subfolder in subfolders {
      let name = SwiftIdentifier(name: subfolder.name)
      if let duplicate = dict[name] {
        duplicate.subfolders += subfolder.subfolders
        duplicate.imageAssets += subfolder.imageAssets
      } else {
        dict[name] = subfolder
      }
    }

    self.folders = dict.values.filter { !assetIdentifiers.contains(SwiftIdentifier(name: $0.name)) }
    self.duplicates = dict.values.filter { assetIdentifiers.contains(SwiftIdentifier(name: $0.name)) }
  }

  func printWarningsForDuplicates() {
    for subfolder in duplicates {
      warn("Skipping asset subfolder because symbol '\(subfolder.name)' would conflict with image: \(subfolder.name)")
    }
  }
}

