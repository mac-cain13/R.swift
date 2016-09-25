//
//  Font.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 09-12-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import Foundation

struct Font: WhiteListedExtensionsResourceType {
  static let supportedExtensions: Set<String> = ["otf", "ttf"]

  let name: String

  init(url: URL) throws {
    try Font.throwIfUnsupportedExtension(url.pathExtension)

    guard let dataProvider = CGDataProvider(url: url as CFURL) else {
      throw ResourceParsingError.parsingFailed("Unable to create data provider for font at \(url)")
    }
    let font = CGFont(dataProvider)

    guard let postScriptName = font.postScriptName else {
      throw ResourceParsingError.parsingFailed("No postscriptName associated to font at \(url)")
    }

    name = postScriptName as String
  }
}
