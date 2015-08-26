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
let findAllAssetsFolderURLsInDirectory = filterDirectoryContentsRecursively(defaultFileManager) { $0.isDirectory && ($0.absoluteString as NSString).pathExtension == "xcassets" }
let findAllNibURLsInDirectory = filterDirectoryContentsRecursively(defaultFileManager) { !$0.isDirectory && ($0.absoluteString as NSString).pathExtension == "xib" }
let findAllStoryboardURLsInDirectory = filterDirectoryContentsRecursively(defaultFileManager) { !$0.isDirectory && ($0.absoluteString as NSString).pathExtension == "storyboard" }

inputDirectories(NSProcessInfo.processInfo())
  .forEach { directory in

    var error: NSError?
    directory.checkResourceIsReachableAndReturnError(&error)
    if let error = error {
      fail(error)
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

    let fonts = Font(url: directory, fileManager: defaultFileManager)

    // Generate resource file contents
    let storyboardStructAndFunction = storyboardStructAndFunctionFromStoryboards(storyboards)

    let nibStructs = nibStructFromNibs(nibs)

    let resourceStruct = Struct(
      type: Type(name: "R"),
      lets: [],
      vars: [],
      functions: [
        storyboardStructAndFunction.1,
      ],
      structs: [
        imageStructFromAssetFolders(assetFolders),
        fontStructFromFonts(fonts),
        segueStructFromStoryboards(storyboards),
        storyboardStructAndFunction.0,
        nibStructs.extern,
        reuseIdentifierStructFromReusables(reusables),
      ]
    )

    let internalResourceStruct = Struct(
      type: Type(name: "_R"),
      implements: [],
      lets: [],
      vars: [],
      functions: [],
      structs: [
        nibStructs.intern
      ]
    )

    let fileContents = [
      Header, "",
      Imports, "",
      resourceStruct.description, "",
      internalResourceStruct.description, "",
      ReuseIdentifier.description, "",
      NibResourceProtocol.description, "",
      ReusableProtocol.description, "",
      ReuseIdentifierUITableViewExtension.description, "",
      ReuseIdentifierUICollectionViewExtension.description, "",
      NibUIViewControllerExtension.description,
    ].joinWithSeparator("\n")

    // Write file if we have changes
    if readResourceFile(directory) != fileContents {
      writeResourceFile(fileContents, toFolderURL: directory)
    }
  }
