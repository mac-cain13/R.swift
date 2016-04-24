//
//  LocalizableStrings.swift
//  R.swift
//
//  Created by Tom Lokhorst on 2016-04-24.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

struct LocalizableStrings : WhiteListedExtensionsResourceType {
  static let supportedExtensions: Set<String> = ["strings", "stringsdict"]

  let filename: String
  let locale: Locale
  let dictionary: [String : (value: String, params: [FormatSpecifier])]

  init(filename: String, locale: Locale, dictionary: [String : (value: String, params: [FormatSpecifier])]) {
    self.filename = filename
    self.locale = locale
    self.dictionary = dictionary
  }

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
    let dictionary: [String : (value: String, params: [FormatSpecifier])]
    switch url.pathExtension {
    case "strings"?:
      dictionary = try parseStrings(nsDictionary, source: url.absoluteString)
    case "stringsdict"?:
      dictionary = try parseStringsdict(nsDictionary, source: url.absoluteString)
    default:
      throw ResourceParsingError.UnsupportedExtension(givenExtension: url.pathExtension, supportedExtensions: LocalizableStrings.supportedExtensions)
    }

    self.filename = filename
    self.locale = locale
    self.dictionary = dictionary
  }
}

private func parseStrings(nsDictionary: NSDictionary, source: String) throws -> [String : (value: String, params: [FormatSpecifier])] {
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

private func parseStringsdict(nsDictionary: NSDictionary, source: String) throws -> [String : (value: String, params: [FormatSpecifier])] {
  var dictionary: [String : (value: String, params: [FormatSpecifier])] = [:]

  for (key, obj) in nsDictionary {
    if let
      key = key as? String,
      val = obj as? [String: AnyObject]
    {
      let localizedFormat = val["NSStringLocalizedFormatKey"] as! String

      var params: [(String, FormatSpecifier)] = []
      for (paramName, dict) in val where paramName != "NSStringLocalizedFormatKey" {
        if let paramDict = dict as? [String: String] {
          guard let specType = paramDict["NSStringFormatSpecTypeKey"] where specType == "NSStringPluralRuleType" else {
            throw ResourceParsingError.ParsingFailed("Missing NSStringFormatSpecTypeKey=NSStringPluralRuleType in \(source): \(key).\(paramName)")
          }

          if let valueType = paramDict["NSStringFormatValueTypeKey"] {
            if let char = valueType.characters.last,
              formatSpecifier = FormatSpecifier(formatChar: char)
            {
              params.append((paramName, formatSpecifier))
            }
            else {
              throw ResourceParsingError.ParsingFailed("Can't parse format specifier `\(valueType)` in \(source): \(key).\(paramName)")
            }
          }
        }
        else {
          throw ResourceParsingError.ParsingFailed("Non-dict param in \(source): \(key).\(paramName)")
        }
      }

      dictionary[key] = (localizedFormat, params.map { $0.1 })
    }
    else {
      throw ResourceParsingError.ParsingFailed("Non-dict value in \(source): \(key) = \(obj)")
    }
  }

  return dictionary
}
