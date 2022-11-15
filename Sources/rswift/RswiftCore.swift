//
//  RswiftCore.swift
//  rswift
//
//  Created by Tom Lokhorst on 2021-04-16.
//

import Foundation
import ArgumentParser
import XcodeEdit
import RswiftParsers
import RswiftResources
import RswiftGenerators

public enum Generator: String, CaseIterable, ExpressibleByArgument {
    case image
    case string
    case color
    case data
    case file
    case font
    case nib
    case segue
    case storyboard
    case reuseIdentifier
    case entitlements
    case info
    case id
}

public enum AccessLevel: String, ExpressibleByArgument {
  case publicLevel = "public"
  case internalLevel = "internal"
  case filePrivate = "fileprivate"
  case privateLevel = "private"
}

public enum BundleSource: String, ExpressibleByArgument {
    case module
    case finder
}

public struct RswiftCore {
    let outputURL: URL
    let generators: [Generator]
    let accessLevel: AccessLevel
    let bundleSource: BundleSource
    let importModules: [String]
    let productModuleName: String?
    let infoPlistFile: URL?
    let codeSignEntitlements: URL?

    let sourceTreeURLs: SourceTreeURLs

    let rswiftIgnoreURL: URL

    public init(
        outputURL: URL,
        generators: [Generator],
        accessLevel: AccessLevel,
        bundleSource: BundleSource,
        importModules: [String],
        productModuleName: String?,
        infoPlistFile: URL?,
        codeSignEntitlements: URL?,
        rswiftIgnoreURL: URL,
        sourceTreeURLs: SourceTreeURLs
    ) {
        self.outputURL = outputURL
        self.generators = generators
        self.accessLevel = accessLevel
        self.bundleSource = bundleSource
        self.importModules = importModules
        self.productModuleName = productModuleName
        self.infoPlistFile = infoPlistFile
        self.codeSignEntitlements = codeSignEntitlements

        self.rswiftIgnoreURL = rswiftIgnoreURL

        self.sourceTreeURLs = sourceTreeURLs
    }

    public func generateFromXcodeproj(url xcodeprojURL: URL, targetName: String) throws {
        let warning: (String) -> Void = { print("warning: [R.swift]", $0) }

        let xcodeproj = try Xcodeproj(url: xcodeprojURL, warning: warning)
        let resources = try ProjectResources.parseXcodeproj(
            xcodeproj: xcodeproj,
            targetName: targetName,
            rswiftIgnoreURL: rswiftIgnoreURL,
            infoPlistFile: infoPlistFile,
            codeSignEntitlements: codeSignEntitlements,
            sourceTreeURLs: sourceTreeURLs,
            parseFontsAsFiles: true,
            parseImagesAsFiles: true,
            warning: warning
        )

        try generateFromProjectResources(resources: resources, developmentRegion: xcodeproj.developmentRegion, knownAssetTags: xcodeproj.knownAssetTags)
    }

    public func generateFromFiles(inputFileURLs urls: [URL]) throws {
        let warning: (String) -> Void = { print("warning: [R.swift]", $0) }

        let resources = try ProjectResources.parseURLs(
            urls: urls,
            infoPlists: [],
            codeSignEntitlements: [],
            parseFontsAsFiles: true,
            parseImagesAsFiles: true,
            warning: warning
        )

        try generateFromProjectResources(resources: resources, developmentRegion: nil, knownAssetTags: nil)
    }

    private func generateFromProjectResources(resources: ProjectResources, developmentRegion: String?, knownAssetTags: [String]?) throws {
        let structName = SwiftIdentifier(rawValue: "_R")
        let qualifiedName = structName

        let segueStruct = Segue.generateStruct(
            storyboards: resources.storyboards,
            prefix: qualifiedName
        )

        let imageStruct = ImageResource.generateStruct(
            catalogs: resources.assetCatalogs,
            toplevel: resources.images,
            prefix: qualifiedName
        )
        let colorStruct = ColorResource.generateStruct(
            catalogs: resources.assetCatalogs,
            prefix: qualifiedName
        )
        let dataStruct = DataResource.generateStruct(
            catalogs: resources.assetCatalogs,
            prefix: qualifiedName
        )

        let fileStruct = FileResource.generateStruct(
            resources: resources.files,
            prefix: qualifiedName
        )

        let idStruct = AccessibilityIdentifier.generateStruct(
            nibs: resources.nibs,
            storyboards: resources.storyboards,
            prefix: qualifiedName
        )

        let fontStruct = FontResource.generateStruct(
            resources: resources.fonts,
            prefix: qualifiedName
        )

        let storyboardStruct = StoryboardResource.generateStruct(
            storyboards: resources.storyboards,
            prefix: qualifiedName
        )

        let infoStruct = PropertyListResource.generateInfoStruct(
            resourceName: "info",
            plists: resources.infoPlists,
            prefix: qualifiedName
        )

        let entitlementsStruct = PropertyListResource.generateStruct(
            resourceName: "entitlements",
            plists: resources.codeSignEntitlements,
            prefix: qualifiedName
        )

        let nibStruct = NibResource.generateStruct(
            nibs: resources.nibs,
            prefix: qualifiedName
        )

        let reuseIdentifierStruct = Reusable.generateStruct(
            nibs: resources.nibs,
            storyboards: resources.storyboards,
            prefix: qualifiedName
        )

        let stringStruct = LocalizableStrings.generateStruct(
            resources: resources.localizableStrings,
            developmentLanguage: developmentRegion,
            prefix: qualifiedName
        )

        let projectStruct = XcodeProjectGenerator.generateProject(developmentRegion: developmentRegion, knownAssetTags: knownAssetTags)

        let generateString = generators.contains(.string) && !stringStruct.isEmpty
        let generateData = generators.contains(.data) && !dataStruct.isEmpty
        let generateColor = generators.contains(.color) && !colorStruct.isEmpty
        let generateImage = generators.contains(.image) && !imageStruct.isEmpty
        let generateInfo = generators.contains(.info) && !infoStruct.isEmpty
        let generateEntitlements = generators.contains(.entitlements) && !entitlementsStruct.isEmpty
        let generateFont = generators.contains(.font) && !fontStruct.isEmpty
        let generateFile = generators.contains(.file) && !fileStruct.isEmpty
        let generateSegue = generators.contains(.segue) && !segueStruct.isEmpty
        let generateId = generators.contains(.id) && !idStruct.isEmpty
        let generateNib = generators.contains(.nib) && !nibStruct.isEmpty
        let generateReuseIdentifier = generators.contains(.reuseIdentifier) && !reuseIdentifierStruct.isEmpty
        let generateStoryboard = generators.contains(.storyboard) && !storyboardStruct.isEmpty

        let validateLines = [
            generateFont ? "try self.font.validate()" : "",
            generateNib ? "try self.nib.validate()" : "",
            generateStoryboard ? "try self.storyboard.validate()" : "",
        ]
        .filter { $0 != "" }
        .joined(separator: "\n")

        let validate = Function(
            comments: [],
            name: SwiftIdentifier(name: "validate"),
            params: [],
            returnThrows: true,
            returnType: .init(module: .stdLib, rawName: "Void"),
            valueCodeString: validateLines
        )

        var s = Struct(name: structName, additionalModuleReferences: [.rswiftResources]) {
            Init.bundle

            if !projectStruct.isEmpty {
                projectStruct
            }

            if generateString {
                stringStruct.generateBundleVarGetter(name: "string")
                stringStruct.generateBundleFunction(name: "string")
                stringStruct
            }

            if generateData {
                dataStruct.generateBundleVarGetter(name: "data")
                dataStruct.generateBundleFunction(name: "data")
                dataStruct
            }

            if generateColor {
                colorStruct.generateBundleVarGetter(name: "color")
                colorStruct.generateBundleFunction(name: "color")
                colorStruct
            }

            if generateImage {
                imageStruct.generateBundleVarGetter(name: "image")
                imageStruct.generateBundleFunction(name: "image")
                imageStruct
            }

            if generateInfo {
                infoStruct.generateBundleVarGetter(name: "info")
                infoStruct.generateBundleFunction(name: "info")
                infoStruct
            }

            if generateEntitlements {
                entitlementsStruct.generateLetBinding()
                entitlementsStruct
            }

            if generateFont {
                fontStruct.generateBundleVarGetter(name: "font")
                fontStruct.generateBundleFunction(name: "font")
                fontStruct
            }

            if generateFile {
                fileStruct.generateBundleVarGetter(name: "file")
                fileStruct.generateBundleFunction(name: "file")
                fileStruct
            }

            if generateSegue {
                segueStruct.generateLetBinding()
                segueStruct
            }

            if generateId {
                idStruct.generateLetBinding()
                idStruct
            }

            if generateNib {
                nibStruct.generateBundleVarGetter(name: "nib")
                nibStruct.generateBundleFunction(name: "nib")
                nibStruct
            }

            if generateReuseIdentifier {
                reuseIdentifierStruct.generateLetBinding()
                reuseIdentifierStruct
            }

            if generateStoryboard {
                storyboardStruct.generateBundleVarGetter(name: "storyboard")
                storyboardStruct.generateBundleFunction(name: "storyboard")
                storyboardStruct
            }

            validate
        }

        if accessLevel == .publicLevel {
            s.setAccessControl(.public)
        }

        let imports = Set(s.allModuleReferences.compactMap(\.name))
            .union(importModules)
            .subtracting([productModuleName].compactMap { $0 })
            .sorted()
            .map { "import \($0)" }
            .joined(separator: "\n")

        let mainLet: String
        switch bundleSource {
        case .module:
            mainLet = "\(accessLevel == .publicLevel ? "public " : "")let R = _R(bundle: Bundle.module)"
        case .finder:
            mainLet = """
                private class BundleFinder {}
                \(accessLevel == .publicLevel ? "public " : "")let R = _R(bundle: Bundle(for: BundleFinder.self))
                """
        }

        let str = s.prettyPrint()
        let code = """
        //
        // This is a generated file, do not edit!
        // Generated by R.swift, see https://github.com/mac-cain13/R.swift
        //

        \(imports)

        \(mainLet)

        \(str)
        """

        try writeIfChanged(contents: code, toURL: outputURL)
    }
}

private func writeIfChanged(contents: String, toURL outputURL: URL) throws {
    let currentFileContents = try? String(contentsOf: outputURL, encoding: .utf8)
    guard currentFileContents != contents else { return }
    try contents.write(to: outputURL, atomically: true, encoding: .utf8)
}
