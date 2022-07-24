//
//  RswiftCore.swift
//  rswift
//
//  Created by Tom Lokhorst on 2021-04-16.
//

import Foundation
import XcodeEdit
import RswiftParsers
import RswiftResources
import RswiftGenerators

public struct RswiftCore {
    let xcodeprojURL: URL
    let targetName: String
    let productModuleName: String?
    let infoPlistFile: URL?
    let codeSignEntitlements: URL?

    let builtProductsDirURL: URL
    let developerDirURL: URL
    let sourceRootURL: URL
    let sdkRootURL: URL
    let platformURL: URL

    let rswiftIgnoreURL: URL

    public init(
        xcodeprojURL: URL,
        targetName: String,
        productModuleName: String?,
        infoPlistFile: URL?,
        codeSignEntitlements: URL?,
        builtProductsDirURL: URL,
        developerDirURL: URL,
        sourceRootURL: URL,
        sdkRootURL: URL,
        platformURL: URL,
        rswiftIgnoreURL: URL
    ) {
        self.xcodeprojURL = xcodeprojURL
        self.targetName = targetName
        self.productModuleName = productModuleName
        self.infoPlistFile = infoPlistFile
        self.codeSignEntitlements = codeSignEntitlements

        self.builtProductsDirURL = builtProductsDirURL
        self.developerDirURL = developerDirURL
        self.sourceRootURL = sourceRootURL
        self.sdkRootURL = sdkRootURL
        self.platformURL = platformURL

        self.rswiftIgnoreURL = rswiftIgnoreURL
    }

    // Temporary function for use during development
    public func developRun() throws {
        let ignoreFile = (try? IgnoreFile(ignoreFileURL: rswiftIgnoreURL)) ?? IgnoreFile()
        let xcodeproj = try! Xcodeproj(url: xcodeprojURL, warning: { print($0) })

    let buildConfigurations = try xcodeproj.buildConfigurations(forTarget: targetName)

        let paths = try xcodeproj.resourcePaths(forTarget: targetName)
        let urls = paths
            .map { $0.url(with: urlForSourceTreeFolder) }
            .filter { !ignoreFile.matches(url: $0) }

        let start = Date()

        let dontGenerateFileForFonts = false
        let dontGenerateFileForImages = false
        let files = try urls
            .filter { !FileResource.unsupportedExtensions.contains($0.pathExtension) }
            .filter { !(dontGenerateFileForFonts && FontResource.supportedExtensions.contains($0.pathExtension)) }
            .filter { !(dontGenerateFileForImages && ImageResource.supportedExtensions.contains($0.pathExtension)) }
            .map { try FileResource.parse(url: $0) }

        let storyboards = try urls
            .filter { StoryboardResource.supportedExtensions.contains($0.pathExtension) }
            .map { try StoryboardResource.parse(url: $0) }

        let nibs = try urls
            .filter { NibResource.supportedExtensions.contains($0.pathExtension) }
            .map { try NibResource.parse(url: $0) }

        let fonts = try urls
            .filter { FontResource.supportedExtensions.contains($0.pathExtension) }
            .map { try FontResource.parse(url: $0) }

        let images = try urls
            .filter { ImageResource.supportedExtensions.contains($0.pathExtension) }
            .map { try ImageResource.parse(url: $0, assetTags: nil) }
        let assetCatalogs = try urls
            .filter { AssetCatalog.supportedExtensions.contains($0.pathExtension) }
            .map { try AssetCatalog.parse(url: $0) }

        let localizableStrings = try urls
            .filter { LocalizableStrings.supportedExtensions.contains($0.pathExtension) }
            .map { try LocalizableStrings.parse(url: $0) }


        let infoplist = URL(fileURLWithPath: "/Users/tom/Projects/R.swift/Examples/ResourceApp/ResourceApp/Info.plist")
        let entitlementsURL = URL(fileURLWithPath: "/Users/tom/Projects/R.swift/Examples/ResourceApp/ResourceApp/ResourceApp.entitlements")
        let plist = try PropertyListResource.parse(url: infoplist, buildConfigurationName: "ResourceApp")
        let infoPlistWhitelist = ["UIApplicationShortcutItems", "UIApplicationSceneManifest", "NSUserActivityTypes", "NSExtension"]

//        let entitlements = try PropertyListResource.parse(url: entitlementsURL, buildConfigurationName: "ResourceApp")


        let structName = SwiftIdentifier(rawValue: "R")
        let qualifiedName = structName

//        let segueStruct = Segue.generateStruct(storyboards: storyboards, prefix: qualifiedName)

//        let imageStruct = ImageResource.generateStruct(
//            catalogs: assetCatalogs,
//            toplevel: images,
//            prefix: qualifiedName
//        )
//        let colorStruct = ColorResource.generateStruct(
//            catalogs: assetCatalogs,
//            prefix: qualifiedName
//        )
//        let dataStruct = DataResource.generateStruct(
//            catalogs: assetCatalogs,
//            prefix: qualifiedName
//        )

//        let fileStruct = FileResource.generateStruct(
//            resources: files,
//            prefix: qualifiedName
//        )

//        let idStruct = AccessibilityIdentifier.generateStruct(
//            nibs: nibs,
//            storyboards: storyboards,
//            prefix: qualifiedName
//        )

//        let fontStruct = FontResource.generateStruct(
//            resources: fonts,
//            prefix: qualifiedName
//        )

//        let storyboardStruct = StoryboardResource.generateStruct(
//            storyboards: storyboards,
//            prefix: qualifiedName
//        )

//        let infoStruct = PropertyListResource.generateStruct(
//            resourceName: "info",
//            plists: [plist],
//            toplevelKeysWhitelist: infoPlistWhitelist,
//            prefix: qualifiedName
//        )

//        let entitlementsStruct = PropertyListResource.generateStruct(
//            resourceName: "entitlements",
//            plists: [entitlements],
//            toplevelKeysWhitelist: nil,
//            prefix: qualifiedName
//        )

//        let reuseIdentifierStruct = Reusable.generateStruct(
//            nibs: nibs,
//            storyboards: storyboards,
//            prefix: qualifiedName
//        )

//        let nibStruct = NibResource.generateStruct(
//            nibs: nibs,
//            prefix: qualifiedName
//        )

        let stringStruct = LocalizableStrings.generateStruct(
            resources: localizableStrings,
            developmentLanguage: xcodeproj.developmentLanguage,
            prefix: qualifiedName
        )

        let s = Struct(name: structName) {
            stringStruct
        }

        print(s.prettyPrint())

        print("TOTAL", Date().timeIntervalSince(start))
        print()
    }

    private func urlForSourceTreeFolder(_ sourceTreeFolder: SourceTreeFolder) -> URL {
        switch sourceTreeFolder {
        case .buildProductsDir:
            return builtProductsDirURL
        case .developerDir:
            return developerDirURL
        case .sdkRoot:
            return sdkRootURL
        case .sourceRoot:
            return sourceRootURL
        case .platformDir:
            return platformURL
        }
    }
}
