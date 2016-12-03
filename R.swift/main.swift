//
//  main.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 11-12-14.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

let IndentationString = "  "
let ResourceFilename = "R.generated.swift"

var isEdgeEnabled = false

do {
  let callInformation = try CallInformation(processInfo: ProcessInfo())
  isEdgeEnabled = callInformation.edge

  let xcodeproj = try Xcodeproj(url: callInformation.xcodeprojURL)
  let ignoreFile = (try? IgnoreFile(ignoreFileURL: callInformation.rswiftIgnoreURL)) ?? IgnoreFile()

  let resourceURLs = try xcodeproj.resourcePathsForTarget(callInformation.targetName)
    .map(pathResolver(with: callInformation.URLForSourceTreeFolder))
    .flatMap { $0 }
    .filter { !ignoreFile.matches(url: $0) }

  let resources = Resources(resourceURLs: resourceURLs, fileManager: FileManager.default)

  let generators: [StructGenerator] = [
    ImageStructGenerator(assetFolders: resources.assetFolders, images: resources.images),
    ColorStructGenerator(colorPalettes: resources.colors),
    FontStructGenerator(fonts: resources.fonts),
    SegueStructGenerator(storyboards: resources.storyboards),
    StoryboardStructGenerator(storyboards: resources.storyboards),
    NibStructGenerator(nibs: resources.nibs),
    ReuseIdentifierStructGenerator(reusables: resources.reusables),
    ResourceFileStructGenerator(resourceFiles: resources.resourceFiles),
    StringsStructGenerator(localizableStrings: resources.localizableStrings),
  ]

  let aggregatedResult = AggregatedStructGenerator(subgenerators: generators)
    .generatedStructs(at: callInformation.accessLevel)

  let (externalStructWithoutProperties, internalStruct) = ValidatedStructGenerator(validationSubject: aggregatedResult)
    .generatedStructs(at: callInformation.accessLevel)

  let externalStruct = externalStructWithoutProperties.addingInternalProperties(forBundleIdentifier: callInformation.bundleIdentifier)

  let codeConvertibles: [SwiftCodeConverible?] = [
      HeaderPrinter(),
      ImportPrinter(structs: [externalStruct, internalStruct], excludedModules: [Module.custom(name: callInformation.productModuleName)]),
      externalStruct,
      internalStruct
    ]

  let fileContents = codeConvertibles
    .flatMap { $0?.swiftCode }
    .joined(separator: "\n\n")

  // Write file if we have changes
  let currentFileContents = try? String(contentsOf: callInformation.outputURL, encoding: String.Encoding.utf8)
  if currentFileContents != fileContents  {
    do {
      try fileContents.write(to: callInformation.outputURL, atomically: true, encoding: String.Encoding.utf8)
    } catch let error as NSError {
      fail(error.description)
    }
  }

} catch let error as InputParsingError {
  if let errorDescription = error.errorDescription {
    fail(errorDescription)
  }

  print(error.helpString)

  switch error {
  case .illegalOption, .missingOption:
    exit(2)
  case .userAskedForHelp, .userRequestsVersionInformation:
    exit(0)
  }
} catch let error as ResourceParsingError {
  switch error {
  case let .parsingFailed(description):
    fail(description)
  case let .unsupportedExtension(givenExtension, supportedExtensions):
    let joinedSupportedExtensions = supportedExtensions.joined(separator: ", ")
    fail("File extension '\(givenExtension)' is not one of the supported extensions: \(joinedSupportedExtensions)")
  }

  exit(3)
}
