//
//  File.swift
//  
//
//  Created by Tom Lokhorst on 2022-07-29.
//

import Foundation
import XcodeEdit
import RswiftResources

public struct Project {
    public let assetCatalogs: [AssetCatalog]
    public let files: [FileResource]
    public let fonts: [FontResource]
    public let images: [ImageResource]
    public let localizableStrings: [LocalizableStrings]
    public let nibs: [NibResource]
    public let storyboards: [StoryboardResource]
    public let infoPlists: [PropertyListResource]
    public let codeSignEntitlements: [PropertyListResource]
    public let xcodeproj: Xcodeproj

    public static func parseTarget(
        name targetName: String,
        xcodeprojURL: URL,
        rswiftIgnoreURL: URL?,
        infoPlistFile: URL?,
        codeSignEntitlements: URL?,
        sourceTreeURLs: SourceTreeURLs,
        parseFontsAsFiles: Bool = true,
        parseImagesAsFiles: Bool = true,
        warning: (String) -> Void
    ) throws -> Project {
        let xcodeproj = try Xcodeproj(url: xcodeprojURL, warning: warning)
        let ignoreFile = rswiftIgnoreURL.flatMap { try? IgnoreFile(ignoreFileURL: $0) } ?? IgnoreFile()

        let buildConfigurations = try xcodeproj.buildConfigurations(forTarget: targetName)

        let paths = try xcodeproj.resourcePaths(forTarget: targetName)
        let urls = paths
            .map { $0.url(with: sourceTreeURLs.url(for:)) }
            .filter { !ignoreFile.matches(url: $0) }


    let assetCatalogs = try urls
        .filter { AssetCatalog.supportedExtensions.contains($0.pathExtension) }
        .map { try AssetCatalog.parse(url: $0) }

        let dontParseFileForFonts = !parseFontsAsFiles
        let dontParseFileForImages = !parseImagesAsFiles
        let files = try urls
            .filter { !FileResource.unsupportedExtensions.contains($0.pathExtension) }
            .filter { !(dontParseFileForFonts && FontResource.supportedExtensions.contains($0.pathExtension)) }
            .filter { !(dontParseFileForImages && ImageResource.supportedExtensions.contains($0.pathExtension)) }
            .map { try FileResource.parse(url: $0) }

        let fonts = try urls
            .filter { FontResource.supportedExtensions.contains($0.pathExtension) }
            .map { try FontResource.parse(url: $0) }

        let images = try urls
            .filter { ImageResource.supportedExtensions.contains($0.pathExtension) }
            .map { try ImageResource.parse(url: $0, assetTags: nil) }

        let localizableStrings = try urls
            .filter { LocalizableStrings.supportedExtensions.contains($0.pathExtension) }
            .map { try LocalizableStrings.parse(url: $0) }

        let nibs = try urls
            .filter { NibResource.supportedExtensions.contains($0.pathExtension) }
            .map { try NibResource.parse(url: $0) }

        let storyboards = try urls
            .filter { StoryboardResource.supportedExtensions.contains($0.pathExtension) }
            .map { try StoryboardResource.parse(url: $0) }

        let infoPlists = try buildConfigurations.compactMap { config -> PropertyListResource? in
            guard let url = infoPlistFile else { return nil }
            return try PropertyListResource.parse(url: url, buildConfigurationName: config.name)
        }

        let codeSignEntitlements = try buildConfigurations.compactMap { config -> PropertyListResource? in
            guard let url = codeSignEntitlements else { return nil }
            return try PropertyListResource.parse(url: url, buildConfigurationName: config.name)
        }

        return Project(
            assetCatalogs: assetCatalogs,
            files: files,
            fonts: fonts,
            images: images,
            localizableStrings: localizableStrings,
            nibs: nibs,
            storyboards: storyboards,
            infoPlists: infoPlists,
            codeSignEntitlements: codeSignEntitlements,
            xcodeproj: xcodeproj
        )
    }
}
