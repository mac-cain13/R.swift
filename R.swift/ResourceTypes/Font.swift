//
//  Font.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 09-12-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import Foundation

struct Font {
  let name: String

  init(url: NSURL) throws {
    guard let pathExtension = url.pathExtension where FontExtensions.contains(pathExtension) else {
      throw ResourceParsingError.UnsupportedExtension(givenExtension: url.pathExtension, supportedExtensions: FontExtensions)
    }

    let dataProvider = CGDataProviderCreateWithURL(url)
    let font = CGFontCreateWithDataProvider(dataProvider)

    guard let postScriptName = CGFontCopyPostScriptName(font) else {
      throw ResourceParsingError.ParsingFailed("No postscriptName associated to font at \(url)")
    }

    name = postScriptName as String
  }
}
