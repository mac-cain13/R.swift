//
//  AssetFolder.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 09-12-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

struct AssetFolder: WhiteListedExtensionsResourceType, NamespacedAssetSubfolderType {
  static let supportedExtensions: Set<String> = ["xcassets"]

  // Note: "appiconset" is not loadable by default, so it's not included here
  private static let AssetExtensions: Set<String> = ["launchimage", "imageset", "imagestack"]
  // Ignore everything in folders with these extensions
  private static let IgnoredExtensions: Set<String> = ["brandassets", "imagestacklayer"]
  // Files checked for asset folder and subfolder properties
  fileprivate static let AssetPropertiesFilenames: Array<(fileName: String, fileExtension: String)> = [("Contents","json")]

  let url: URL
  let name: String
  var path: String { return "" }
  var resourcePath: String { return "" }
  var imageAssets: [String]
  var subfolders: [NamespacedAssetSubfolder]

  init(url: URL, fileManager: FileManager) throws {
    self.url = url
    try AssetFolder.throwIfUnsupportedExtension(url.pathExtension)

    guard let filename = url.filename else {
      throw ResourceParsingError.parsingFailed("Couldn't extract filename from URL: \(url)")
    }
    name = filename

    // Browse asset directory recursively and list only the assets folders
    var assets = [URL]()
    var namespaces = [URL]()
    let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: nil, options: .skipsHiddenFiles, errorHandler: nil)
    if let enumerator = enumerator {
      for case let fileURL as URL in enumerator {
        let pathExtension = fileURL.pathExtension
        if fileURL.providesNamespace {
          namespaces.append(fileURL.namespaceURL)
        }
        if AssetFolder.AssetExtensions.contains(pathExtension) {
          assets.append(fileURL)
        }
        if AssetFolder.IgnoredExtensions.contains(pathExtension) {
          enumerator.skipDescendants()
        }
      }
    }

    subfolders = []
    imageAssets = []
    namespaces.sort { $0.absoluteString < $1.absoluteString }
    namespaces.map(NamespacedAssetSubfolder.init).forEach {
        dive(subfolder: $0)
    }

    assets.forEach {
        dive(asset: $0)
    }
  }
}

protocol NamespacedAssetSubfolderType {
    var url: URL { get }
    var name: String { get }
    var path: String { get }
    var resourcePath: String { get }
    var imageAssets: [String] { get set }
    var subfolders: [NamespacedAssetSubfolder] { get set }

    mutating func dive(subfolder: NamespacedAssetSubfolder)
    mutating func dive(asset: URL)
}

extension NamespacedAssetSubfolderType {
    mutating func dive(subfolder: NamespacedAssetSubfolder) {
        if var parent = subfolders.first(where: { subfolder.isSubfolderOf($0) }) {
            parent.dive(subfolder: subfolder)
        } else {
            let name = SwiftIdentifier(name: subfolder.name, lowercaseStartingCharacters: false)
            let resourceName = SwiftIdentifier(rawValue: subfolder.name)
            subfolder.path = path.characters.count > 0 ? "\(path).\(name)" : "\(name)"
            subfolder.resourcePath = resourcePath.characters.count > 0 ? "\(resourcePath)/\(resourceName)" : "\(resourceName)"
            subfolders.append(subfolder)
        }
    }

    mutating func dive(asset: URL) {
        if var parent = subfolders.first(where: { asset.matches($0.url) }) {
            parent.dive(asset: asset)
        } else {
            imageAssets.append(asset.filename!)
        }
    }

    func isSubfolderOf(_ subfolder: NamespacedAssetSubfolder) -> Bool {
        return url.absoluteString != subfolder.url.absoluteString && url.matches(subfolder.url)
    }
}

class NamespacedAssetSubfolder: NamespacedAssetSubfolderType {
    let url: URL
    let name: String
    var path: String = ""
    var resourcePath: String = ""
    var imageAssets: [String] = []
    var subfolders: [NamespacedAssetSubfolder] = []

    init(url: URL) {
        self.url = url
        self.name = url.namespace
    }
}

extension NamespacedAssetSubfolder: ExternalOnlyStructGenerator {
    func generatedStruct(at externalAccessLevel: AccessLevel) -> Struct {
        let allFunctions = imageAssets
        let groupedFunctions = allFunctions.groupedBySwiftIdentifier { $0 }

        groupedFunctions.printWarningsForDuplicatesAndEmpties(source: "image", result: "image")

        let imagePath = resourcePath + (!path.isEmpty ? "/" : "")

        let assetSubfolders = subfolders
            .mergeDuplicates()
            .removeConflicting(with: allFunctions.map({ "\(SwiftIdentifier(name: $0))" }))

        let structs = assetSubfolders
            .map { $0.generatedStruct(at: externalAccessLevel) }

        let imageLets = groupedFunctions
            .uniques
            .map { name in
                Let(
                    comments: ["Image `\(name)`."],
                    accessModifier: externalAccessLevel,
                    isStatic: true,
                    name: SwiftIdentifier(name: name),
                    typeDefinition: .inferred(Type.ImageResource),
                    value: "Rswift.ImageResource(bundle: R.hostingBundle, name: \"\(imagePath)\(name)\")"
                )
        }

        return Struct(
            comments: ["This `R.image` struct is generated, and contains static references to \(imageLets.count) images."],
            accessModifier: externalAccessLevel,
            type: Type(module: .host, name: SwiftIdentifier(name: name, lowercaseStartingCharacters: false)),
            implements: [],
            typealiasses: [],
            properties: imageLets,
            functions: groupedFunctions.uniques.map { imageFunction(for: $0, at: externalAccessLevel) },
            structs: structs,
            classes: []
        )
    }

    private func imageFunction(for name: String, at externalAccessLevel: AccessLevel) -> Function {
        return Function(
            comments: ["`UIImage(named: \"\(name)\", bundle: ..., traitCollection: ...)`"],
            accessModifier: externalAccessLevel,
            isStatic: true,
            name: SwiftIdentifier(name: name),
            generics: nil,
            parameters: [
                Function.Parameter(
                    name: "compatibleWith",
                    localName: "traitCollection",
                    type: Type._UITraitCollection.asOptional(),
                    defaultValue: "nil"
                )
            ],
            doesThrow: false,
            returnType: Type._UIImage.asOptional(),
            body: "return UIKit.UIImage(resource: R.image.\(path).\(SwiftIdentifier(name: name)), compatibleWith: traitCollection)"
        )
    }
}

fileprivate extension URL {
    var providesNamespace: Bool {
        guard isFileURL else { return false }

        let isPropertiesFile = AssetFolder.AssetPropertiesFilenames.contains(where: { (fileName: String, fileExtension: String) -> Bool in
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
    func matches(_ namespace: URL) -> Bool {
        return self.absoluteString.hasPrefix(namespace.absoluteString)
    }
}
