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
func sanitizedSwiftName(name: String, lowercaseFirstCharacter: Bool = true) -> String {
  var nameComponents = name.componentsSeparatedByCharactersInSet(BlacklistedCharacters)

  let firstComponent = nameComponents.removeAtIndex(0)
  let cleanedSwiftName = nameComponents.reduce(firstComponent) { $0 + $1.uppercaseFirstCharacter }

  let regex = try! NSRegularExpression(pattern: "^[0-9]+", options: .CaseInsensitive)
  let fullRange = NSRange(location: 0, length: cleanedSwiftName.characters.count)
  let sanitizedSwiftName = regex.stringByReplacingMatchesInString(cleanedSwiftName, options: NSMatchingOptions(rawValue: 0), range: fullRange, withTemplate: "")

  let capitalizedSwiftName = lowercaseFirstCharacter ? sanitizedSwiftName.lowercaseFirstCharacter : sanitizedSwiftName
  if SwiftKeywords.contains(capitalizedSwiftName) {
    return "`\(capitalizedSwiftName)`"
  }

  return capitalizedSwiftName // .isEmpty ? nil : capitalizedSwiftName
}

struct SwiftNameGroups<T> {
  let uniques: [T]
  let duplicates: [(String, [String])] // Identifiers that result in duplicate Swift names
  let empties: [String] // Identifiers that result in empty swift names
}

extension SequenceType {
  func groupBySwiftNames(identifierSelector: Generator.Element -> String) -> SwiftNameGroups<Generator.Element> {
    var groupedBy = groupBy { sanitizedSwiftName(identifierSelector($0)) }
    let empties = groupedBy[""]?.map { identifierSelector($0) }
    groupedBy[""] = nil

    let uniques = groupedBy.values.filter { $0.count == 1 }.flatten()
    let duplicates = groupedBy
      .filter { $0.1.count > 1 }
      .map { ($0.0, $0.1.map(identifierSelector).sort()) }

    return SwiftNameGroups(uniques: Array(uniques), duplicates: duplicates, empties: empties ?? [])
  }
}

private let BlacklistedCharacters: NSCharacterSet = {
  let blacklist = NSMutableCharacterSet(charactersInString: "")
  blacklist.formUnionWithCharacterSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
  blacklist.formUnionWithCharacterSet(NSCharacterSet.punctuationCharacterSet())
  blacklist.formUnionWithCharacterSet(NSCharacterSet.symbolCharacterSet())
  blacklist.formUnionWithCharacterSet(NSCharacterSet.illegalCharacterSet())
  blacklist.formUnionWithCharacterSet(NSCharacterSet.controlCharacterSet())
  blacklist.removeCharactersInString("_")

  // Emoji ranges, roughly based on http://www.unicode.org/Public/emoji/1.0//emoji-data.txt
  [
    0x2600...0x27BF,
    0x1F300...0x1F6FF,
    0x1F900...0x1F9FF,
    0x1F1E6...0x1F1FF,
  ].forEach {
    let range = NSRange(location: $0.startIndex, length: $0.endIndex - $0.startIndex)
    blacklist.removeCharactersInRange(range)
  }

  return blacklist
}()

// Based on https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/LexicalStructure.html#//apple_ref/doc/uid/TP40014097-CH30-ID413
private let SwiftKeywords = [
  // Keywords used in declarations
  "class", "deinit", "enum", "extension", "func", "import", "init", "inout", "internal", "let", "operator", "private", "protocol", "public", "static", "struct", "subscript", "typealias", "var",

  // Keywords used in statements
  "break", "case", "continue", "default", "defer", "do", "else", "fallthrough", "for", "guard", "if", "in", "repeat", "return", "switch", "where", "while",

  // Keywords used in expressions and types
  "as", "catch", "dynamicType", "false", "is", "nil", "rethrows", "super", "self", "Self", "throw", "throws", "true", "try", "__COLUMN__", "__FILE__", "__FUNCTION__", "__LINE__",

  // Keywords used in patterns
  "_",
]

