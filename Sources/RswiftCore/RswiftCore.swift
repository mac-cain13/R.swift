//
//  RswiftCore.swift
//  rswift
//
//  Created by Tom Lokhorst on 2021-04-16.
//

import Foundation
import XcodeEdit
import RswiftGenerators
import RswiftParsers
import RswiftResources
import SwiftSyntax

public struct RswiftCore {
    public init() {}

    public func run(
        projectPath: String,
        targetName: String,
        sourceRoot: String
    ) throws {
        let xcodeprojURL = URL(fileURLWithPath: projectPath)
        let xcodeproj = try XcodeprojParser().parse(url: xcodeprojURL)
        let paths = try xcodeproj.resourcePaths(forTarget: targetName)
        let urls = paths
            .map {
                $0.url(with: { sourceTreeFolder in
                    switch sourceTreeFolder {
                    case .sourceRoot:
                        return URL(fileURLWithPath: sourceRoot)
                    case .buildProductsDir:
                        print("WARNING: buildProductsDir not implemented")
                        return URL(fileURLWithPath: sourceRoot)
                    case .developerDir:
                        print("WARNING: developerDir not implemented")
                        return URL(fileURLWithPath: sourceRoot)
                    case .sdkRoot:
                        print("WARNING: sdkRoot not implemented")
                        return URL(fileURLWithPath: sourceRoot)
                    case .platformDir:
                        print("WARNING: platformDir not implemented")
                        return URL(fileURLWithPath: sourceRoot)
                    }
                })
            }

        let fontParser = FontParser()
        let fonts = try urls
            .filter { fontParser.supportedExtensions.contains($0.pathExtension) }
            .map { try fontParser.parse(url: $0) }

        let fontGenerator = FontGenerator()

        let stringsParser = LocalizedStringsParser()
        let strings = try urls
            .filter { stringsParser.supportedExtensions.contains($0.pathExtension) }
            .map { try stringsParser.parse(url: $0) }
        let stringsGenerator = LocalizedStringGenerator()

        let assetFolderParser = AssetFolderParser()
        let assetFolders = try urls
            .filter { assetFolderParser.supportedExtensions.contains($0.pathExtension) }
            .map { try assetFolderParser.parse(url: $0) }
        let imageGenerator = ImageGenerator()

        let fontCode = try fonts.map { try fontGenerator.generateResourceLet(resource: $0) }
        let assetCode = try assetFolders.map { try imageGenerator.generateResourceLet(resource: $0) }
        let stringsCode = try strings.map { try stringsGenerator.generateResourceLet(resource: $0) }

        let x = (fontCode + assetCode + stringsCode)
        for syntax in x {
            print(syntax)
        }
    }
}
