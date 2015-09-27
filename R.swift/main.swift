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

  let xcodeproj = try Xcodeproj(url: callInformation.xcodeprojURL)
  let resourceURLs = try xcodeproj.resourceURLsForTarget(callInformation.targetName, pathResolver: pathResolverWithSourceTreeToPathConverter(callInformation.pathFromSourceTreeFolder))

  let resources = Resources(resourceURLs: resourceURLs, fileManager: NSFileManager.defaultManager())

  let (internalStruct, externalStruct) = generateResourceStructsWithResources(resources)

  let fileContents = [
    Header,
    Imports,
    externalStruct.description,
    internalStruct.description,
    ReuseIdentifier.description,
    NibResourceProtocol.description,
    ReusableProtocol.description,
    ReuseIdentifierUITableViewExtension.description,
    ReuseIdentifierUICollectionViewExtension.description,
    NibUIViewControllerExtension.description,
    ].joinWithSeparator("\n\n")

  // Write file if we have changes
  if readResourceFile(callInformation.outputURL) != fileContents {
    writeResourceFile(fileContents, toFileURL: callInformation.outputURL)
  }

} catch let InputParsingError.UserAskedForHelp(helpString: helpString) {
  print(helpString)
  exit(1)
} catch let InputParsingError.IllegalOption(helpString: helpString) {
  fail("Illegal option given.")
  print(helpString)
  exit(2)
} catch let InputParsingError.MissingOption(helpString: helpString) {
  fail("Not all mandatory option given.")
  print(helpString)
  exit(2)
} catch let ResourceParsingError.ParsingFailed(description) {
  fail(description)
  exit(3)
}
