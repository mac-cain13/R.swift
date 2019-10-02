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

public typealias RswiftGenerator = Generator
public enum Generator: String, CaseIterable {
  case image
  case color
  case font
  case segue
  case storyboard
  case nib
  case reuseIdentifier
  case file
  case string
  case id
}

public struct RswiftCore {
  private let callInformation: CallInformation

  public init(_ callInformation: CallInformation) {
    self.callInformation = callInformation
  }

  public func run() throws {
    do {
      let xcodeproj = try Xcodeproj(url: callInformation.xcodeprojURL)
      let ignoreFile = (try? IgnoreFile(ignoreFileURL: callInformation.rswiftIgnoreURL)) ?? IgnoreFile()

      let resourceURLs = try xcodeproj.resourcePathsForTarget(callInformation.targetName)
        .map { path in path.url(with: callInformation.urlForSourceTreeFolder) }
        .compactMap { $0 }
        .filter { !ignoreFile.matches(url: $0) }

      let resources = Resources(resourceURLs: resourceURLs, fileManager: FileManager.default)

      var structGenerators: [StructGenerator] = []
      if callInformation.generators.contains(.image) {
        structGenerators.append(ImageStructGenerator(assetFolders: resources.assetFolders, images: resources.images))
      }
      if callInformation.generators.contains(.color) {
        structGenerators.append(ColorStructGenerator(assetFolders: resources.assetFolders))
      }
      if callInformation.generators.contains(.font) {
        structGenerators.append(FontStructGenerator(fonts: resources.fonts))
      }
      if callInformation.generators.contains(.segue) {
        structGenerators.append(SegueStructGenerator(storyboards: resources.storyboards))
      }
      if callInformation.generators.contains(.storyboard) {
        structGenerators.append(StoryboardStructGenerator(storyboards: resources.storyboards))
      }
      if callInformation.generators.contains(.nib) {
        structGenerators.append(NibStructGenerator(nibs: resources.nibs))
      }
      if callInformation.generators.contains(.reuseIdentifier) {
        structGenerators.append(ReuseIdentifierStructGenerator(reusables: resources.reusables))
      }
      if callInformation.generators.contains(.file) {
        structGenerators.append(ResourceFileStructGenerator(resourceFiles: resources.resourceFiles))
      }
      if callInformation.generators.contains(.string) {
        structGenerators.append(StringsStructGenerator(localizableStrings: resources.localizableStrings, developmentLanguage: xcodeproj.developmentLanguage))
      }
      if callInformation.generators.contains(.id) {
        structGenerators.append(AccessibilityIdentifierStructGenerator(nibs: resources.nibs, storyboards: resources.storyboards))
      }

      // Generate regular R file
      let fileContents = generateRegularFileContents(resources: resources, generators: structGenerators)
      writeIfChanged(contents: fileContents, toURL: callInformation.outputURL)

      // Generate UITest R file
      if let uiTestOutputURL = callInformation.uiTestOutputURL {
        let uiTestFileContents = generateUITestFileContents(resources: resources, generators: [
          AccessibilityIdentifierStructGenerator(nibs: resources.nibs, storyboards: resources.storyboards)
        ])
        writeIfChanged(contents: uiTestFileContents, toURL: uiTestOutputURL)
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

  private func generateRegularFileContents(resources: Resources, generators: [StructGenerator]) -> String {
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

    return codeConvertibles
      .compactMap { $0?.swiftCode }
      .joined(separator: "\n\n")
      + "\n" // Newline at end of file
  }

  private func generateUITestFileContents(resources: Resources, generators: [StructGenerator]) -> String {
    let (externalStruct, _) =  AggregatedStructGenerator(subgenerators: generators)
      .generatedStructs(at: callInformation.accessLevel, prefix: "")

    let codeConvertibles: [SwiftCodeConverible?] = [
      HeaderPrinter(),
      externalStruct
    ]

    return codeConvertibles
      .compactMap { $0?.swiftCode }
      .joined(separator: "\n\n")
      + "\n" // Newline at end of file
  }
}

private func writeIfChanged(contents: String, toURL outputURL: URL) {
  let currentFileContents = try? String(contentsOf: outputURL, encoding: .utf8)
  guard currentFileContents != contents else { return }
  do {
    try contents.write(to: outputURL, atomically: true, encoding: .utf8)
  } catch {
    fail(error.localizedDescription)
  }
}
