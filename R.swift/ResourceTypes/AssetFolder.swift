//
//  AssetFolder.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 09-12-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
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

    guard let filename = url.filename else {
      throw ResourceParsingError.parsingFailed("Couldn't extract filename from URL: \(url)")
    }
    name = filename

    // Browse asset directory recursively and list only the assets folders
    var assets = [URL]()
    let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: nil, options: .skipsHiddenFiles, errorHandler: nil)
    if let enumerator = enumerator {
      for case let fileURL as URL in enumerator {
        let pathExtension = fileURL.pathExtension
        if AssetFolder.AssetExtensions.contains(pathExtension) {
          assets.append(fileURL)
        }
        if AssetFolder.IgnoredExtensions.contains(pathExtension) {
          enumerator.skipDescendants()
        }
      }
    }

    imageAssets = assets.map { $0.filename! }
  }
}
