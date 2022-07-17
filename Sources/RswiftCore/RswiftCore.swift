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
        //        let items = try urls
        //            .filter { ImageResource.supportedExtensions.contains($0.pathExtension) }
        ////            .filter { !FileResource.unsupportedExtensions.contains($0.pathExtension) }
        //            .map { try ImageResource.parse(url: $0, assetTags: nil) }
        //        for item in items {
        ////            print(">>>", item)
        //            print(item.generateResourceLetCodeString())
        //        }

        //        let items = try urls
        //            .filter { StoryboardResource.supportedExtensions.contains($0.pathExtension) }
        ////            .filter { !FileResource.unsupportedExtensions.contains($0.pathExtension) }
        //            .map { try StoryboardResource.parse(url: $0) }
        //        for item in items {
        //            print(item.name, item.viewControllers.map(\.type.rawName))
        //        }

        let images = try urls
            .filter { ImageResource.supportedExtensions.contains($0.pathExtension) }
            .map { try ImageResource.parse(url: $0, assetTags: nil) }
        let assetCatalogs = try urls
            .filter { AssetCatalog.supportedExtensions.contains($0.pathExtension) }
            .map { try AssetCatalog.parse(url: $0) }

        let structName = SwiftIdentifier(rawValue: "R")
        let qualifiedName = structName
        let s = Struct(name: structName) {
            ImageResource.generateStruct(
                resources: images,
                namespaces: assetCatalogs.map(\.root),
                name: SwiftIdentifier(name: "image"),
                prefix: qualifiedName
            )
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
