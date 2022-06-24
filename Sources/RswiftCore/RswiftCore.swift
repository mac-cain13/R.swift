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
        platformURL: URL
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
    }

    // Temporary function for use during development
    public func developRun() throws {
        let xcodeproj = try! Xcodeproj(url: xcodeprojURL, warning: { print($0) })

        let buildConfigurations = try xcodeproj.buildConfigurations(forTarget: targetName)

        let paths = try xcodeproj.resourcePaths(forTarget: targetName)
        let urls = paths
            .map { $0.url(with: urlForSourceTreeFolder) }

//        let fonts = try urls
//            .filter { Font.supportedExtensions.contains($0.pathExtension) }
//            .map { try Font.parse(url: $0) }
//        for font in fonts {
//            print(font.generateResourceLetCodeString())
//        }

//        let images = try urls
//            .filter { Image.supportedExtensions.contains($0.pathExtension) }
//            .map { try Image.parse(url: $0) }
//        for image in images {
//            print(image.generateResourceLetCodeString())
//        }

//        let nibs = try urls
//            .filter { Nib.supportedExtensions.contains($0.pathExtension) }
//            .map { try Nib.parse(url: $0) }
//        for nib in nibs {
//            print(nib.generateResourceLetCodeString())
//        }

        let storyboards = try urls
            .filter { Storyboard.supportedExtensions.contains($0.pathExtension) }
            .map { try Storyboard.parse(url: $0) }
        for storyboard in storyboards {
            print(storyboard.generateResourceLetCodeString())
        }

//        let resources = try urls
//            .map { try ResourceFile.parse(url: $0) }
//        for resource in resources {
//            print(resource.generateResourceLetCodeString())
//        }

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
