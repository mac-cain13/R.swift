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

  static public func install(xcodeprojURL: URL, targetNames: [String]) throws {
    let xcodeproj = try loadXcodeproj(url: xcodeprojURL)
    let projectFile = xcodeproj.projectFile

    let generatedGuids = newGuids()

    for target in projectFile.project.targets.flatMap({ $0.value }) {

      guard
        targetNames.contains(target.name),
        !target.contains(filename: "R.generated.swift")
      else { continue }

      let shellScript = "\"$PODS_ROOT/R.swift/rswift\" generate \"$SRCROOT/TESTTEST\""
      let fields: [String: Any] = [
        "isa": "PBXShellScriptBuildPhase",
        "files": [],
        "name": "Run R.swift",
        "runOnlyForDeploymentPostprocessing": 0,
        "shellPath": "/bin/sh",
        "inputPaths": [],
        "outputPaths": [],
        "shellScript": shellScript,
        "buildActionMask": 0x7FFFFFFF]
      let guid = generatedGuids.next()!
      let scriptBuildPhase = try! projectFile.makeObject(type: PBXShellScriptBuildPhase.self, id: guid, fields: fields)
      let reference: Reference<PBXBuildPhase> = projectFile.addReference(value: scriptBuildPhase)
      target.addBuildPhase(reference)
    }

    try projectFile.write(to: xcodeprojURL)
  }

  static public func run(_ callInformation: CallInformation) throws {
    let xcodeproj = try loadXcodeproj(url: callInformation.xcodeprojURL)
    let ignoreFile = (try? IgnoreFile(ignoreFileURL: callInformation.rswiftIgnoreURL)) ?? IgnoreFile()

    let resourceURLs = try xcodeproj.resourcePathsForTarget(callInformation.targetName)
      .map { path in path.url(with: callInformation.urlForSourceTreeFolder) }
      .flatMap { $0 }
      .filter { !ignoreFile.matches(url: $0) }

    let resources = Resources(resourceURLs: resourceURLs, fileManager: FileManager.default)

    var generators: [StructGenerator] = [
      ImageStructGenerator(assetFolders: resources.assetFolders, images: resources.images),
      ColorStructGenerator(assetFolders: resources.assetFolders),
      FontStructGenerator(fonts: resources.fonts),
      SegueStructGenerator(storyboards: resources.storyboards),
      StoryboardStructGenerator(storyboards: resources.storyboards),
      NibStructGenerator(nibs: resources.nibs),
      ReuseIdentifierStructGenerator(reusables: resources.reusables),
      ResourceFileStructGenerator(resourceFiles: resources.resourceFiles),
      StringsStructGenerator(localizableStrings: resources.localizableStrings),
    ]

    do {
      let colorPaletteGenerator = ColorPaletteStructGenerator(palettes: resources.colors)
      let colorPaletteGeneratorStruct = colorPaletteGenerator.generatedStructs(at: callInformation.accessLevel, prefix: "")
      if !colorPaletteGeneratorStruct.externalStruct.isEmpty {
        generators.append(colorPaletteGenerator)
      }
    }

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
      .flatMap { $0?.swiftCode }
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
  }

  static func loadXcodeproj(url: URL) throws -> Xcodeproj {
    do {
      return try Xcodeproj(url: url)
    }
    catch let error as ResourceParsingError {
      switch error {
      case let .parsingFailed(description):
        fail(description)

      case let .unsupportedExtension(givenExtension, supportedExtensions):
        let joinedSupportedExtensions = supportedExtensions.joined(separator: ", ")
        fail("File extension '\(String(describing: givenExtension))' is not one of the supported extensions: \(joinedSupportedExtensions)")
      }

      exit(3)
    }
  }
}

extension PBXNativeTarget {
  func contains(filename: String) -> Bool {
    for resourcesBuildPhase in buildPhases.flatMap({ $0.value }) {
      let files = resourcesBuildPhase.files.flatMap { $0.value }
      for file in files {
        if let fileReference = file.fileRef?.value as? PBXFileReference {
          if fileReference.name == filename {
            return true
          }
        }
      }
    }

    return false
  }
}

func newGuids() -> AnyIterator<Guid> {
  var x = 0

  return AnyIterator() { () -> Guid in
    defer { x += 1}
    return Guid(String(format: "CAFECAFE%016X", x))
  }
}
