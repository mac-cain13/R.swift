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

inputDirectories(NSProcessInfo.processInfo()).each { directory in
  let code = findAllAssetsFolderURLsInDirectory(url: directory)
    .map { AssetFolder(url: $0, fileManager: defaultFileManager) }
    .map(swiftStructForAssetFolder)
    .reduce("struct R {\n", +) + "}\n"

  writeResourceFile(code, toFolderURL: directory)
}
