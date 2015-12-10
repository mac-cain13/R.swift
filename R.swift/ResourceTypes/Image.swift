//
//  Image.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 09-12-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import Foundation

struct Image {
  let name: String

  init(url: NSURL) throws {
    guard let pathExtension = url.pathExtension?.lowercaseString where ImageExtensions.contains(pathExtension) else {
      throw ResourceParsingError.UnsupportedExtension(givenExtension: url.pathExtension, supportedExtensions: ImageExtensions)
    }

    guard let filename = url.lastPathComponent else {
      throw ResourceParsingError.ParsingFailed("Filename could not be parsed from URL: \(url.absoluteString)")
    }

    let extensions = ImageExtensions.joinWithSeparator("|")
    let regex = try! NSRegularExpression(pattern: "(~(ipad|iphone))?(@[2,3]x)?\\.(\(extensions))$", options: .CaseInsensitive)
    let fullFileNameRange = NSRange(location: 0, length: filename.characters.count)
    let pathExtensionToUse = (pathExtension == "png") ? "" : ".\(pathExtension)"
    name = regex.stringByReplacingMatchesInString(filename, options: NSMatchingOptions(rawValue: 0), range: fullFileNameRange, withTemplate: pathExtensionToUse)
  }
}
