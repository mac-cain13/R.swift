//
//  AssetFolder.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 09-12-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation
import RswiftResources
import CoreGraphics

// Note: "appiconset" is not loadable by default, so it's not included here
private let imageExtensions: Set<String> = ["launchimage", "imageset", "imagestack", "symbolset"]

private let colorExtensions: Set<String> = ["colorset"]
private let datasetExtensions: Set<String> = ["dataset"]

// Ignore everything in folders with these extensions
private let ignoredExtensions: Set<String> = ["brandassets", "imagestacklayer", "appiconset"]

extension AssetCatalog: SupportedExtensions {
    static public let supportedExtensions: Set<String> = ["xcassets"]

    static public func parse(url: URL) throws -> AssetCatalog {

        guard let basename = url.filenameWithoutExtension else {
            throw ResourceParsingError("Couldn't extract filename from URL: \(url)")
        }

        let directory = try parseDirectory(catalogURL: url)
        let namespace = try createNamespace(directory: directory, path: [])

        return AssetCatalog(filename: basename, root: namespace)
    }

    static private func parseDirectory(catalogURL: URL) throws -> NamespaceDirectory {
        let fileManager = FileManager.default
        func errorHandler(_ url: URL, _ error: Error) -> Bool {
            assertionFailure((error as NSError).debugDescription)
            return true
        }
        guard let directoryEnumerator = fileManager.enumerator(at: catalogURL, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles, .producesRelativePathURLs], errorHandler: errorHandler) else {
            throw ResourceParsingError("Supposed AssetCatalog \(catalogURL) can't be enumerated")
        }

        let root = NamespaceDirectory()
        var namespaces: [URL: NamespaceDirectory] = [URL(fileURLWithPath: ".", relativeTo: catalogURL): root]

        for case let fileURL as URL in directoryEnumerator {
            guard fileURL.baseURL == catalogURL else {
                throw ResourceParsingError("File \(fileURL) is not in AssetCatalog \(catalogURL)")
            }

            let resourceValues = try fileURL.resourceValues(forKeys: [.isDirectoryKey])
            let isDirectory = resourceValues.isDirectory!

            guard let filename = fileURL.filenameWithoutExtension else {
                throw ResourceParsingError("Missing filename in \(fileURL)")
            }
            let pathExtension = fileURL.pathExtension

            let relativeURL = URL(fileURLWithPath: fileURL.relativePath, relativeTo: catalogURL)
            var parentURL = relativeURL
            var parent: NamespaceDirectory?
            for _ in 0..<directoryEnumerator.level {
                parentURL = parentURL.deletingLastPathComponent()
                parent = namespaces[parentURL]
                if parent != nil { break }
            }

            guard let parent = parent else {
                throw ResourceParsingError("Can't find namespace in AssetCatalog \(catalogURL) for \(fileURL)")
            }

            if imageExtensions.contains(pathExtension) {
                parent.images.append(fileURL)
            } else if colorExtensions.contains(pathExtension) {
                parent.colors.append(fileURL)
            } else if datasetExtensions.contains(pathExtension) {
                parent.dataAssets.append(fileURL)
            } else if ignoredExtensions.contains(pathExtension) {
                directoryEnumerator.skipDescendants()
            } else if isDirectory && providesNamespace(directory: fileURL) {
                let ns = NamespaceDirectory()
                namespaces[relativeURL] = ns
                parent.subnamespaces[filename] = ns
            } else if isDirectory {
                // Ignore
            } else {
                // Unknown
            }
        }

        return root
    }

    static private func createNamespace(directory: NamespaceDirectory, path: [String]) throws -> Namespace {

        var subnamespaces: [String: AssetCatalog.Namespace] = [:]
        for (name, directory) in directory.subnamespaces {
            subnamespaces[name] = try createNamespace(directory: directory, path: path + [name])
        }

        var colors: [AssetCatalog.Color] = []
        for fileURL in directory.colors {
            colors.append(.init(name: fileURL.filenameWithoutExtension!))
        }

        var images: [Image] = []
        for fileURL in directory.images {
            let tags = onDemandResourceTags(directory: fileURL)
            images.append(.init(name: fileURL.filenameWithoutExtension!, onDemandResourceTags: tags))
        }

        var dataAssets: [AssetCatalog.DataAsset] = []
        for fileURL in directory.dataAssets {
            let tags = onDemandResourceTags(directory: fileURL)
            dataAssets.append(.init(name: fileURL.filenameWithoutExtension!, onDemandResourceTags: tags))
        }

        return AssetCatalog.Namespace(
            subnamespaces: subnamespaces,
            colors: colors,
            images: images,
            dataAssets: dataAssets
        )
    }
}

private class NamespaceDirectory: CustomDebugStringConvertible {
    var subnamespaces: [String: NamespaceDirectory] = [:]
    var colors: [URL] = []
    var images: [URL] = []
    var dataAssets: [URL] = []

    var debugDescription: String {
        "Directory(subnamespaces: \(subnamespaces), images: \(images)"
    }
}

private func providesNamespace(directory: URL) -> Bool {
    guard
        let contents = try? ContentsJson.parse(directory: directory),
        let providesNamespace = contents.properties.providesNamespace
    else { return false }

    return providesNamespace
}

private func onDemandResourceTags(directory: URL) -> [String]? {
    guard
        let contents = try? ContentsJson.parse(directory: directory)
    else { return nil }

    return contents.properties.onDemandResourceTags
}

private struct ContentsJson: Decodable {
    let properties: Properties

    struct Properties: Decodable {
        let providesNamespace: Bool?
        let onDemandResourceTags: [String]?

        enum CodingKeys: String, CodingKey {
            case providesNamespace = "provides-namespace"
            case onDemandResourceTags = "on-demand-resource-tags"
        }
    }

    static func parse(directory: URL) throws -> ContentsJson {
        let decoder = JSONDecoder()
        let contentsFile = URL(string: "Contents.json", relativeTo: directory)!
        let contentsData = try Data(contentsOf: contentsFile)
        let contents = try decoder.decode(ContentsJson.self, from: contentsData)

        return contents
    }
}
