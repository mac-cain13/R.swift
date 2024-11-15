//
//  ProjectResources.swift
//  
//
//  Created by Tom Lokhorst on 2022-07-29.
//

import Foundation
import XcodeEdit
import RswiftResources
import RswiftShared

public struct ProjectResources {
    public let assetCatalogs: [AssetCatalog]
    public let files: [FileResource]
    public let fonts: [FontResource]
    public let images: [ImageResource]
    public let strings: [StringsTable]
    public let nibs: [NibResource]
    public let storyboards: [StoryboardResource]
    public let infoPlists: [PropertyListResource]
    public let codeSignEntitlements: [PropertyListResource]

    public static func parseXcodeproj(
        xcodeproj: Xcodeproj,
        targetName: String,
        rswiftIgnoreURL: URL?,
        infoPlistFile: URL?,
        codeSignEntitlements: URL?,
        sourceTreeURLs: SourceTreeURLs,
        parseFontsAsFiles: Bool,
        parseImagesAsFiles: Bool,
        resourceTypes: [ResourceType],
        warning: (String) -> Void
    ) throws -> ProjectResources {
        let ignoreFile = rswiftIgnoreURL.flatMap { try? IgnoreFile(ignoreFileURL: $0) } ?? IgnoreFile()

        let buildConfigurations = try xcodeproj.buildConfigurations(forTarget: targetName)

        var excludeURLs: [URL] = []
        let infoPlists: [PropertyListResource]
        let entitlements: [PropertyListResource]

        if resourceTypes.contains(.info) {
            infoPlists = try buildConfigurations.compactMap { config -> PropertyListResource? in
                guard let url = infoPlistFile else { return nil }
                excludeURLs.append(url)
                return try parse(with: warning) {
                    try PropertyListResource.parse(url: url, buildConfigurationName: config.name)
                }
            }
        } else {
            infoPlists = []
        }

        if resourceTypes.contains(.entitlements) {
            entitlements = try buildConfigurations.compactMap { config -> PropertyListResource? in
                guard let url = codeSignEntitlements else { return nil }
                excludeURLs.append(url)
                return try parse(with: warning) { try PropertyListResource.parse(url: url, buildConfigurationName: config.name) }
            }
        } else {
            entitlements = []
        }

        let paths = try xcodeproj.resourcePaths(forTarget: targetName)
        let pathURLs = paths.map { $0.url(with: sourceTreeURLs.url(for:)) }

        let extraURLs = try xcodeproj.extraResourceURLs(forTarget: targetName, sourceTreeURLs: sourceTreeURLs)

        // Combine URLs from Xcode project file with extra URLs found by scanning file system
        var pathAndExtraURLs = Array(Set(pathURLs + extraURLs))

        // Find all localized strings files for ignore extension so that those can be removed
        let localizedExtensions = ["xib", "storyboard", "intentdefinition"]
        let localizedStringURLs = findLocalizedStrings(inputURLs: pathAndExtraURLs, ignoreExtensions: localizedExtensions)

        // These file types are compiled, and shouldn't be included as resources
        // Note that this should be done after finding localized files
        let sourceCodeExtensions = [
            "swift", "h", "m", "mm", "c", "cpp", "metal",
            "xcdatamodeld", "entitlements", "intentdefinition",
        ]
        pathAndExtraURLs.removeAll(where: { sourceCodeExtensions.contains($0.pathExtension) })

        // Remove all ignored files, excluded files and localized strings files
        let urls = pathAndExtraURLs
            .filter { !ignoreFile.matches(url: $0) }
            .filter { !excludeURLs.contains($0) }
            .filter { !localizedStringURLs.contains($0) }

        return try parseURLs(
            urls: urls,
            infoPlists: infoPlists,
            codeSignEntitlements: entitlements,
            parseFontsAsFiles: parseFontsAsFiles,
            parseImagesAsFiles: parseImagesAsFiles,
            resourceTypes: resourceTypes,
            warning: warning
        )
    }

    public static func parseURLs(
        urls: [URL],
        infoPlists: [PropertyListResource],
        codeSignEntitlements: [PropertyListResource],
        parseFontsAsFiles: Bool,
        parseImagesAsFiles: Bool,
        resourceTypes: [ResourceType],
        warning: (String) -> Void
    ) throws -> ProjectResources {

        let assetCatalogs: [AssetCatalog]
        let files: [FileResource]
        let fonts: [FontResource]
        let images: [ImageResource]
        let strings: [StringsTable]
        let nibs: [NibResource]
        let storyboards: [StoryboardResource]

        if resourceTypes.contains(.image) || resourceTypes.contains(.color) || resourceTypes.contains(.data) {
            assetCatalogs = try urls
                .filter { AssetCatalog.supportedExtensions.contains($0.pathExtension) }
                .compactMap { url in try parse(with: warning) { try AssetCatalog.parse(url: url) } }
        } else {
            assetCatalogs = []
        }

        if resourceTypes.contains(.file) {
            let dontParseFileForFonts = !parseFontsAsFiles
            let dontParseFileForImages = !parseImagesAsFiles
            files = try urls
                .filter { !FileResource.unsupportedExtensions.contains($0.pathExtension) }
                .filter { !(dontParseFileForFonts && FontResource.supportedExtensions.contains($0.pathExtension)) }
                .filter { !(dontParseFileForImages && ImageResource.supportedExtensions.contains($0.pathExtension)) }
                .compactMap { url in try parse(with: warning) { try FileResource.parse(url: url) } }
        } else {
            files = []
        }

        if resourceTypes.contains(.font) {
            fonts = try urls
                .filter { FontResource.supportedExtensions.contains($0.pathExtension) }
                .compactMap { url in try parse(with: warning) { try FontResource.parse(url: url) } }
        } else {
            fonts = []
        }

        if resourceTypes.contains(.image) {
            images = try urls
                .filter { ImageResource.supportedExtensions.contains($0.pathExtension) }
                .compactMap { url in try parse(with: warning) { try ImageResource.parse(url: url, assetTags: nil) } }
        } else {
            images = []
        }

        if resourceTypes.contains(.string) {
            strings = try urls
                .filter { StringsTable.supportedExtensions.contains($0.pathExtension) }
                .compactMap { url in try parse(with: warning) { try StringsTable.parse(url: url) } }
        } else {
            strings = []
        }

        if resourceTypes.contains(.nib) {
            nibs = try urls
                .filter { NibResource.supportedExtensions.contains($0.pathExtension) }
                .compactMap { url in try parse(with: warning) { try NibResource.parse(url: url) } }
        } else {
            nibs = []
        }

        if resourceTypes.contains(.storyboard) {
            storyboards = try urls
                .filter { StoryboardResource.supportedExtensions.contains($0.pathExtension) }
                .compactMap { url in try parse(with: warning) { try StoryboardResource.parse(url: url) } }
        } else {
            storyboards = []
        }

        return ProjectResources(
            assetCatalogs: assetCatalogs,
            files: files,
            fonts: fonts,
            images: images,
            strings: strings,
            nibs: nibs,
            storyboards: storyboards,
            infoPlists: infoPlists,
            codeSignEntitlements: codeSignEntitlements
        )
    }
}

// Finds strings files for Xcode generated files
//
// Example 1:
// some-dir/Base.lproj/MyIntents.intentdefinition
// some-dir/nl.lproj/MyIntents.string
//
// Example 2:
// some-dir/Base.lproj/Main.storyboard
// some-dir/nl.lproj/Main.string
private func findLocalizedStrings(inputURLs: [URL], ignoreExtensions: [String]) -> [URL] {
    // Dictionary to map each parent directory to its `.lproj` subdirectories
    var parentToLprojDirectories = [URL: [URL]]()

    // Dictionary to keep track of files in each `.lproj` directory
    var directoryContents = [URL: [URL]]()

    // Populate the dictionaries
    for url in inputURLs {
        let directoryURL = url.deletingLastPathComponent()
        let parentDirectory = directoryURL.deletingLastPathComponent()
        if directoryURL.lastPathComponent.hasSuffix(".lproj") {
            parentToLprojDirectories[parentDirectory, default: []].append(directoryURL)
            directoryContents[directoryURL, default: []].append(url)
        }
    }

    // Set of URLs to remove
    var urlsToRemove = Set<URL>()

    // Analyze each group of sibling `.lproj` directories under the same parent
    for (_, lprojDirectories) in parentToLprojDirectories {
        var baseFilenameToFileUrls = [String: [URL]]()
        var baseFilenamesWithIgnoreExtension = Set<String>()

        // Collect all files by base filename and check for files with an ignoreExtension
        for directory in lprojDirectories {
            guard let files = directoryContents[directory] else { continue }
            for file in files {
                let baseFilename = file.deletingPathExtension().lastPathComponent
                let fileExtension = file.pathExtension

                baseFilenameToFileUrls[baseFilename, default: []].append(file)

                if ignoreExtensions.contains(fileExtension) {
                    baseFilenamesWithIgnoreExtension.insert(baseFilename)
                }
            }
        }

        // Determine which files to remove based on the presence of files with an ignoreExtension
        for baseFilename in baseFilenamesWithIgnoreExtension {
            if let files = baseFilenameToFileUrls[baseFilename] {
                for file in files {
                    if file.pathExtension == "strings" {
                        urlsToRemove.insert(file)
                    }
                }
            }
        }
    }

    return Array(urlsToRemove)
}


private func parse<R>(with warning: (String) -> Void, closure: () throws -> R) throws -> R? {
    do {
        return try closure()
    } catch let error as ResourceParsingError {
        warning(error.description)
        return nil
    }
}
