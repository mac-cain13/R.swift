//
//  AssetFolder.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 09-12-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

// Note: "appiconset" is not loadable by default, so it's not included here
private let assetExtensions: Set<String> = ["launchimage", "imageset", "imagestack"]

// Ignore everything in folders with these extensions
private let ignoredExtensions: Set<String> = ["brandassets", "imagestacklayer"]

// Files checked for asset folder and subfolder properties
private let assetPropertiesFilenames: Array<(fileName: String, fileExtension: String)> = [("Contents","json")]

struct AssetFolder: WhiteListedExtensionsResourceType, NamespacedAssetSubfolderType {
  static let supportedExtensions: Set<String> = ["xcassets"]

  let url: URL
  let name: String
  let path = ""
  let resourcePath = ""
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
        if fileURL.providesNamespace() {
          namespaces.append(fileURL.namespaceURL)
        }
        if assetExtensions.contains(pathExtension) {
          assets.append(fileURL)
        }
        if ignoredExtensions.contains(pathExtension) {
          enumerator.skipDescendants()
        }
      }
    }

    subfolders = []
    imageAssets = []
    namespaces.sort { $0.absoluteString < $1.absoluteString }
    for namespace in namespaces.map(NamespacedAssetSubfolder.init) {
      populateSubfolders(subfolder: namespace)
    }

    for asset in assets {
      populateImageAssets(asset: asset)
    }
  }
}

protocol NamespacedAssetSubfolderType {
  var url: URL { get }
  var path: String { get }
  var resourcePath: String { get }
  var imageAssets: [String] { get set }
  var subfolders: [NamespacedAssetSubfolder] { get set }
}

extension NamespacedAssetSubfolderType {
  mutating func populateSubfolders(subfolder: NamespacedAssetSubfolder) {
    if var parent = subfolders.first(where: { subfolder.isSubfolderOf($0) }) {
      parent.populateSubfolders(subfolder: subfolder)
    } else {
      let name = SwiftIdentifier(name: subfolder.name)
      let resourceName = SwiftIdentifier(rawValue: subfolder.name)
      subfolder.path = path != "" ? "\(path).\(name)" : "\(name)"
      subfolder.resourcePath = resourcePath != "" ? "\(resourcePath)/\(resourceName)" : "\(resourceName)"
      subfolders.append(subfolder)
    }
  }

  mutating func populateImageAssets(asset: URL) {
    if var parent = subfolders.first(where: { asset.matches($0.url) }) {
      parent.populateImageAssets(asset: asset)
    } else {
      if let filename = asset.filename {
        imageAssets.append(filename)
      }
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

fileprivate extension URL {

  func providesNamespace() -> Bool {
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
  func matches(_ namespace: URL) -> Bool {
    return self.absoluteString.hasPrefix(namespace.absoluteString)
  }
}
