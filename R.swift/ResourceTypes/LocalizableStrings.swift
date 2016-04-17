//
//  LocalizableStrings.swift
//  R.swift
//
//  Created by Nolan Warner on 2016/02/23.
//  Copyright © 2016 Nolan Warner. All rights reserved.
//

import Foundation

struct LocalizableStrings: WhiteListedExtensionsResourceType {
  static let supportedExtensions: Set<String> = ["strings"]

  let locale: String?
  let dictionary: [String : String]

  init(url: NSURL) throws {
    try LocalizableStrings.throwIfUnsupportedExtension(url.pathExtension)

    // Set locale for file (second to last component)
    if let localeComponent = url.pathComponents?.dropLast().last where localeComponent.hasSuffix(".lproj") {
      locale = localeComponent.stringByReplacingOccurrencesOfString(".lproj", withString: "")
    } else {
      locale = nil
    }

    // Check to make sure url can be parsed as a dictionary
    guard let nsDictionary = NSDictionary(contentsOfURL: url) else {
      throw ResourceParsingError.ParsingFailed("Filename and/or extension could not be parsed from URL: \(url.absoluteString)")
    }

    // Parse strings from NSDictionary
    var dictionary: [String : String] = [:]
    for (key, obj) in nsDictionary {
      if let
        key = key as? String,
        val = obj as? String
      {
        dictionary[key] = val
      }
      else {
        throw ResourceParsingError.ParsingFailed("Non-string value in \(url.absoluteString): \(key) = \(obj)")
      }
    }

    self.dictionary = dictionary
  }
}
