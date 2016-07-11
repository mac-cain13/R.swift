//
//  SanitizedSwiftName.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 11-12-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import Foundation

/*
Disallowed characters: whitespace, mathematical symbols, arrows, private-use and invalid Unicode points, line- and boxdrawing characters
Special rules: Can't begin with a number
*/
func sanitizedSwiftName(_ name: String, lowercaseFirstCharacter: Bool = true) -> String {
  var nameComponents = name.components(separatedBy: BlacklistedCharacters)

  let firstComponent = nameComponents.remove(at: 0)
  let cleanedSwiftName = nameComponents.reduce(firstComponent) { $0 + $1.uppercaseFirstCharacter }

  let regex = try! RegularExpression(pattern: "^[0-9]+", options: .caseInsensitive)
  let fullRange = NSRange(location: 0, length: cleanedSwiftName.characters.count)
  let sanitizedSwiftName = regex.stringByReplacingMatches(in: cleanedSwiftName, options: RegularExpression.MatchingOptions(rawValue: 0), range: fullRange, withTemplate: "")

  let capitalizedSwiftName = lowercaseFirstCharacter ? sanitizedSwiftName.lowercaseFirstCharacter : sanitizedSwiftName
  if SwiftKeywords.contains(capitalizedSwiftName) {
    return "`\(capitalizedSwiftName)`"
  }

  return capitalizedSwiftName // .isEmpty ? nil : capitalizedSwiftName
}

struct SwiftNameGroups<T> {
  let uniques: [T]
  let duplicates: [(String, [String])] // Identifiers that result in duplicate Swift names
  let empties: [String] // Identifiers (wrapped in quotes) that result in empty swift names
}

extension Sequence {
  func groupBySwiftNames(identifierSelector: (Iterator.Element) -> String) -> SwiftNameGroups<Iterator.Element> {
    var groupedBy = groupBy { sanitizedSwiftName(identifierSelector($0)) }
    let empties = groupedBy[""]?.map { "'\(identifierSelector($0))'" }.sorted()
    groupedBy[""] = nil

    let uniques = Array(groupedBy.values.filter { $0.count == 1 }.flatten())
    let duplicates = groupedBy
      .filter { $0.value.count > 1 }
      .map { ($0.key, $0.value.map(identifierSelector).sorted()) }

    return SwiftNameGroups(uniques: uniques, duplicates: duplicates, empties: empties ?? [])
  }
}

private let BlacklistedCharacters: CharacterSet = {
  var blacklist = CharacterSet(charactersIn: "")
  blacklist.formUnion(.whitespacesAndNewlines)
  blacklist.formUnion(.punctuation)
  blacklist.formUnion(.symbols)
  blacklist.formUnion(.illegalCharacters)
  blacklist.formUnion(.controlCharacters)
  blacklist.remove(charactersIn: "_")

  // Emoji ranges, roughly based on http://www.unicode.org/Public/emoji/1.0//emoji-data.txt
  [
    0x2600...0x27BF,
    0x1F300...0x1F6FF,
    0x1F900...0x1F9FF,
    0x1F1E6...0x1F1FF,
  ].forEach {
    blacklist.remove(charactersIn: UnicodeScalar($0.lowerBound) ..< UnicodeScalar($0.upperBound))
  }

  return blacklist
}()

// Based on https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/LexicalStructure.html#//apple_ref/doc/uid/TP40014097-CH30-ID413
private let SwiftKeywords = [
  // Keywords used in declarations
  "associatedtype", "class", "deinit", "enum", "extension", "func", "import", "init", "inout", "internal", "let", "operator", "private", "protocol", "public", "static", "struct", "subscript", "typealias", "var",

  // Keywords used in statements
  "break", "case", "continue", "default", "defer", "do", "else", "fallthrough", "for", "guard", "if", "in", "repeat", "return", "switch", "where", "while",

  // Keywords used in expressions and types
  "as", "catch", "dynamicType", "false", "is", "nil", "rethrows", "super", "self", "Self", "throw", "throws", "true", "try", "__COLUMN__", "__FILE__", "__FUNCTION__", "__LINE__",
]

