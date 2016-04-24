//
//  LocalizableStrings.swift
//  R.swift
//
//  Created by Nolan Warner on 2016/02/23.
//  Copyright © 2016 Nolan Warner. All rights reserved.
//

import Foundation

struct LocalizableStrings : WhiteListedExtensionsResourceType {
  static let supportedExtensions: Set<String> = ["strings"]

  let filename: String
  let locale: Locale
  let dictionary: [String : (value: String, params: [FormatSpecifier])]

  init(url: NSURL) throws {
    try LocalizableStrings.throwIfUnsupportedExtension(url.pathExtension)

    guard let filename = url.filename else {
      throw ResourceParsingError.ParsingFailed("Couldn't extract filename without extension from URL: \(url)")
    }

    // Get locale from url (second to last component)
    let locale = Locale(url: url)

    // Check to make sure url can be parsed as a dictionary
    guard let nsDictionary = NSDictionary(contentsOfURL: url) else {
      throw ResourceParsingError.ParsingFailed("Filename and/or extension could not be parsed from URL: \(url.absoluteString)")
    }

    // Parse dicts from NSDictionary
    let dictionary = try parseDictionary(nsDictionary, source: url.absoluteString)

    self.filename = filename
    self.locale = locale
    self.dictionary = dictionary
  }
}

private func parseDictionary(nsDictionary: NSDictionary, source: String) throws -> [String : (value: String, params: [FormatSpecifier])] {
  var dictionary: [String : (value: String, params: [FormatSpecifier])] = [:]

  for (key, obj) in nsDictionary {
    if let
      key = key as? String,
      val = obj as? String
    {
      dictionary[key] = (val, FormatSpecifier.formatSpecifiersFromFormatString(val))
    }
    else {
      throw ResourceParsingError.ParsingFailed("Non-string value in \(source): \(key) = \(obj)")
    }
  }

  return dictionary
}
