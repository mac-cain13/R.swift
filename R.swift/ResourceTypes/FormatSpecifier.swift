//
//  FormatSpecifier.swift
//  R.swift
//
//  Created by Tom Lokhorst on 2016-04-18.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation


// https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/Strings/Articles/formatSpecifiers.html#//apple_ref/doc/uid/TP40004265-SW1
enum FormatSpecifier {
  case Object
  case Double
  case Int
  case UInt
  case Character
  case CStringPointer
  case VoidPointer
  case TopType

  var type: Type {
    switch self {
    case .Object:
      return Type._String

    case .Double:
      return Type._Double

    case .Int:
      return Type._Int

    case .UInt:
      return Type._UInt

    case .Character:
      return Type._Character

    case .CStringPointer:
      return Type._CStringPointer

    case .VoidPointer:
      return Type._VoidPointer

    case .TopType:
      return Type._Any
    }
  }
}

extension FormatSpecifier {
  init?(formatChar char: Swift.Character) {
    let lcChar = Swift.String(char).lowercaseString.characters.first!
    switch lcChar {
    case "@":
      self = .Object
    case "a", "e", "f", "g":
      self = .Double
    case "d", "i":
      self = .Int
    case "o", "u", "x":
      self = .UInt
    case "c":
      self = .Character
    case "s":
      self = .CStringPointer
    case "p":
      self = .VoidPointer
    default:
      return nil
    }
  }

  static func formatSpecifiersFromFormatString(formatString: String) -> [FormatSpecifier] {
    return _formatSpecifiersFromFormatString(formatString)
  }
}

// Based on StringsFileParser.swift from SwiftGen

private let formatTypesRegEx: NSRegularExpression = {
  let pattern_int = "(?:h|hh|l|ll|q|z|t|j)?([dioux])" // %d/%i/%o/%u/%x with their optional length modifiers like in "%lld"
  let pattern_float = "[aefg]"
  let position = "([1-9]\\d*\\$)?" // like in "%3$" to make positional specifiers
  let precision = "[-+]?\\d?(?:\\.\\d)?" // precision like in "%1.2f"
  do {
    return try NSRegularExpression(pattern: "(?<!%)%\(position)\(precision)(@|\(pattern_int)|\(pattern_float)|[csp])", options: [.CaseInsensitive])
  } catch {
    fatalError("Error building the regular expression used to match string formats")
  }
}()

// "I give %d apples to %@" --> [.Int, .String]
private func _formatSpecifiersFromFormatString(formatString: String) -> [FormatSpecifier] {
  let nsString = formatString as NSString
  let range = NSRange(location: 0, length: nsString.length)

  // Extract the list of chars (conversion specifiers) and their optional positional specifier
  let chars = formatTypesRegEx.matchesInString(formatString, options: [], range: range).map { match -> (String, Int?) in
    let range: NSRange
    if match.rangeAtIndex(3).location != NSNotFound {
      // [dioux] are in range #3 because in #2 there may be length modifiers (like in "lld")
      range = match.rangeAtIndex(3)
    } else {
      // otherwise, no length modifier, the conversion specifier is in #2
      range = match.rangeAtIndex(2)
    }
    let char = nsString.substringWithRange(range)

    let posRange = match.rangeAtIndex(1)
    if posRange.location == NSNotFound {
      // No positional specifier
      return (char, nil)
    } else {
      // Remove the "$" at the end of the positional specifier, and convert to Int
      let posRange1 = NSRange(location: posRange.location, length: posRange.length-1)
      let pos = nsString.substringWithRange(posRange1)
      return (char, Int(pos))
    }
  }

  // enumerate the conversion specifiers and their optionally forced position and build the array of format specifiers accordingly
  var list = [FormatSpecifier]()
  var nextNonPositional = 1
  for (str, pos) in chars {
    if let char = str.characters.first, let p = FormatSpecifier(formatChar: char) {
      let insertionPos: Int
      if let pos = pos {
        insertionPos = pos
      }
      else {
        insertionPos = nextNonPositional
        nextNonPositional += 1
      }

      if insertionPos > 0 {
        while list.count <= insertionPos-1 {
          list.append(FormatSpecifier.TopType)
        }
        list[insertionPos-1] = p
      }
    }
  }
  return list
}
