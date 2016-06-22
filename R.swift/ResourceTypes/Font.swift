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

  init(url: NSURL) throws {
    try Font.throwIfUnsupportedExtension(url.pathExtension)

    guard let dataProvider = CGDataProviderCreateWithURL(url) else {
      throw ResourceParsingError.ParsingFailed("Unable to create data provider for font at \(url)")
    }
    let font = CGFontCreateWithDataProvider(dataProvider)

    guard let postScriptName = CGFontCopyPostScriptName(font) else {
      throw ResourceParsingError.ParsingFailed("No postscriptName associated to font at \(url)")
    }

    name = postScriptName as String
  }
}
