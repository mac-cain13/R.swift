//
//  SwiftIdentifier.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 11-12-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

private let numberPrefixRegex = try! NSRegularExpression(pattern: "^[0-9]+")
private let upperCasedPrefixRegex = try! NSRegularExpression(pattern: "^([A-Z]+)(?=[^a-z]{1})")

/*
 Disallowed characters: whitespace, mathematical symbols, arrows, private-use and invalid Unicode points, line- and boxdrawing characters
 Special rules: Can't begin with a number
 */
struct SwiftIdentifier : CustomStringConvertible {
  let description: String

  init(name: String, lowercaseStartingCharacters: Bool = true) {
    // Remove all blacklisted characters from the name and uppercase the character after a blacklisted character
    var nameComponents = name.components(separatedBy: BlacklistedCharacters)
    let firstComponent = nameComponents.remove(at: 0)
    let cleanedSwiftName = nameComponents.reduce(firstComponent) { $0 + $1.uppercaseFirstCharacter }

    // Remove numbers at the start of the name
    let sanitizedSwiftName = numberPrefixRegex.stringByReplacingMatches(in: cleanedSwiftName, options: [], range: cleanedSwiftName.fullRange, withTemplate: "")

    // Lowercase the start of the name
    let capitalizedSwiftName = lowercaseStartingCharacters ? SwiftIdentifier.lowercasePrefix(sanitizedSwiftName) : sanitizedSwiftName

    // Escape the name if it is a keyword
    if SwiftKeywords.contains(capitalizedSwiftName) {
      description = "`\(capitalizedSwiftName)`"
    } else {
      description = capitalizedSwiftName
    }
  }

  init(rawValue: String) {
    description = rawValue
  }

  private static func lowercasePrefix(_ name: String) -> String {
    guard RswiftCore.isEdgeEnabled else {
      return name.lowercaseFirstCharacter
    }

    let prefixRange = upperCasedPrefixRegex.rangeOfFirstMatch(in: name, options: [], range: name.fullRange)

    if prefixRange.location == NSNotFound {
      return name.lowercaseFirstCharacter
    } else {
      let lowercasedPrefix = (name as NSString).substring(with: prefixRange).lowercased()
      return (name as NSString).replacingCharacters(in: prefixRange, with: lowercasedPrefix)
    }
  }
}

extension SwiftIdentifier : Hashable {
  var hashValue: Int {
    return description.hashValue
  }
}

func ==(lhs: SwiftIdentifier, rhs: SwiftIdentifier) -> Bool {
  return lhs.description == rhs.description
}

extension SwiftIdentifier : ExpressibleByStringLiteral {
  typealias StringLiteralType = String
  typealias UnicodeScalarLiteralType = String
  typealias ExtendedGraphemeClusterLiteralType = String

  init(stringLiteral value: StringLiteralType) {
    description = value

    if self != SwiftIdentifier(name: value, lowercaseStartingCharacters: false) {
      assertionFailure("'\(value)' not a correct SwiftIdentifier")
    }
  }

  init(unicodeScalarLiteral value: StringLiteralType) {
    description = value
  }

  init(extendedGraphemeClusterLiteral value: StringLiteralType) {
    description = value
  }

}

struct SwiftNameGroups<T> {
  let uniques: [T]
  let duplicates: [(SwiftIdentifier, [String])] // Identifiers that result in duplicate Swift names
  let empties: [String] // Identifiers (wrapped in quotes) that result in empty swift names

  func printWarningsForDuplicatesAndEmpties(source: String, container: String? = nil, result: String) {

    let sourceSingular = [source, container].flatMap { $0 }.joined(separator: " ")
    let sourcePlural = ["\(source)s", container].flatMap { $0 }.joined(separator: " ")

    let resultSingular = result
    let resultPlural = "\(result)s"

    for (sanitizedName, dups) in duplicates {
      warn("Skipping \(dups.count) \(sourcePlural) because symbol '\(sanitizedName)' would be generated for all of these \(resultPlural): \(dups.joined(separator: ", "))")
    }

    if let empty = empties.first , empties.count == 1 {
      warn("Skipping 1 \(sourceSingular) because no swift identifier can be generated for \(resultSingular): \(empty)")
    }
    else if empties.count > 1 {
      warn("Skipping \(empties.count) \(sourcePlural) because no swift identifier can be generated for all of these \(resultPlural): \(empties.joined(separator: ", "))")
    }
  }
}

extension Sequence {
  func groupedBySwiftIdentifier(_ identifierSelector: @escaping (Iterator.Element) -> String) -> SwiftNameGroups<Iterator.Element> {
    var groupedBy = grouped { SwiftIdentifier(name: identifierSelector($0)) }
    let empty = SwiftIdentifier(name: "")
    let empties = groupedBy[empty]?.map { "'\(identifierSelector($0))'" }.sorted()
    groupedBy[empty] = nil

    let uniques = Array(groupedBy.values.filter { $0.count == 1 }.flatten())
    let duplicates = groupedBy
      .filter { $0.1.count > 1 }
      .map { ($0.0, $0.1.map(identifierSelector).sorted()) }

    return SwiftNameGroups(uniques: uniques, duplicates: duplicates, empties: empties ?? [])
  }
}

private let BlacklistedCharacters: CharacterSet = {
  let blacklist = NSMutableCharacterSet(charactersIn: "")
  blacklist.formUnion(with: CharacterSet.whitespacesAndNewlines)
  blacklist.formUnion(with: CharacterSet.punctuationCharacters)
  blacklist.formUnion(with: CharacterSet.symbols)
  blacklist.formUnion(with: CharacterSet.illegalCharacters)
  blacklist.formUnion(with: CharacterSet.controlCharacters)
  blacklist.removeCharacters(in: "_")

  // Emoji ranges, roughly based on http://www.unicode.org/Public/emoji/1.0//emoji-data.txt
  [
    0x2600...0x27BF,
    0x1F300...0x1F6FF,
    0x1F900...0x1F9FF,
    0x1F1E6...0x1F1FF,
  ].forEach {
    let range = NSRange(location: $0.lowerBound, length: $0.upperBound - $0.lowerBound)
    blacklist.removeCharacters(in: range)
  }

  return blacklist as CharacterSet
}()

// Based on https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/LexicalStructure.html#//apple_ref/doc/uid/TP40014097-CH30-ID413
private let SwiftKeywords = [
  // Keywords used in declarations
  "associatedtype", "class", "deinit", "enum", "extension", "fileprivate", "func", "import", "init", "inout", "internal", "let", "open", "operator", "private", "protocol", "public", "static", "struct", "subscript", "typealias", "var",

  // Keywords used in statements
  "break", "case", "continue", "default", "defer", "do", "else", "fallthrough", "for", "guard", "if", "in", "repeat", "return", "switch", "where", "while",

  // Keywords used in expressions and types
  "as", "Any", "catch", "false", "is", "nil", "rethrows", "super", "self", "Self", "throw", "throws", "true", "try",

  // Keywords that begin with a number sign (#)
  "#available", "#colorLiteral", "#column", "#else", "#elseif", "#endif", "#file", "#fileLiteral", "#function", "#if", "#imageLiteral", "#line", "#selector", "#sourceLocation",

  // Keywords from Swift 2 that are still reserved
  "__COLUMN__", "__FILE__", "__FUNCTION__", "__LINE__",
]

