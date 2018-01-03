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

  public static func generate(_ callInformation: CallInformation) throws {
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

  public static func install(xcodeprojURL: URL, targetNames: [String]) throws {
    let xcodeproj = try loadXcodeproj(url: xcodeprojURL)
    let projectFile = xcodeproj.projectFile

    // Find correct targets
    for target in projectFile.project.targets.flatMap({ $0.value }) {
      guard targetNames.contains(target.name) else { continue }

      guard
        let buildConfiguration = target.buildConfigurationList.value?.defaultConfiguration,
        let infoPlistFile = buildConfiguration.buildSettings["INFOPLIST_FILE"] as? String,
        let directory = URL(string: infoPlistFile)?.deletingLastPathComponent()
      else {
        print("Skipping target `\(target.name)', missing INFOPLIST_FILE build setting")
        continue
      }

      // Install in 3 steps
      try target.addRswiftBuildPhase(directory: directory, projectFile: projectFile)
      let fileReference = try projectFile.addRswiftFileReference(directory: directory)

      if let fileReference = fileReference {
        try target.addRswiftBuildFile(fileReference: fileReference, projectFile: projectFile)
      }
    }

    try projectFile.write(to: xcodeprojURL)

    print("DONE!")
  }

  private static func loadXcodeproj(url: URL) throws -> Xcodeproj {
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

  func addRswiftBuildPhase(directory: URL, projectFile: XCProjectFile) throws {
    if buildPhases.contains(where: { $0.value?.containsRswift ?? false }) {
      print("[!] Skipping target `\(name)', it already contains a R.swift build phase")
      return
    }

    let shellScript = "\"$PODS_ROOT/R.swift/rswift\" generate \"$SRCROOT/\(directory.description)\""
    let scriptBuildPhase = try projectFile.createShellScript(name: "Run R.swift", shellScript: shellScript)
    let reference: Reference<PBXBuildPhase> = projectFile.addReference(value: scriptBuildPhase)

    let index = buildPhases.index(where: { $0.value is PBXSourcesBuildPhase }) ?? 0

    self.insertBuildPhase(reference, at: index)
    print("inserted buildphase")
  }

  func addRswiftBuildFile(fileReference: Reference<PBXFileReference>, projectFile: XCProjectFile) throws {

    guard let sources = buildPhases.flatMap({ $0.value as? PBXSourcesBuildPhase }).first else {
      throw ResourceParsingError.parsingFailed("Missing sources build phase")
    }

    let buildFile = try projectFile.createBuildFile(fileReference: fileReference)
    let reference = projectFile.addReference(value: buildFile)

    sources.insertFile(reference, at: 0)
    print("inserted build file")
  }
}

extension XCProjectFile {
  func addRswiftFileReference(directory: URL) throws -> Reference<PBXFileReference>? {
    guard let mainGroup = project.mainGroup.value else {
      throw ResourceParsingError.parsingFailed("Missing mainGroup")
    }

    let infoPath = Path.relativeTo(.sourceRoot, "/\(directory.appendingPathComponent("Info.plist").description)")
    let path = directory.appendingPathComponent("R.generated.swift")

    let group: PBXGroup
    let sourceTree: SourceTree

    if let (infoRef, container) = find(path: infoPath, reference: mainGroup, group: mainGroup) {
      group = container
      sourceTree = infoRef.sourceTree
    }
    else {
      group = mainGroup
      sourceTree = .group
    }

    if group.children.contains(where: { $0.value?.containsRswift ?? false }) {
      print("[!] Skipping adding file reference, project already has a file")
      return nil
    }

    let fileReference = try self.createFileReference(path: path.description, name: "R.generated.swift", sourceTree: sourceTree)
    let reference: Reference<PBXFileReference> = self.addReference(value: fileReference)

    group.insertFileReference(reference)
    print("inserted file reference")

    return reference
  }

  func find(path: Path, reference: PBXReference, group: PBXGroup) -> (PBXFileReference, PBXGroup)? {
    if let fileRef = reference as? PBXFileReference {
      if let fullPath = fileRef.fullPath, fullPath == path {
        return (fileRef, group)
      }
    }

    if let group = reference as? PBXGroup {
      for child in group.children.flatMap({ $0.value }) {
        if let result = find(path: path, reference: child, group: group) {
          return result
        }
      }
    }

    return nil
  }
}

extension PBXGroup {
  func insertFileReference(_ reference: Reference<PBXFileReference>) {
    let ix = children.index(where: { $0.value?.name ?? $0.value?.path ?? "" > "R.generated.swift" }) ?? children.count

    self.insertFileReference(reference, at: ix)
  }
}

extension PBXBuildPhase {
  var containsRswift: Bool {
    guard let buildPhase = self as? PBXShellScriptBuildPhase else { return false }

    return buildPhase.shellScript.contains("rswift generate") || buildPhase.shellScript.contains("rswift\" generate")
  }
}

extension PBXReference {
  var containsRswift: Bool {
    guard let fileReference = self as? PBXFileReference else { return false }

    return fileReference.name == "R.generated.swift" || (fileReference.path ?? "").hasSuffix("R.generated.swift")
  }
}
