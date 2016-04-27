//
//  LocalizableStrings.swift
//  R.swift
//
//  Created by Nolan Warner on 2016/02/23.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

enum Locale {
  case None
  case Base
  case Language(String)

  var isBase: Bool {
    if case .Base = self {
      return true
    }

    return false
  }

  var isNone: Bool {
    if case .None = self {
      return true
    }

    return false
  }
}

extension Locale {
  var localeDescription: String? {
    switch self {
    case .None:
      return nil

    case .Base:
      return "Base"

    case .Language(let language):
      return language
    }
  }
}

struct LocalizableStrings: WhiteListedExtensionsResourceType {
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
    var locale = Locale.None
    if let localeComponent = url.pathComponents?.dropLast().last where localeComponent.hasSuffix(".lproj") {
      let lang = localeComponent.stringByReplacingOccurrencesOfString(".lproj", withString: "")

      if lang == "Base" {
        locale = .Base
      }
      else {
        locale = .Language(lang)
      }
    }

    // Check to make sure url can be parsed as a dictionary
    guard let nsDictionary = NSDictionary(contentsOfURL: url) else {
      throw ResourceParsingError.ParsingFailed("Filename and/or extension could not be parsed from URL: \(url.absoluteString)")
    }

    // Parse strings from NSDictionary
    var dictionary: [String : (value: String, params: [FormatSpecifier])] = [:]
    for (key, obj) in nsDictionary {
      if let
        key = key as? String,
        val = obj as? String
      {
        dictionary[key] = (val, FormatSpecifier.formatSpecifiersFromFormatString(val))
      }
      else {
        throw ResourceParsingError.ParsingFailed("Non-string value in \(url.absoluteString): \(key) = \(obj)")
      }
    }

    self.filename = filename
    self.locale = locale
    self.dictionary = dictionary
  }
}
