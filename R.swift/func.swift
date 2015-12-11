//
//  func.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 14-12-14.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

// MARK: Helper functions

func warn(warning: String) {
  print("warning: [R.swift] \(warning)")
}

func fail(error: String) {
  print("error: [R.swift] \(error)")
}

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
  return SwiftKeywords.contains(capitalizedSwiftName) ? "`\(capitalizedSwiftName)`" : capitalizedSwiftName
}

// Roughly based on http://www.unicode.org/Public/emoji/1.0//emoji-data.txt
private let emojiRanges = [
  0x2600...0x27BF,
  0x1F300...0x1F6FF,
  0x1F900...0x1F9FF,
  0x1F1E6...0x1F1FF,
]

private let BlacklistedCharacters = { () -> NSCharacterSet in
  let blacklist = NSMutableCharacterSet(charactersInString: "")
  blacklist.formUnionWithCharacterSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
  blacklist.formUnionWithCharacterSet(NSCharacterSet.punctuationCharacterSet())
  blacklist.formUnionWithCharacterSet(NSCharacterSet.symbolCharacterSet())
  blacklist.formUnionWithCharacterSet(NSCharacterSet.illegalCharacterSet())
  blacklist.formUnionWithCharacterSet(NSCharacterSet.controlCharacterSet())
  blacklist.removeCharactersInString("_")

  emojiRanges.forEach {
    let range = NSRange(location: $0.startIndex, length: $0.endIndex - $0.startIndex)
    blacklist.removeCharactersInRange(range)
  }

  return blacklist
}()

private let SwiftKeywords = ["class", "deinit", "enum", "extension", "func", "import", "init", "internal", "let", "operator", "private", "protocol", "public", "static", "struct", "subscript", "typealias", "var", "break", "case", "continue", "default", "do", "else", "fallthrough", "for", "if", "in", "return", "switch", "where", "while", "as", "dynamicType", "false", "is", "nil", "self", "Self", "super", "true", "__COLUMN__", "__FILE__", "__FUNCTION__", "__LINE__"]
