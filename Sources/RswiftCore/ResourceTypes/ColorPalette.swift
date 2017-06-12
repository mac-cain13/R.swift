//
//  ColorPalete.swift
//  R.swift
//
//  Created by Tom Lokhorst on 2016-03-13.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
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
    guard let colorList = NSColorList(name: NSColorList.Name(rawValue: ""), fromFile: url.path) else {
      throw ResourceParsingError.parsingFailed("Couldn't parse as color palette: \(url)")
    }

    var colors: [String: NSColor] = [:]
    for key in colorList.allKeys {
      guard let color = colorList.color(withKey: key) else { continue }
      guard color.colorSpaceName == NSColorSpaceName.calibratedRGB else {
        warn("Skipping color '\(key)' in '\(url.lastPathComponent)' because it is colorspace '\(color.colorSpace.description)', R.swift currently only supports colorspace RGB")
        continue
      }

      colors[key.rawValue] = color
    }

    self.filename = filename
    self.colors = colors
  }
}
