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


extension AssetCatalog: SupportedExtensions {
    static public let supportedExtensions: Set<String> = ["xcassets"]

    static public func parse(url: URL) throws -> AssetCatalog {

        guard let basename = url.filenameWithoutExtension else {
            throw ResourceParsingError("Couldn't extract filename from URL: \(url)")
        }

        return AssetCatalog(filename: basename, root: try parseNamespace(url: url).namespace)
    }

    static private func parseNamespace(url: URL) throws -> NamespaceDirectory {
        let fileManager = FileManager.default
        func errorHandler(_ url: URL, _ error: Error) -> Bool {
            assertionFailure((error as NSError).debugDescription)
            return true
        }
        guard let directoryEnumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles, .producesRelativePathURLs], errorHandler: errorHandler) else {
            throw ResourceParsingError("Supposed AssetCatalog \(url) can't be enumerated")
        }

        let root = NamespaceDirectory()
        var namespaces: [URL: NamespaceDirectory] = [URL(fileURLWithPath: ".", relativeTo: url): root]

        for case let fileURL as URL in directoryEnumerator {
            guard fileURL.baseURL == url else {
                throw ResourceParsingError("File \(fileURL) is not in AssetCatalog \(url)")
            }

            let resourceValues = try fileURL.resourceValues(forKeys: [.isDirectoryKey])
            let isDirectory = resourceValues.isDirectory!

            let name = fileURL.lastPathComponent
            let pathExtension = fileURL.pathExtension

            var parentURL = URL(fileURLWithPath: fileURL.relativePath, relativeTo: url).deletingLastPathComponent()
            var parent: NamespaceDirectory? = namespaces[parentURL]
            for _ in 0..<directoryEnumerator.level {
                if parent != nil { break }
                parentURL = parentURL.deletingLastPathComponent()
                parent = namespaces[parentURL]
            }

            guard let parent = parent else {
                throw ResourceParsingError("Can't find namespace in AssetCatalog \(url) for \(fileURL)")
            }

            if imageExtensions.contains(pathExtension) {
                parent.images.append(name)
            } else if colorExtensions.contains(pathExtension) {
                parent.colors.append(name)
            } else if ignoredExtensions.contains(pathExtension) {
                directoryEnumerator.skipDescendants()
            } else if isDirectory && providesNamespace(directory: fileURL) {
                let ns = NamespaceDirectory()
                namespaces[URL(fileURLWithPath: fileURL.relativePath, relativeTo: url)] = ns
                parent.subnamespaces[name] = ns
            } else if isDirectory {
                // Ignore
            } else {
                // Unknown
            }
        }

        return root
    }

}

private func providesNamespace(directory: URL) -> Bool {
    let decoder = JSONDecoder()
    guard
        let contentsFile = URL(string: "Contents.json", relativeTo: directory),
        let contentsData = try? Data(contentsOf: contentsFile),
        let contents = try? decoder.decode(ContentsJson.self, from: contentsData)
    else { return false }

    return contents.properties.providesNamespace
}


// Note: "appiconset" is not loadable by default, so it's not included here
private let imageExtensions: Set<String> = ["launchimage", "imageset", "imagestack", "symbolset"]

private let colorExtensions: Set<String> = ["colorset"]

// Ignore everything in folders with these extensions
private let ignoredExtensions: Set<String> = ["brandassets", "imagestacklayer", "appiconset"]

private class NamespaceDirectory: CustomDebugStringConvertible {
    var subnamespaces: [String: NamespaceDirectory] = [:]
    var colors: [String] = []
    var images: [String] = []
    var files: [String] = []

    var namespace: AssetCatalog.Namespace {
        AssetCatalog.Namespace(
            subnamespaces: subnamespaces.mapValues(\.namespace),
            colors: colors,
            images: images,
            files: files
        )
    }

    var debugDescription: String {
        "Directory(subnamespaces: \(subnamespaces), files: \(files))"
    }
}

private struct ContentsJson: Decodable {
    let properties: Properties

    struct Properties: Decodable {
        let providesNamespace: Bool

        enum CodingKeys: String, CodingKey {
            case providesNamespace = "provides-namespace"
        }
    }
}
