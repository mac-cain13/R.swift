//
//  RswiftCore.swift
//  R.swift
//
//  Created by Tom Lokhorst on 2017-04-22.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation
import XcodeEdit

public struct RswiftCore {

  static public func run(_ callInformation: CallInformation) throws {
    do {
      let xcodeproj = try Xcodeproj(url: callInformation.xcodeprojURL)
      let ignoreFile = (try? IgnoreFile(ignoreFileURL: callInformation.rswiftIgnoreURL)) ?? IgnoreFile()

      let resourceURLs = try xcodeproj.resourcePathsForTarget(callInformation.targetName)
        .map { path in path.url(with: callInformation.urlForSourceTreeFolder) }
        .compactMap { $0 }
        .filter { !ignoreFile.matches(url: $0) }

      let resources = Resources(resourceURLs: resourceURLs, fileManager: FileManager.default)

      let generators: [StructGenerator] = [
        ImageStructGenerator(assetFolders: resources.assetFolders, images: resources.images),
        ColorStructGenerator(assetFolders: resources.assetFolders),
        FontStructGenerator(fonts: resources.fonts),
        SegueStructGenerator(storyboards: resources.storyboards),
        StoryboardStructGenerator(storyboards: resources.storyboards),
        NibStructGenerator(nibs: resources.nibs),
        ReuseIdentifierStructGenerator(reusables: resources.reusables),
        ResourceFileStructGenerator(resourceFiles: resources.resourceFiles),
        StringsStructGenerator(localizableStrings: resources.localizableStrings),
        AccessibilityIdentifierStructGenerator(nibs: resources.nibs, storyboards: resources.storyboards)
      ]

      let aggregatedResult = AggregatedStructGenerator(subgenerators: generators)
        .generatedStructs(at: callInformation.accessLevel, prefix: "")

      let (externalStructWithoutProperties, internalStruct) = ValidatedStructGenerator(validationSubject: aggregatedResult)
        .generatedStructs(at: callInformation.accessLevel, prefix: "")

      let externalStruct = externalStructWithoutProperties.addingInternalProperties(forBundleIdentifier: callInformation.bundleIdentifier)

      let codeConvertibles: [SwiftCodeConverible?] = [
          HeaderPrinter(),
          ImportPrinter(
            modules: callInformation.imports,
            extractFrom: [externalStruct, internalStruct],
            exclude: [Module.custom(name: callInformation.productModuleName)]
          ),
          externalStruct,
          internalStruct
        ]

      let fileContents = codeConvertibles
        .compactMap { $0?.swiftCode }
        .joined(separator: "\n\n")
        + "\n" // Newline at end of file

      // Write file if we have changes
      let currentFileContents = try? String(contentsOf: callInformation.outputURL, encoding: .utf8)
      if currentFileContents != fileContents  {
        do {
          try fileContents.write(to: callInformation.outputURL, atomically: true, encoding: .utf8)
        } catch {
          fail(error.localizedDescription)
        }
      }

    } catch let error as ResourceParsingError {
      switch error {
      case let .parsingFailed(description):
        fail(description)

      case let .unsupportedExtension(givenExtension, supportedExtensions):
        let joinedSupportedExtensions = supportedExtensions.joined(separator: ", ")
        fail("File extension '\(String(describing: givenExtension))' is not one of the supported extensions: \(joinedSupportedExtensions)")
      }

      exit(EXIT_FAILURE)
    }
  }
}
