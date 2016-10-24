//
//  LocalizableStrings.swift
//  R.swift
//
//  Created by Tom Lokhorst on 2016-04-24.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
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

  init(url: URL) throws {
    try LocalizableStrings.throwIfUnsupportedExtension(url.pathExtension)

    guard let filename = url.filename else {
      throw ResourceParsingError.parsingFailed("Couldn't extract filename without extension from URL: \(url)")
    }

    // Get locale from url (second to last component)
    let locale = Locale(url: url)

    // Check to make sure url can be parsed as a dictionary
    guard let nsDictionary = NSDictionary(contentsOf: url) else {
      throw ResourceParsingError.parsingFailed("Filename and/or extension could not be parsed from URL: \(url.absoluteString)")
    }

    // Parse dicts from NSDictionary
    let entries: [Entry]
    switch url.pathExtension {
    case "strings":
      entries = try parseStrings(String(contentsOf: url), source: locale.withFilename("\(filename).strings"))
    case "stringsdict":
      entries = try parseStringsdict(nsDictionary, source: locale.withFilename("\(filename).stringsdict"))
    default:
      throw ResourceParsingError.unsupportedExtension(givenExtension: url.pathExtension, supportedExtensions: LocalizableStrings.supportedExtensions)
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

private func parseStrings(_ stringsFile: String, source: String) throws -> [LocalizableStrings.Entry] {
  var entries: [LocalizableStrings.Entry] = []
  
  for parsed in StringsFileEntry.parse(stringsFile: stringsFile) {
    var params: [StringParam] = []
    
    for part in FormatPart.formatParts(formatString: parsed.val) {
      switch part {
      case .reference:
        throw ResourceParsingError.parsingFailed("Non-specifier reference in \(source): \(parsed.key) = \(parsed.val)")
        
      case .spec(let formatSpecifier):
        params.append(StringParam(name: nil, spec: formatSpecifier))
      }
    }
    
    entries.append(LocalizableStrings.Entry(key: parsed.key, val: parsed.val, params: params, comment: parsed.comment))
  }
  
  return entries
}


// MARK: -

private let unquotedStringCharacters: CharacterSet = {
  var set = CharacterSet.whitespacesAndNewlines
  set.invert()
  set.remove(charactersIn: "\\\"=;")
  return set
}()

private extension Scanner {
  func scan(_ s: String) -> Bool {
    return scanString(s, into: nil)
  }
  
  func scanUpTo(_ s: String) -> String? {
    var result: NSString?
    guard scanUpTo(s, into: &result) else { return nil }
    return result as String?
  }
  
  func scanCharacters(_ set: CharacterSet) -> String? {
    var result: NSString?
    guard scanCharacters(from: set as CharacterSet, into: &result) else { return nil }
    return result as String?
  }
  
  func scanComment() -> StringsFileEntry.Comment? {
    if scan("/*") {
      let result = scanUpTo("*/")
      _ = scan("*/")
      return .block(result ?? "")
    }
    else if scan("//") {
      let result = scanUpTo("\n")
      _ = scan("\n")
      return .line(result ?? "")
    }
    else {
      return nil
    }
  }
  
  func skipCommentsAndWhitespace() {
    while !isAtEnd {
      if scanComment() == nil &&
        scanCharacters(.whitespacesAndNewlines) == nil
      {
        return
      }
    }
  }
  
  func scanKeyOrValue() -> String? {
    if scan("\"") {
      var key = ""
      while let part = scanUpTo("\"") {
        key.append(part)
        _ = scan("\"")
        if part.characters.last == "\\" {
          key.append(Character("\""))
        } else {
          break
        }
      }
      do {
        let data = "\"\(key)\"".data(using: String.Encoding.utf8)!
        return try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? String
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
  
  static func mergeComments(_ comments: [Comment]) -> String? {
    guard !comments.isEmpty else { return nil }
    // TODO: something nicer
    return comments.map { $0.content }.joinWithSeparator(" ")
  }
  
  static func parse(stringsFile: String) -> [StringsFileEntry] {
    var entries: [StringsFileEntry] = []
    
    let scanner = Scanner(string: stringsFile)
    scanner.charactersToBeSkipped = nil
    scanner.caseSensitive = true
    
    while !scanner.isAtEnd {
      _ = scanner.scanCharacters(.whitespacesAndNewlines)
      
      var comments: [Comment] = []
      while let comment = scanner.scanComment() {
        comments.append(comment)
        
        if case .block = comment {
          break
        }
      }
      
      // Only comments directly above a string are desired.
      if let whitespace = scanner.scanCharacters(.whitespacesAndNewlines)
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
      
      _ = scanner.scanCharacters(.whitespaces)
      if let comment = scanner.scanComment() {
        comments.append(comment)
      }
      
      entries.append(StringsFileEntry(comment: mergeComments(comments), key: key, val: val))
    }
    
    return entries
  }
}

private func parseStringsdict(_ nsDictionary: NSDictionary, source: String) throws -> [LocalizableStrings.Entry] {

  var entries: [LocalizableStrings.Entry] = []

  for (key, obj) in nsDictionary {
    if let
      key = key as? String,
      let dict = obj as? [String: AnyObject]
    {
      guard let localizedFormat = dict["NSStringLocalizedFormatKey"] as? String else {
        continue
      }

      do {
        let params = try parseStringsdictParams(localizedFormat, dict: dict)
        entries.append(LocalizableStrings.Entry(key: key, val: localizedFormat, params: params, comment: nil))
      }
      catch ResourceParsingError.parsingFailed(let message) {
        warn("\(message) in '\(key)' \(source)")
      }
    }
    else {
      throw ResourceParsingError.parsingFailed("Non-dict value in \(source): \(key) = \(obj)")
    }
  }

  return entries
}

private func parseStringsdictParams(_ format: String, dict: [String: AnyObject]) throws -> [StringParam] {

  var params: [StringParam] = []

  let parts = FormatPart.formatParts(formatString: format)
  for part in parts {
    switch part {
    case .reference(let reference):
      params += try lookup(key: reference, in: dict)

    case .spec(let formatSpecifier):
      params.append(StringParam(name: nil, spec: formatSpecifier))
    }
  }

  return params
}

func lookup(key: String, in dict: [String: AnyObject], processedReferences: [String] = []) throws -> [StringParam] {
  var processedReferences = processedReferences

  if processedReferences.contains(key) {
    throw ResourceParsingError.parsingFailed("Cyclic reference '\(key)'")
  }

  processedReferences.append(key)

  guard let obj = dict[key], let nested = obj as? [String: AnyObject] else {
    throw ResourceParsingError.parsingFailed("Missing reference '\(key)'")
  }

  guard let formatSpecType = nested["NSStringFormatSpecTypeKey"] as? String,
    let formatValueType = nested["NSStringFormatValueTypeKey"] as? String
    , formatSpecType == "NSStringPluralRuleType"
  else {
    throw ResourceParsingError.parsingFailed("Incorrect reference '\(key)'")
  }
  guard let formatSpecifier = FormatSpecifier(formatString: formatValueType)
  else {
    throw ResourceParsingError.parsingFailed("Incorrect reference format specifier \"\(formatValueType)\" for '\(key)'")
  }

  var results = [StringParam(name: nil, spec: formatSpecifier)]

  let stringValues = nested.values.flatMap { $0 as? String }.sorted()

  for stringValue in stringValues {
    var alternative: [StringParam] = []
    let parts = FormatPart.formatParts(formatString: stringValue)
    for part in parts {
      switch part {
      case .reference(let reference):
        alternative += try lookup(key: reference, in: dict, processedReferences: processedReferences)

      case .spec(let formatSpecifier):
        alternative.append(StringParam(name: key, spec: formatSpecifier))
      }
    }

    if let unified = results.unify(alternative) {
      results = unified
    }
    else {
      throw ResourceParsingError.parsingFailed("Can't unify '\(key)'")
    }
  }

  return results
}
