//
//  Image.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 09-12-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

struct Image: WhiteListedExtensionsResourceType {
  // See "Supported Image Formats" on https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIImage_Class/
  static let supportedExtensions: Set<String> = ["tiff", "tif", "jpg", "jpeg", "gif", "png", "bmp", "bmpf", "ico", "cur", "xbm"]

  let name: String

  init(url: URL) throws {
    try Image.throwIfUnsupportedExtension(url.pathExtension)

    let filename = url.lastPathComponent
    let pathExtension = url.pathExtension
    guard filename.count > 0 && pathExtension.count > 0 else {
      throw ResourceParsingError.parsingFailed("Filename and/or extension could not be parsed from URL: \(url.absoluteString)")
    }

    let extensions = Image.supportedExtensions.joined(separator: "|")
    let regex = try! NSRegularExpression(pattern: "(~(ipad|iphone))?(@[2,3]x)?\\.(\(extensions))$", options: .caseInsensitive)
    let fullFileNameRange = NSRange(location: 0, length: filename.count)
    let pathExtensionToUse = (pathExtension == "png") ? "" : ".\(pathExtension)"
    name = regex.stringByReplacingMatches(in: filename, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: fullFileNameRange, withTemplate: pathExtensionToUse)
  }
}
