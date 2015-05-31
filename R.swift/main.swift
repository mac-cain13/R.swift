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

    var error: NSError?
    if !directory.checkResourceIsReachableAndReturnError(&error) {
      failOnError(error)
      return
    }

    // Get/parse all resources into our domain objects
    let assetFolders = findAllAssetsFolderURLsInDirectory(url: directory)
      .map { AssetFolder(url: $0, fileManager: defaultFileManager) }

    let storyboards = findAllStoryboardURLsInDirectory(url: directory)
      .map { Storyboard(url: $0) }

    let nibs = findAllNibURLsInDirectory(url: directory)
      .map { Nib(url: $0) }

    let reusables = (nibs.map { $0 as ReusableContainer } + storyboards.map { $0 as ReusableContainer })
      .flatMap { $0.reusables }

    // Generate
    let structs = [
      imageStructFromAssetFolders(assetFolders),
      segueStructFromStoryboards(storyboards),
      storyboardStructFromStoryboards(storyboards),
      nibStructFromNibs(nibs),
      reuseIdentifierStructFromReusables(reusables),
    ]

    let functions = [
      validateAllFunctionWithStoryboards(storyboards),
    ]

    // Generate resource file contents
    let resourceStruct = Struct(
      type: Type(name: "R"),
      lets: [],
      vars: [],
      functions: functions,
      structs: structs
    )
    let fileContents = join("\n", [
      Header, "",
      Imports, "",
      resourceStruct.description, "",
      ReuseIdentifier.description, "",
      ReuseIdentifierUITableViewExtension.description, "",
      ReuseIdentifierUICollectionViewExtension.description,
    ])

    // Write file if we have changes
    if readResourceFile(directory) != fileContents {
      writeResourceFile(fileContents, toFolderURL: directory)
    }
  }
