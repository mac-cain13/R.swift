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
  let pathExtension: String

  init(url: URL) throws {
    pathExtension = url.pathExtension
    if ResourceFile.unsupportedExtensions.contains(pathExtension) {
      throw ResourceParsingError.unsupportedExtension(givenExtension: pathExtension, supportedExtensions: ["*"])
    }

    let fullname = url.lastPathComponent
    guard let filename = url.filename else {
      throw ResourceParsingError.parsingFailed("Couldn't extract filename from URL: \(url)")
    }

    self.fullname = fullname
    self.filename = filename
  }
}
