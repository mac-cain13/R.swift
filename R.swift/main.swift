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
let findAllNibURLsInDirectory = filterDirectoryContentsRecursively(defaultFileManager) { !$0.isDirectory && $0.absoluteString!.pathExtension == "xib" }
let findAllStoryboardURLsInDirectory = filterDirectoryContentsRecursively(defaultFileManager) { !$0.isDirectory && $0.absoluteString!.pathExtension == "storyboard" }

inputDirectories(NSProcessInfo.processInfo())
  .each { directory in
    // Imports
    let imports = swiftImports()

    // Asset folders
    let assetFolders = findAllAssetsFolderURLsInDirectory(url: directory)
      .map { AssetFolder(url: $0, fileManager: defaultFileManager) }

    let imageStruct = swiftImageStructWithAssetFolders(assetFolders)
    
    // Storyboards
    let storyboards = findAllStoryboardURLsInDirectory(url: directory)
      .map { Storyboard(url: $0) }

    let segueStruct = swiftSegueStructWithStoryboards(storyboards)

    let storyboardStructs = storyboards.map(swiftStructForStoryboard)
      .map(indent)
      .reduce("struct storyboard {\n", +) + "}"
    
    let validateAllStoryboardsFunction = storyboards.map(swiftCallStoryboardValidators)
      .map(indent)
      .reduce("static func validate() {\n", +) + "}"

    // Nibs
    let nibStructs = findAllNibURLsInDirectory(url: directory)
      .map { Nib(url: $0) }
      .map(swiftStructForNib)
      .map(indent)
      .reduce("struct nib {\n", +) + "}"

    // Write out the code
    let code = [imageStruct, segueStruct, storyboardStructs, validateAllStoryboardsFunction, nibStructs]
      .reduce("\(imports)\n\nstruct R {") { $0 + "\n" + indent(string: $1) } + "}\n"
    writeResourceFile(code, toFolderURL: directory)
  }
