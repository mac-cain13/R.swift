//
//  Image.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 09-12-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import Foundation

struct Image: WhiteListedExtensionsResourceType {
  // See "Supported Image Formats" on https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIImage_Class/
  static let supportedExtensions: Set<String> = ["tiff", "tif", "jpg", "jpeg", "gif", "png", "bmp", "bmpf", "ico", "cur", "xbm"]

  let name: String

  init(url: NSURL) throws {
    try Image.throwIfUnsupportedExtension(url.pathExtension)

    guard let filename = url.lastPathComponent, pathExtension = url.pathExtension else {
      throw ResourceParsingError.ParsingFailed("Filename and/or extension could not be parsed from URL: \(url.absoluteString)")
    }

    let extensions = Image.supportedExtensions.joinWithSeparator("|")
    let regex = try! NSRegularExpression(pattern: "(~(ipad|iphone))?(@[2,3]x)?\\.(\(extensions))$", options: .CaseInsensitive)
    let fullFileNameRange = NSRange(location: 0, length: filename.characters.count)
    let pathExtensionToUse = (pathExtension == "png") ? "" : ".\(pathExtension)"
    name = regex.stringByReplacingMatchesInString(filename, options: NSMatchingOptions(rawValue: 0), range: fullFileNameRange, withTemplate: pathExtensionToUse)
  }
}
