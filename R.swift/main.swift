//
//  main.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 11-12-14.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

do {
  let callInformation = try CallInformation(processInfo: NSProcessInfo.processInfo())

  let resourceURLs = try resourceURLsInXcodeproj(callInformation.xcodeprojPath, forTarget: callInformation.targetName, pathResolver: pathResolverWithSourceTreeToPathConverter(callInformation.pathFromSourceTreeFolder))
  print("\(resourceURLs)")

  let resources = Resources(resourceURLs: resourceURLs, fileManager: NSFileManager.defaultManager())

  let (internalStruct, externalStruct) = generateResourceStructsWithResources(resources)

  let fileContents = [
    Header, "",
    Imports, "",
    externalStruct.description, "",
    internalStruct.description, "",
    ReuseIdentifier.description, "",
    NibResourceProtocol.description, "",
    ReusableProtocol.description, "",
    ReuseIdentifierUITableViewExtension.description, "",
    ReuseIdentifierUICollectionViewExtension.description, "",
    NibUIViewControllerExtension.description,
    ].joinWithSeparator("\n")

  // Write file if we have changes
  let outputFolderURL = NSURL(fileURLWithPath: callInformation.outputFolderPath)
  if readResourceFile(outputFolderURL) != fileContents {
    writeResourceFile(fileContents, toFolderURL: outputFolderURL)
  }

} catch let error as InputParsingError {
  fail(error)
}
