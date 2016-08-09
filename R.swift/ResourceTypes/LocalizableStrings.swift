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
  let entries: [Entry]

  init(filename: String, locale: Locale, entries: [Entry]) {
    self.filename = filename
    self.locale = locale
    self.entries = entries
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
    let entries: [Entry]
    switch url.pathExtension {
    case "strings"?:
      entries = try parseStrings(String(contentsOfURL: url), source: locale.withFilename("\(filename).strings"))
    case "stringsdict"?:
      entries = try parseStringsdict(nsDictionary, source: locale.withFilename("\(filename).stringsdict"))
    default:
      throw ResourceParsingError.UnsupportedExtension(givenExtension: url.pathExtension, supportedExtensions: LocalizableStrings.supportedExtensions)
    }

    self.filename = filename
    self.locale = locale
    self.entries = entries
  }
  
  var keys: [String] {
    return entries.map { $0.key }
  }
  
  struct Entry {
    let key: String
    let val: String
    let params: [StringParam]
    let comment: String?
  }
}

private func parseStrings(stringsFile: String, source: String) throws -> [LocalizableStrings.Entry] {
  var entries: [LocalizableStrings.Entry] = []
  
  for parsed in StringsFileEntry.parse(stringsFile) {
    var params: [StringParam] = []
    
    for part in FormatPart.formatParts(formatString: parsed.val) {
      switch part {
      case .Reference:
        throw ResourceParsingError.ParsingFailed("Non-specifier reference in \(source): \(parsed.key) = \(parsed.val)")
        
      case .Spec(let formatSpecifier):
        params.append(StringParam(name: nil, spec: formatSpecifier))
      }
    }
    
    entries.append(LocalizableStrings.Entry(key: parsed.key, val: parsed.val, params: params, comment: parsed.comment))
  }
  
  return entries
}

// MARK: -

private let unquotedStringCharacters: NSCharacterSet = {
  let set = NSMutableCharacterSet.whitespaceAndNewlineCharacterSet()
  set.invert()
  set.removeCharactersInString("\\\"=;")
  return set
}()

private extension NSScanner {
  func scan(s: String) -> Bool {
    return scanString(s, intoString: nil)
  }
  
  func scanUpTo(s: String) -> String? {
    var result: NSString?
    guard scanUpToString(s, intoString: &result) else { return nil }
    return result as String?
  }
  
  func scanCharacters(set: NSCharacterSet) -> String? {
    var result: NSString?
    guard scanCharactersFromSet(set, intoString: &result) else { return nil }
    return result as String?
  }
  
  func scanComment() -> StringsFileEntry.Comment? {
    if scan("/*") {
      let result = scanUpTo("*/")
      scan("*/")
      return .block(result ?? "")
    }
    else if scan("//") {
      let result = scanUpTo("\n")
      scan("\n")
      return .line(result ?? "")
    }
    else {
      return nil
    }
  }
  
  func skipCommentsAndWhitespace() {
    while !atEnd {
      if scanComment() == nil &&
        scanCharacters(.whitespaceAndNewlineCharacterSet()) == nil
      {
        return
      }
    }
  }
  
  func scanKeyOrValue() -> String? {
    if scan("\"") {
      var key = ""
      while let part = scanUpTo("\"") {
        key.appendContentsOf(part)
        scan("\"")
        if part.characters.last == "\\" {
          key.append(Character("\""))
        } else {
          break
        }
      }
      do {
        let data = "\"\(key)\"".dataUsingEncoding(NSUTF8StringEncoding)!
        return try NSPropertyListSerialization.propertyListWithData(data, options: [], format: nil) as? String
      } catch {
        return nil
      }
    }
    else if let part = scanCharacters(unquotedStringCharacters) {
      return part
    }
    else {
      return nil
    }
  }
}

private struct StringsFileEntry {
  let comment: String?
  let key: String
  let val: String
  
  enum Comment {
    case block(String)
    case line(String)
    
    var content: String {
      switch self {
      case .block(let content): return content
      case .line(let content): return content
      }
    }
  }
  
  static func mergeComments(comments: [Comment]) -> String? {
    guard !comments.isEmpty else { return nil }
    // TODO: something nicer
    return comments.map { $0.content }.joinWithSeparator(" ")
  }
  
  static func parse(stringsFile: String) -> [StringsFileEntry] {
    var entries: [StringsFileEntry] = []
    
    let scanner = NSScanner(string: stringsFile)
    scanner.charactersToBeSkipped = nil
    scanner.caseSensitive = true
    
    while !scanner.atEnd {
      scanner.scanCharacters(.whitespaceAndNewlineCharacterSet())
      
      var comments: [Comment] = []
      while let comment = scanner.scanComment() {
        comments.append(comment)
        
        if case .block = comment {
          break
        }
      }
      
      // Only comments directly above a string are desired.
      if let whitespace = scanner.scanCharacters(.whitespaceAndNewlineCharacterSet())
      {
        var newlines = whitespace.characters.filter({ $0 == "\n" }).count
        if case .line? = comments.last {
          newlines += 1
        }
        if newlines > 1 {
          continue
        }
      }
      
      guard let key = scanner.scanKeyOrValue() else { continue }
      
      scanner.skipCommentsAndWhitespace()
      
      guard scanner.scan("=") else { continue }
      
      scanner.skipCommentsAndWhitespace()
      
      guard let val = scanner.scanKeyOrValue() else { continue }
      
      scanner.skipCommentsAndWhitespace()
      
      guard scanner.scan(";") else { continue }
      
      scanner.scanCharacters(.whitespaceCharacterSet())
      if let comment = scanner.scanComment() {
        comments.append(comment)
      }
      
      entries.append(StringsFileEntry(comment: mergeComments(comments), key: key, val: val))
    }
    
    return entries
  }
}

private func parseStringsdict(nsDictionary: NSDictionary, source: String) throws -> [LocalizableStrings.Entry] {

  var entries: [LocalizableStrings.Entry] = []

  for (key, obj) in nsDictionary {
    if let
      key = key as? String,
      dict = obj as? [String: AnyObject]
    {
      guard let localizedFormat = dict["NSStringLocalizedFormatKey"] as? String else {
        continue
      }

      do {
        let params = try parseStringsdictParams(localizedFormat, dict: dict)
        entries.append(LocalizableStrings.Entry(key: key, val: localizedFormat, params: params, comment: nil))
      }
      catch ResourceParsingError.ParsingFailed(let message) {
        warn("\(message) in '\(key)' \(source)")
      }
    }
    else {
      throw ResourceParsingError.ParsingFailed("Non-dict value in \(source): \(key) = \(obj)")
    }
  }

  return entries
}

private func parseStringsdictParams(format: String, dict: [String: AnyObject]) throws -> [StringParam] {

  var params: [StringParam] = []

  let parts = FormatPart.formatParts(formatString: format)
  for part in parts {
    switch part {
    case .Reference(let reference):
      params += try lookup(reference, dict: dict)

    case .Spec(let formatSpecifier):
      params.append(StringParam(name: nil, spec: formatSpecifier))
    }
  }

  return params
}

func lookup(key: String, dict: [String: AnyObject], processedReferences: [String] = []) throws -> [StringParam] {
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
        alternative += try lookup(reference, dict: dict, processedReferences: processedReferences)

      case .Spec(let formatSpecifier):
        alternative.append(StringParam(name: key, spec: formatSpecifier))
      }
    }

    if let unified = results.unify(alternative) {
      results = unified
    }
    else {
      throw ResourceParsingError.ParsingFailed("Can't unify '\(key)'")
    }
  }

  return results
}
