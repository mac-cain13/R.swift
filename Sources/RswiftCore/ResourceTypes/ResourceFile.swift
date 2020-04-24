//
//  ResourceFile.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 09-12-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

struct ResourceFile {
  // These are all extensions of resources that are passed to some special compiler step and not directly available runtime
  static let unsupportedExtensions: Set<String> = [
      AssetFolder.supportedExtensions,
      Storyboard.supportedExtensions,
      Nib.supportedExtensions,
      LocalizableStrings.supportedExtensions,
    ]
    .reduce([]) { $0.union($1) }

  let fullname: String
  let filename: String
  let filenameWithNamespace: String
  let pathExtension: String
  let isDirectory: Bool
  let subfiles: [ResourceFile]

  init(url: URL, withNamespace namespace: String? = nil, fileManager: FileManager) throws {
    pathExtension = url.pathExtension
    if ResourceFile.unsupportedExtensions.contains(pathExtension) {
      throw ResourceParsingError.unsupportedExtension(givenExtension: pathExtension, supportedExtensions: ["*"])
    }

    let fullname = url.lastPathComponent
    guard let filename = url.filename else {
      throw ResourceParsingError.parsingFailed("Couldn't extract filename from URL: \(url)")
    }
    let filenameWithNamespace = namespace.map { "\($0)/\(filename)" } ?? filename
	
    self.fullname = fullname
    self.filename = filename
    self.filenameWithNamespace = filenameWithNamespace
    
    if let subfileURLs = try? fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .skipsHiddenFiles) {
      let subfileNamespace = namespace.map { "\($0)/\(filename)"} ?? filename
      self.subfiles = subfileURLs.compactMap { try? ResourceFile(url: $0, withNamespace: subfileNamespace, fileManager: fileManager) }
      self.isDirectory = true
    } else {
      self.subfiles = []
      self.isDirectory = false
    }
  }
}
