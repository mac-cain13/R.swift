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
  private let callInformation: CallInformation

  public init(_ callInformation: CallInformation) {
    self.callInformation = callInformation
  }

  public func run() throws {
    do {
      let xcodeproj = try Xcodeproj(url: callInformation.xcodeprojURL)
      let ignoreFile = (try? IgnoreFile(ignoreFileURL: callInformation.rswiftIgnoreURL)) ?? IgnoreFile()

      let buildConfigurations = try xcodeproj.buildConfigurations(forTarget: callInformation.targetName)
      let infoPlists = buildConfigurations.compactMap {
        return loadPropertyList(name: $0.name, path: $0.infoPlistPath, callInformation: callInformation)
      }
      let entitlements = buildConfigurations.compactMap {
        return loadPropertyList(name: $0.name, path: $0.entitlementsPath, callInformation: callInformation)
      }

      let resourceURLs = try xcodeproj.resourcePaths(forTarget: callInformation.targetName)
        .map { path in path.url(with: callInformation.urlForSourceTreeFolder) }
        .compactMap { $0 }
        .filter { !ignoreFile.matches(url: $0) }

      let resources = Resources(resourceURLs: resourceURLs, fileManager: FileManager.default)
      let infoPlistWhitelist = ["UIApplicationShortcutItems", "UISceneConfigurations", "NSUserActivityTypes", "NSExtension"]

      // Generate regular R file
      let fileContents = generateRegularFileContents(resources: resources, generators: [
        PropertyListGenerator(name: "info", plists: infoPlists, toplevelKeysWhitelist: infoPlistWhitelist),
        PropertyListGenerator(name: "entitlements", plists: entitlements, toplevelKeysWhitelist: nil),
        ImageStructGenerator(assetFolders: resources.assetFolders, images: resources.images),
        ColorStructGenerator(assetFolders: resources.assetFolders),
        FontStructGenerator(fonts: resources.fonts),
        SegueStructGenerator(storyboards: resources.storyboards),
        StoryboardStructGenerator(storyboards: resources.storyboards),
        NibStructGenerator(nibs: resources.nibs),
        ReuseIdentifierStructGenerator(reusables: resources.reusables),
        ResourceFileStructGenerator(resourceFiles: resources.resourceFiles),
        StringsStructGenerator(localizableStrings: resources.localizableStrings, developmentLanguage: xcodeproj.developmentLanguage),
        AccessibilityIdentifierStructGenerator(nibs: resources.nibs, storyboards: resources.storyboards),
      ])
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

private func loadPropertyList(name: String, path: Path?, callInformation: CallInformation) -> PropertyList? {
  guard let path = path else { return nil }
  do {
    let url = path.url(with: callInformation.urlForSourceTreeFolder)
    return try PropertyList(buildConfigurationName: name, url: url)
  } catch let ResourceParsingError.parsingFailed(humanReadableError) {
    warn(humanReadableError)
    return nil
  }
  catch {
    return nil
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
