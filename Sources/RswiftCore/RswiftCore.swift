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
  case string
  case color
  case file
  case font
  case nib
  case segue
  case storyboard
  case reuseIdentifier
  case entitlements
  case info
  case id
  case bundle
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

      let buildConfigurations = try xcodeproj.buildConfigurations(forTarget: callInformation.targetName)
      
      let resourceURLs = try xcodeproj.resourcePaths(forTarget: callInformation.targetName)
        .map { path in path.url(with: callInformation.urlForSourceTreeFolder) }
        .compactMap { $0 }
        .filter { !ignoreFile.matches(url: $0) }

      let resources = Resources(resourceURLs: resourceURLs, fileManager: FileManager.default)
      let infoPlistWhitelist = ["UIApplicationShortcutItems", "UIApplicationSceneManifest", "NSUserActivityTypes", "NSExtension"]

      var structGenerators: [StructGenerator] = makeStructGenerators(availableGenerators: callInformation.generators, resources: resources, developmentLanguage: xcodeproj.developmentLanguage)
      
      if callInformation.generators.contains(.bundle) {
        var bundleInfos: [BundleStructGenerator.BundleInfo] = []
        // Enhance this list after testing:
        let supportedGenerators: [Generator] = [.image, .string, .color, .file]
        let availableGenerators = Array(Set(supportedGenerators).intersection(Set(callInformation.generators)))
        for bundle in resources.bundles {
          let bundleStructGenerators = makeStructGenerators(availableGenerators: availableGenerators, resources: bundle, developmentLanguage: xcodeproj.developmentLanguage)
          let bundleInfo = BundleStructGenerator.BundleInfo(bundle: bundle, structGenerators: bundleStructGenerators)
          bundleInfos.append(bundleInfo)
        }

        structGenerators.append(BundleStructGenerator(bundleInfos: bundleInfos))
      }
      
      if callInformation.generators.contains(.info) {

        let infoPlists = buildConfigurations.compactMap { config in
          return loadPropertyList(name: config.name, url: callInformation.infoPlistFile, callInformation: callInformation)
        }
        
        structGenerators.append(PropertyListGenerator(name: "info", plists: infoPlists, toplevelKeysWhitelist: infoPlistWhitelist))
      }
      if callInformation.generators.contains(.entitlements) {
        
        let entitlements = buildConfigurations.compactMap { config -> PropertyList? in
          guard let codeSignEntitlement = callInformation.codeSignEntitlements else { return nil }
          return loadPropertyList(name: config.name, url: codeSignEntitlement, callInformation: callInformation)
        }
        
        structGenerators.append(PropertyListGenerator(name: "entitlements", plists: entitlements, toplevelKeysWhitelist: nil))
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
  
  func makeStructGenerators(availableGenerators: [Generator], resources: Resources, developmentLanguage: String) -> [StructGenerator] {
    var structGenerators: [StructGenerator] = []
    if availableGenerators.contains(.image) {
      structGenerators.append(ImageStructGenerator(assetFolders: resources.assetFolders, images: resources.images))
    }
    if availableGenerators.contains(.color) {
      structGenerators.append(ColorStructGenerator(assetFolders: resources.assetFolders))
    }
    if availableGenerators.contains(.font) {
      structGenerators.append(FontStructGenerator(fonts: resources.fonts))
    }
    if availableGenerators.contains(.segue) {
      structGenerators.append(SegueStructGenerator(storyboards: resources.storyboards))
    }
    if availableGenerators.contains(.storyboard) {
      structGenerators.append(StoryboardStructGenerator(storyboards: resources.storyboards))
    }
    if availableGenerators.contains(.nib) {
      structGenerators.append(NibStructGenerator(nibs: resources.nibs))
    }
    if availableGenerators.contains(.reuseIdentifier) {
      structGenerators.append(ReuseIdentifierStructGenerator(reusables: resources.reusables))
    }
    if availableGenerators.contains(.file) {
      structGenerators.append(ResourceFileStructGenerator(resourceFiles: resources.resourceFiles))
    }
    if availableGenerators.contains(.string) {
      structGenerators.append(StringsStructGenerator(localizableStrings: resources.localizableStrings, developmentLanguage: developmentLanguage))
    }
    if availableGenerators.contains(.id) {
      structGenerators.append(AccessibilityIdentifierStructGenerator(nibs: resources.nibs, storyboards: resources.storyboards))
    }
    
    return structGenerators
  }

  private func generateRegularFileContents(resources: Resources, generators: [StructGenerator]) -> String {
    let aggregatedResult = AggregatedStructGenerator(subgenerators: generators)
      .generatedStructs(at: callInformation.accessLevel, prefix: "", bundle: .hostingBundle)

    let (externalStructWithoutProperties, internalStruct) = ValidatedStructGenerator(validationSubject: aggregatedResult)
      .generatedStructs(at: callInformation.accessLevel, prefix: "", bundle: .hostingBundle)

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
      .generatedStructs(at: callInformation.accessLevel, prefix: "", bundle: .hostingBundle)

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

private func loadPropertyList(name: String, url: URL, callInformation: CallInformation) -> PropertyList? {
  do {
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
