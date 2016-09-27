//
//  ColorPalete.swift
//  R.swift
//
//  Created by Tom Lokhorst on 2016-03-13.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation
import AppKit.NSColor

struct ColorPalette: WhiteListedExtensionsResourceType {
  static let supportedExtensions: Set<String> = ["clr"]

  let filename: String
  let colors: [String: NSColor]

  init(url: URL) throws {
    try ColorPalette.throwIfUnsupportedExtension(url.pathExtension)

    guard let filename = url.filename else {
      throw ResourceParsingError.parsingFailed("Couldn't extract filename without extension from URL: \(url)")
    }
    guard let colorList = NSColorList(name: "", fromFile: url.path) else {
      throw ResourceParsingError.parsingFailed("Couldn't parse as color palette: \(url)")
    }

    var colors: [String: NSColor] = [:]
    for key in colorList.allKeys {
      colors[key] = colorList.color(withKey: key)?.usingColorSpaceName(NSCalibratedRGBColorSpace)
    }

    self.filename = filename
    self.colors = colors
  }
}
