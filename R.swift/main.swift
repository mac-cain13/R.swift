//
//  main.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 11-12-14.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

let defaultFileManager = NSFileManager.defaultManager()
let findAllAssetsFolderURLsInDirectory = filterDirectoryContentsRecursively(defaultFileManager) { $0.isDirectory && $0.absoluteString!.pathExtension == "xcassets" }
let findAllStoryboardURLsInDirectory = filterDirectoryContentsRecursively(defaultFileManager) { !$0.isDirectory && $0.absoluteString!.pathExtension == "storyboard" }

inputDirectories(NSProcessInfo.processInfo()).each { directory in
  // Storyboards
  let storyboards = findAllStoryboardURLsInDirectory(url: directory)
    .map { Storyboard(url: $0) }
  let storyboardStructs = storyboards.map(swiftStructForStoryboard)
  let validateAllStoryboardsFunction = storyboards.map(swiftCallStoryboardImageValidation)
    .reduce("  static func validateStoryboardImages() {\n", +) + "  }\n"

  // Asset folders
  let imageAssetStructs = findAllAssetsFolderURLsInDirectory(url: directory)
    .map { AssetFolder(url: $0, fileManager: defaultFileManager) }
    .map(swiftStructForAssetFolder)

  // Write out the code
  let code = (storyboardStructs + imageAssetStructs + [validateAllStoryboardsFunction])
    .reduce("struct R {\n") { $0 + "\n" + $1 } + "}\n"
  writeResourceFile(code, toFolderURL: directory)
}
