//
//  ResourceFile.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 09-12-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
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
  let pathExtension: String?

  init(url: NSURL) throws {
    if let pathExtension = url.pathExtension where ResourceFile.unsupportedExtensions.contains(pathExtension) {
      throw ResourceParsingError.UnsupportedExtension(givenExtension: pathExtension, supportedExtensions: ["*"])
    }

    guard let fullname = url.lastPathComponent, filename = url.filename else {
      throw ResourceParsingError.ParsingFailed("Couldn't extract filename without extension from URL: \(url)")
    }

    self.fullname = fullname
    self.filename = filename
    pathExtension = url.pathExtension
  }
}
