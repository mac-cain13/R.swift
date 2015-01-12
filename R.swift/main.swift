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

inputDirectories(NSProcessInfo.processInfo())
  .each { directory in
    // Storyboards
    let storyboards = findAllStoryboardURLsInDirectory(url: directory)
      .map { Storyboard(url: $0) }

    let segueStruct = swiftSegueStructWithStoryboards(storyboards)

    let storyboardStructs = storyboards.map(swiftStructForStoryboard)
      .map(indent)
      .reduce("struct storyboard {\n", +) + "}"
    
    let validateAllStoryboardsFunction = storyboards.map(swiftCallStoryboardImageValidation)
      .map(indent)
      .reduce("static func validate() {\n", +) + "}"

    // Asset folders
    let assetFolders = findAllAssetsFolderURLsInDirectory(url: directory)
      .map { AssetFolder(url: $0, fileManager: defaultFileManager) }

    let imageStruct = swiftImageStructWithAssetFolders(assetFolders)

    // Write out the code
    let code = [imageStruct, segueStruct, storyboardStructs, validateAllStoryboardsFunction]
      .reduce("struct R {") { $0 + "\n" + indent(string: $1) } + "}\n"
    writeResourceFile(code, toFolderURL: directory)
  }
