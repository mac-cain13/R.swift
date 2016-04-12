//
//  Strings.swift
//  R.swift
//
//  Created by Nolan Warner on 2016/02/23.
//  Copyright © 2016 Nolan Warner. All rights reserved.
//

import Foundation

struct Strings: WhiteListedExtensionsResourceType {
  static let supportedExtensions: Set<String> = ["strings"]

  let localizedKeys: LocalizedKeys

  init(keys: [String] = []) {
    localizedKeys = LocalizedKeys(locale: nil, keys: keys)
  }

  init(url: NSURL) throws {
    try Strings.throwIfUnsupportedExtension(url.pathExtension)

    // Check to make sure url can be parsed as a dictionary
    guard let _ = NSDictionary(contentsOfURL: url) else {
      throw ResourceParsingError.ParsingFailed("Filename and/or extension could not be parsed from URL: \(url.absoluteString)")
    }

    // Parse url as string to get instances of duplicate keys
    let fileContents: String
    do {
      fileContents = try String(contentsOfURL: url, encoding: NSUTF8StringEncoding)
    } catch {
      throw ResourceParsingError.ParsingFailed("Filename and/or extension could not be parsed from URL: \(url.absoluteString)")
    }

    // Set localized string keys
    let keys = fileContents.componentsSeparatedByString("\n").map(keyWithLine).filter { !$0.isEmpty }
    let locale: String?

    // Set locale for file (second to last component)
    if let localeComponent = url.pathComponents?.dropLast().last where localeComponent.containsString("lproj") {
      locale = localeComponent
    } else {
      locale = nil
    }

    localizedKeys = LocalizedKeys(locale: locale, keys: keys)
  }
}

struct LocalizedKeys {
  let locale: String?
  let keys: [String]

  init(locale: String? = nil, keys: [String] = []) {
    self.locale = locale
    self.keys = keys
  }

  func mergeWith(missingKey: LocalizedKeys) -> LocalizedKeys {
    let lhsKeySet = Set(keys)
    let rhsKeySet = Set(missingKey.keys)
    let mergedKeySet = lhsKeySet.union(rhsKeySet)
    let mergedKeys = Array(mergedKeySet)

    return LocalizedKeys(locale: locale, keys: mergedKeys)
  }
}

// MARK: - Parser Methods

/**
 Matches strings formatted in the valid Localizable.strings syntax.

 Regex: ^\s*"(.*?)"\s*?=\s*?"(.*)"\s*;$

 Examples of matched strings:

 "key" = "value";
 "key.with-delimiter.symbols_and spaces" = "Must end in a semicolon";

 Example of unmatched strings:

 // "commented out lines" = "value";
 "lines that don't end with a semicolon" = "value"
 */
private let ValidStringPattern = "^\\s*\"(.*?)\"\\s*?=\\s*?\"(.*)\"\\s*;$"

private func keyWithLine(line: String) -> String {
  guard let match = matchWithLine(line) else { return "" }

  return (line as NSString).substringWithRange(match.rangeAtIndex(1))
}

private func matchWithLine(line: String) -> NSTextCheckingResult? {
  let regex: NSRegularExpression?
  do {
    regex = try NSRegularExpression(pattern: ValidStringPattern, options: .AnchorsMatchLines)
  } catch {
    regex = nil
  }

  let range = NSRange(location: 0, length: line.characters.count)

  return regex?.firstMatchInString(line, options: .ReportCompletion, range: range)
}

// MARK: - String Validation

struct StringValidator {
  let strings: Strings
  let missingKeys: [LocalizedKeys]
  let duplicateKeys: [LocalizedKeys]

  init(strings: Strings = Strings(),
    missingKeys: [LocalizedKeys] = [],
    duplicateKeys: [LocalizedKeys] = []) {
      self.strings = strings
      self.missingKeys = missingKeys
      self.duplicateKeys = duplicateKeys
  }

  // MARK: - Validation Parser Methods

  static func combine(acc: StringValidator, next: Strings) -> StringValidator {
    let combinedStrings = getStrings(lhs: acc.strings, rhs: next)
    let missingKeys = getMissingKeys(lhs: acc.strings, rhs: next, currentMissingKeys: acc.missingKeys)
    let duplicateKeys = getDuplicateKeys(next, currentDuplicateKeys: acc.duplicateKeys)

    return StringValidator(strings: combinedStrings, missingKeys: missingKeys, duplicateKeys: duplicateKeys)
  }

  static func getStrings(lhs lhs: Strings, rhs: Strings) -> Strings {
    // Get key sets from accumulator and next
    let lhsKeySet = Set(lhs.localizedKeys.keys)
    let rhsKeySet = Set(rhs.localizedKeys.keys)

    // Take union to get common elements
    let unionSet = lhsKeySet.union(rhsKeySet)

    return Strings(keys: Array(unionSet))
  }

  static func getMissingKeys(lhs lhs: Strings, rhs: Strings, currentMissingKeys: [LocalizedKeys]) -> [LocalizedKeys] {
    // Convert key arrays to sets to remove keys and to prepare for merging
    let lhsKeySet = Set(lhs.localizedKeys.keys)
    let rhsKeySet = Set(rhs.localizedKeys.keys)

    // Extract exclusive keys for both lhs and rhs with set subtraction
    let missingLhsSet = rhsKeySet.subtract(lhsKeySet)
    let missingRhsSet = lhsKeySet.subtract(rhsKeySet)

    // Create LocalizedKeySet for each missing key set
    let missingLhsKeys = LocalizedKeys(locale: lhs.localizedKeys.locale, keys: Array(missingLhsSet))
    let missingRhsKeys = LocalizedKeys(locale: rhs.localizedKeys.locale, keys: Array(missingRhsSet))

    // Merge current sets with new sets
    return currentMissingKeys.map { $0.mergeWith(missingLhsKeys) } + [missingRhsKeys]
  }

  static func getDuplicateKeys(strings: Strings, currentDuplicateKeys: [LocalizedKeys]) -> [LocalizedKeys] {
    let duplicateKeys = strings.localizedKeys.keys.filter { key in
      return strings.localizedKeys.keys.filter { $0 == key }.count > 1
    }
    let localizedKeys = LocalizedKeys(locale: strings.localizedKeys.locale, keys: duplicateKeys)

    return currentDuplicateKeys + [localizedKeys]
  }

  // MARK: - Validation Error Printing Methods

  func validStrings() -> Strings {
    showMissingKeysWarning()
    showDuplicateKeysWarning()

    return strings
  }

  private func showMissingKeysWarning() {
    missingKeys.forEach { missingKey in
      if missingKey.keys.isEmpty { return }

      if let locale = missingKey.locale {
        let paddedKeys = missingKey.keys.sort().map { "'\($0)'" }
        let paddedKeysString = paddedKeys.joinWithSeparator(", ")
        warn("Locale '\(locale)' is missing translations for keys: [\(paddedKeysString)]")
      }
    }
  }

  private func showDuplicateKeysWarning() {
    duplicateKeys.forEach { duplicateKey in
      if duplicateKey.keys.isEmpty { return }

      let paddedKeys = Set(duplicateKey.keys).sort().map { "'\($0)'" }
      let paddedKeysString = paddedKeys.joinWithSeparator(", ")
      if let locale = duplicateKey.locale {
        warn("Locale '\(locale)' has multiple translations for keys: [\(paddedKeysString)]")
      } else {
        warn("Multiple translations for keys: [\(paddedKeysString)]")
      }
    }
  }
}
