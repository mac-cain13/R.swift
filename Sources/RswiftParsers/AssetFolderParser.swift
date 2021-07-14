//
//  AssetFolderParser.swift
//  
//
//  Created by Mathijs on 13/07/2021.
//

import Foundation
import RswiftResources

// Note: "appiconset" is not loadable by default, so it's not included here
private let imageExtensions: Set<String> = ["launchimage", "imageset", "imagestack", "symbolset"]

private let colorExtensions: Set<String> = ["colorset"]

// Ignore everything in folders with these extensions
private let ignoredExtensions: Set<String> = ["brandassets", "imagestacklayer"]

// Files checked for asset folder and subfolder properties
private let assetPropertiesFilenames: Array<(fileName: String, fileExtension: String)> = [("Contents","json")]

public struct AssetFolderParser: ResourceParser {
    public let supportedExtensions: Set<String> = ["xcassets"]

    public init() {}

    public func parse(url: URL) throws -> AssetFolder {
        try throwIfUnsupportedExtension(url)

        let filename = url.lastPathComponent
        let name = filename

        // Browse asset directory recursively and list only the assets folders
        var imageAssetURLs = [URL]()
        var colorAssetURLs = [URL]()
        var namespaces = [URL]()
        let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles], errorHandler: nil)

        if let enumerator = enumerator {
            for case let fileURL as URL in enumerator {
                let pathExtension = fileURL.pathExtension
                if fileURL.providesNamespace {
                    namespaces.append(fileURL.namespaceURL)
                } else if imageExtensions.contains(pathExtension) {
                    imageAssetURLs.append(fileURL)
                } else if colorExtensions.contains(pathExtension) {
                    colorAssetURLs.append(fileURL)
                } else if ignoredExtensions.contains(pathExtension) {
                    enumerator.skipDescendants()
                }
            }
        }

        namespaces.sort { $0.absoluteString < $1.absoluteString }

        let subfolders: [AssetFolder] = []
        // TODO
//                try namespaces.map { namespace in
//                // Recursively parse subfolders
//                try parse(url: namespace)
//            }

        return AssetFolder(
            url: url,
            name: name,
            path: url.absoluteString, // TODO
            resourcePath: "", // TODO
            imageAssets: imageAssetURLs,
            colorAssets: colorAssetURLs,
            subfolders: subfolders
        )
    }
}

fileprivate extension URL {
    var providesNamespace: Bool {
        guard isFileURL else { return false }

        let isPropertiesFile = assetPropertiesFilenames.contains(where: { arg -> Bool in
            let (fileName, fileExtension) = arg
            guard let pathFilename = self.filename else {
                return false
            }
            let pathExtension = self.pathExtension
            return pathFilename == fileName && pathExtension == fileExtension
        })

        guard isPropertiesFile else { return false }
        guard let data = try? Data(contentsOf: self) else { return false }
        guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) else { return false }
        guard let dict = json as? [String: Any] else { return false }
        guard let properties = dict["properties"] as? [String: Any] else { return false }
        guard let providesNamespace = properties["provides-namespace"] as? Bool else { return false }

        return providesNamespace
    }

    var namespace: String {
        return lastPathComponent
    }

    var namespaceURL: URL {
        return deletingLastPathComponent()
    }

    // Returns whether self is descendant of namespace
    func isDescendantOf(_ other: URL) -> Bool {
        absoluteString.hasPrefix(other.absoluteString)
    }
}
