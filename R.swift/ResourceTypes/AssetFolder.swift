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

  let name: String
  let imageAssets: [String]

  init(url: NSURL, fileManager: NSFileManager) throws {
    try AssetFolder.throwIfUnsupportedExtension(url.pathExtension)

    name = url.filename!

    // Browse asset directory recursively and list only the assets folders
    var assets = [NSURL]()
    let enumerator = fileManager.enumeratorAtURL(url, includingPropertiesForKeys: nil, options: .SkipsHiddenFiles, errorHandler: nil)
    if let enumerator = enumerator {
      for file in enumerator {
        if let fileURL = file as? NSURL, pathExtension = fileURL.pathExtension where AssetFolder.AssetExtensions.indexOf(pathExtension) != nil {
          assets.append(fileURL)
        }
      }
    }

    imageAssets = assets.map { $0.filename! }
  }
}
