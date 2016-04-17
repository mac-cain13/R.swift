//
//  LocalizableStrings.swift
//  R.swift
//
//  Created by Nolan Warner on 2016/02/23.
//  Copyright © 2016 Nolan Warner. All rights reserved.
//

import Foundation

struct LocalizableStrings: WhiteListedExtensionsResourceType {
  static let supportedExtensions: Set<String> = ["strings"]

  let locale: String?
  let dictionary: [String : (value: String, params: [Type])]

  init(url: NSURL) throws {
    try LocalizableStrings.throwIfUnsupportedExtension(url.pathExtension)

    // Set locale for file (second to last component)
    if let localeComponent = url.pathComponents?.dropLast().last where localeComponent.hasSuffix(".lproj") {
      locale = localeComponent.stringByReplacingOccurrencesOfString(".lproj", withString: "")
    } else {
      locale = nil
    }

    // Check to make sure url can be parsed as a dictionary
    guard let nsDictionary = NSDictionary(contentsOfURL: url) else {
      throw ResourceParsingError.ParsingFailed("Filename and/or extension could not be parsed from URL: \(url.absoluteString)")
    }

    // Parse strings from NSDictionary
    var dictionary: [String : (value: String, params: [Type])] = [:]
    for (key, obj) in nsDictionary {
      if let
        key = key as? String,
        val = obj as? String
      {
        dictionary[key] = (val, typesFromFormatString(val))
      }
      else {
        throw ResourceParsingError.ParsingFailed("Non-string value in \(url.absoluteString): \(key) = \(obj)")
      }
    }

    self.dictionary = dictionary
  }
}


// https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/Strings/Articles/formatSpecifiers.html#//apple_ref/doc/uid/TP40004265-SW1
extension Type {
  init?(formatChar char: Character) {
    let lcChar = String(char).lowercaseString.characters.first!
    switch lcChar {
    case "@":
      self = Type._String
    case "a", "e", "f", "g":
      self = Type._Double
    case "d", "i":
      self = Type._Int
    case "o", "u", "x":
      self = Type._UInt
    case "c":
      self = Type._Character
    case "s":
      self = Type._CStringPointer
    case "p":
      self = Type._VoidPointer
    default:
      return nil
    }
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
private func typesFromFormatString(formatString: String) -> [Type] {
  let range = NSRange(location: 0, length: (formatString as NSString).length)

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
    let char = (formatString as NSString).substringWithRange(range)

    let posRange = match.rangeAtIndex(1)
    if posRange.location == NSNotFound {
      // No positional specifier
      return (char, nil)
    } else {
      // Remove the "$" at the end of the positional specifier, and convert to Int
      let posRange1 = NSRange(location: posRange.location, length: posRange.length-1)
      let pos = (formatString as NSString).substringWithRange(posRange1)
      return (char, Int(pos))
    }
  }

  // enumerate the conversion specifiers and their optionally forced position and build the array of Types accordingly
  var list = [Type]()
  var nextNonPositional = 1
  for (str, pos) in chars {
    if let char = str.characters.first, let p = Type(formatChar: char) {
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
          list.append(Type._Any)
        }
        list[insertionPos-1] = p
      }
    }
  }
  return list
}

