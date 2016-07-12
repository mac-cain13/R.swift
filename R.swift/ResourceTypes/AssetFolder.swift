//
//  AssetFolder.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 09-12-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import Foundation

struct AssetFolder: WhiteListedExtensionsResourceType {
  static let supportedExtensions: Set<String> = ["xcassets"]

  // Note: "appiconset" is not loadable by default, so it's not included here
  private static let AssetExtensions: Set<String> = ["launchimage", "imageset", "imagestack"]
  // Ignore everything in folders with these extensions
  private static let IgnoredExtensions: Set<String> = ["brandassets", "imagestacklayer"]

  let name: String
  let imageAssets: [String]

  init(url: URL, fileManager: FileManager) throws {
    try AssetFolder.throwIfUnsupportedExtension(url.pathExtension)

    name = url.filename!

    // Browse asset directory recursively and list only the assets folders
    var assets = [URL]()
    let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: nil, options: .skipsHiddenFiles, errorHandler: nil)
    if let enumerator = enumerator {
      for case let fileURL as URL in enumerator {
        if let pathExtension = fileURL.pathExtension {
          if AssetFolder.AssetExtensions.contains(pathExtension) {
            assets.append(fileURL)
          }
          if AssetFolder.IgnoredExtensions.contains(pathExtension) {
            enumerator.skipDescendants()
          }
        }
      }
    }

    imageAssets = assets.map { $0.filename! }
  }
}
