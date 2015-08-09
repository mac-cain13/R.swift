//
//  main.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 11-12-14.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation
import Darwin

let defaultFileManager = NSFileManager.defaultManager()
let findAllAssetsFolderURLsInDirectory = filterDirectoryContentsRecursively(defaultFileManager) { $0.isDirectory && ($0.absoluteString as NSString).pathExtension == "xcassets" }
let findAllNibURLsInDirectory = filterDirectoryContentsRecursively(defaultFileManager) { !$0.isDirectory && ($0.absoluteString as NSString).pathExtension == "xib" }
let findAllStoryboardURLsInDirectory = filterDirectoryContentsRecursively(defaultFileManager) { !$0.isDirectory && ($0.absoluteString as NSString).pathExtension == "storyboard" }

let processInfo = NSProcessInfo.processInfo()
let inputDirectory = verifyFileURL(argumentDirectory(processInfo, atIndex: 1))

// Get/parse all resources into our domain objects
let assetFolders = findAllAssetsFolderURLsInDirectory(url: inputDirectory)
    .map { AssetFolder(url: $0, fileManager: defaultFileManager) }

let storyboards = findAllStoryboardURLsInDirectory(url: inputDirectory)
    .map { Storyboard(url: $0) }

let nibs = findAllNibURLsInDirectory(url: inputDirectory)
    .map { Nib(url: $0) }

let reusables = (nibs.map { $0 as ReusableContainer } + storyboards.map { $0 as ReusableContainer })
    .flatMap { $0.reusables }

// Generate resource file contents
let resourceStruct = Struct(
    type: Type(name: "R"),
    lets: [],
    vars: [],
    functions: [
        validateAllFunctionWithStoryboards(storyboards),
    ],
    structs: [
        imageStructFromAssetFolders(assetFolders),
        segueStructFromStoryboards(storyboards),
        storyboardStructFromStoryboards(storyboards),
        nibStructFromNibs(nibs),
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
        internalNibStructFromNibs(nibs)
    ]
)

let fileContents = "\n".join([
    Header, "",
    Imports, "",
    resourceStruct.description, "",
    internalResourceStruct.description, "",
    ReuseIdentifier.description, "",
    NibResourceProtocol.description, "",
    ReusableProtocol.description, "",
    ReuseIdentifierUITableViewExtension.description, "",
    ReuseIdentifierUICollectionViewExtension.description, "",
    NibUIViewControllerExtension.description
    ])

// Write file if we have changes
let outputDirectory: NSURL
if let secondDirectory = argumentDirectory(processInfo, atIndex: 2) {
    outputDirectory = verifyFileURL(secondDirectory)
}
else {
    outputDirectory = inputDirectory
}

if readResourceFile(outputDirectory) != fileContents {
    writeResourceFile(fileContents, toFolderURL: outputDirectory)
}