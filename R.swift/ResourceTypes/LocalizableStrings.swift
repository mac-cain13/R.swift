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
  let dictionary: [String : (params: [StringParam], commentValue: String)]

  init(filename: String, locale: Locale, dictionary: [String : (params: [StringParam], commentValue: String)]) {
    self.filename = filename
    self.locale = locale
    self.dictionary = dictionary
  }

  init(url: URL) throws {
    try LocalizableStrings.throwIfUnsupportedExtension(url.pathExtension)

    guard let filename = url.filename else {
      throw ResourceParsingError.ParsingFailed("Couldn't extract filename without extension from URL: \(url)")
    }

    // Get locale from url (second to last component)
    let locale = Locale(url: url)

    // Check to make sure url can be parsed as a dictionary
    guard let nsDictionary = NSDictionary(contentsOf: url) else {
      throw ResourceParsingError.ParsingFailed("Filename and/or extension could not be parsed from URL: \(url.absoluteString)")
    }

    // Parse dicts from NSDictionary
    let dictionary: [String : (params: [StringParam], commentValue: String)]
    switch url.pathExtension {
    case "strings"?:
      dictionary = try parseStrings(nsDictionary, source: locale.with(filename: "\(filename).strings"))
    case "stringsdict"?:
      dictionary = try parseStringsdict(nsDictionary, source: locale.with(filename: "\(filename).stringsdict"))
    default:
      throw ResourceParsingError.UnsupportedExtension(givenExtension: url.pathExtension, supportedExtensions: LocalizableStrings.supportedExtensions)
    }

    self.filename = filename
    self.locale = locale
    self.dictionary = dictionary
  }
}

private func parseStrings(_ nsDictionary: NSDictionary, source: String) throws -> [String : (params: [StringParam], commentValue: String)] {
  var dictionary: [String : (params: [StringParam], commentValue: String)] = [:]

  for (key, obj) in nsDictionary {
    if let
      key = key as? String,
      val = obj as? String
    {
      var params: [StringParam] = []

      for part in FormatPart.formatParts(formatString: val) {
        switch part {
        case .Reference:
          throw ResourceParsingError.ParsingFailed("Non-specifier reference in \(source): \(key) = \(val)")

        case .Spec(let formatSpecifier):
          params.append(StringParam(name: nil, spec: formatSpecifier))
        }
      }


      dictionary[key] = (params, val)
    }
    else {
      throw ResourceParsingError.ParsingFailed("Non-string value in \(source): \(key) = \(obj)")
    }
  }

  return dictionary
}

private func parseStringsdict(_ nsDictionary: NSDictionary, source: String) throws -> [String : (params: [StringParam], commentValue: String)] {

  var dictionary: [String : (params: [StringParam], commentValue: String)] = [:]

  for (key, obj) in nsDictionary {
    if let
      key = key as? String,
      dict = obj as? [String: AnyObject]
    {
      guard let localizedFormat = dict["NSStringLocalizedFormatKey"] as? String else {
        continue
      }

      do {
        let params = try parseStringsdictParams(format: localizedFormat, dict: dict)
        dictionary[key] = (params, localizedFormat)
      }
      catch ResourceParsingError.ParsingFailed(let message) {
        warn(warning: "\(message) in '\(key)' \(source)")
      }
    }
    else {
      throw ResourceParsingError.ParsingFailed("Non-dict value in \(source): \(key) = \(obj)")
    }
  }

  return dictionary
}

private func parseStringsdictParams(format: String, dict: [String: AnyObject]) throws -> [StringParam] {

  var params: [StringParam] = []

  let parts = FormatPart.formatParts(formatString: format)
  for part in parts {
    switch part {
    case .Reference(let reference):
      params += try lookup(reference, in: dict)

    case .Spec(let formatSpecifier):
      params.append(StringParam(name: nil, spec: formatSpecifier))
    }
  }

  return params
}

func lookup(_ key: String, in dict: [String: AnyObject], with processedReferences: [String] = []) throws -> [StringParam] {
  var processedReferences = processedReferences

  if processedReferences.contains(key) {
    throw ResourceParsingError.ParsingFailed("Cyclic reference '\(key)'")
  }

  processedReferences.append(key)

  guard let obj = dict[key], nested = obj as? [String: AnyObject] else {
    throw ResourceParsingError.ParsingFailed("Missing reference '\(key)'")
  }

  guard let formatSpecType = nested["NSStringFormatSpecTypeKey"] as? String,
    formatValueType = nested["NSStringFormatValueTypeKey"] as? String
    where formatSpecType == "NSStringPluralRuleType"
  else {
    throw ResourceParsingError.ParsingFailed("Incorrect reference '\(key)'")
  }
  guard let formatSpecifier = FormatSpecifier(formatString: formatValueType)
  else {
    throw ResourceParsingError.ParsingFailed("Incorrect reference format specifier \"\(formatValueType)\" for '\(key)'")
  }

  var results = [StringParam(name: nil, spec: formatSpecifier)]

  let stringValues = nested.values.flatMap { $0 as? String }

  for stringValue in stringValues {
    var alternative: [StringParam] = []
    let parts = FormatPart.formatParts(formatString: stringValue)
    for part in parts {
      switch part {
      case .Reference(let reference):
        alternative += try lookup(reference, in: dict, with: processedReferences)

      case .Spec(let formatSpecifier):
        alternative.append(StringParam(name: key, spec: formatSpecifier))
      }
    }

    if let unified = results.unify(with: alternative) {
      results = unified
    }
    else {
      throw ResourceParsingError.ParsingFailed("Can't unify '\(key)'")
    }
  }

  return results
}
