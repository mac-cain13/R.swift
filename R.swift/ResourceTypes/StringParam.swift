//
//  StringParam.swift
//  R.swift
//
//  Created by Tom Lokhorst on 2016-04-18.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//
//  Parts of the content of this file are loosly based on StringsFileParser.swift from SwiftGen/GenumKit.
//  We don't feel this is a "substantial portion of the Software" so are not including their MIT license,
//  eventhough we would like to give credit where credit is due by referring to SwiftGen thanking Olivier
//  Halligon for creating SwiftGen and GenumKit.
//
//  See: https://github.com/AliSoftware/SwiftGen/blob/master/GenumKit/Parsers/StringsFileParser.swift
//

import Foundation

struct StringParam : Equatable, Unifiable {
  let name: String?
  let spec: FormatSpecifier

  func unify(other: StringParam) -> StringParam? {
    if let name = name, otherName = other.name where name != otherName {
      return nil
    }

    if let spec = spec.unify(other.spec) {
      return StringParam(name: name ?? other.name, spec: spec)
    }

    return nil
  }
}

func ==(lhs: StringParam, rhs: StringParam) -> Bool {
  return lhs.name == rhs.name && lhs.spec == rhs.spec
}

enum FormatPart: Unifiable {
  case Spec(FormatSpecifier)
  case Reference(String)

  var formatSpecifier: FormatSpecifier? {
    switch self {
    case .Spec(let formatSpecifier):
      return formatSpecifier

    case .Reference:
      return nil
    }
  }

  static func formatParts(formatString formatString: String) -> [FormatPart] {
    return createFormatParts(formatString)
  }

  func unify(other: FormatPart) -> FormatPart? {
    switch (self, other) {
    case let (.Spec(l), .Spec(r)):
      if let spec = l.unify(r) {
        return .Spec(spec)
      }
      else {
        return nil
      }

    case let (.Reference(l), .Reference(r)) where l == r:
      return .Reference(l)

    default:
      return nil
    }
  }
}

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
      return ._String
    case .Double:
      return ._Double
    case .Int:
      return ._Int
    case .UInt:
      return ._UInt
    case .Character:
      return ._Character
    case .CStringPointer:
      return ._CStringPointer
    case .VoidPointer:
      return ._VoidPointer
    case .TopType:
      return ._Any
    }
  }
}

extension FormatSpecifier : Unifiable {

  // Convenience initializer, uses last character of string,
  // ignoring lengt modifiers, e.g. "lld"
  init?(formatString string: String) {
    guard let last = string.characters.last else {
      return nil
    }

    self.init(formatChar: last)
  }

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

  func unify(other: FormatSpecifier) -> FormatSpecifier? {
    if self == .TopType {
      return other
    }

    if other == .TopType {
      return self
    }

    if self == other {
      return self
    }

    return nil
  }
}

private let referenceRegEx: NSRegularExpression = {
  do {
    return try NSRegularExpression(pattern: "#@([^@]+)@", options: [.CaseInsensitive])
  } catch {
    fatalError("Error building the regular expression used to match reference")
  }
}()

private let formatTypesRegEx: NSRegularExpression = {
  let pattern_int = "(?:h|hh|l|ll|q|z|t|j)?([dioux])" // %d/%i/%o/%u/%x with their optional length modifiers like in "%lld"
  let pattern_float = "[aefg]"
  let position = "([1-9]\\d*\\$)?" // like in "%3$" to make positional specifiers
  let precision = "[-+]?\\d?(?:\\.\\d)?" // precision like in "%1.2f"
  let reference = "#@([^@]+)@" // reference to NSStringFormatSpecType in .stringsdict
  do {
    return try NSRegularExpression(pattern: "(?<!%)%\(position)\(precision)(@|\(pattern_int)|\(pattern_float)|[csp]|\(reference))", options: [.CaseInsensitive])
  } catch {
    fatalError("Error building the regular expression used to match string formats")
  }
}()

// "I give %d apples to %@ %#@named@" --> [.Spec(.Int), .Spec(.String), .Reference("named")]
private func createFormatParts(formatString: String) -> [FormatPart] {
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

  // Build up params array
  var params = [FormatPart]()
  var nextNonPositional = 1
  for (str, pos) in chars {
    let insertionPos: Int
    if let pos = pos {
      insertionPos = pos
    }
    else {
      insertionPos = nextNonPositional
      nextNonPositional += 1
    }

    let param: FormatPart?

    if let reference = referenceRegEx.firstSubstring(input: str) {
      param = FormatPart.Reference(reference)
    }
    else if let char = str.characters.first, fs = FormatSpecifier(formatChar: char)
    {
      param = FormatPart.Spec(fs)
    }
    else {
      param = nil
    }

    if let param = param {
      if insertionPos > 0 {
        while params.count <= insertionPos - 1 {
          params.append(FormatPart.Spec(FormatSpecifier.TopType))
        }

        params[insertionPos - 1] = param
      }
    }
  }

  return params
}

extension NSRegularExpression {
  private func firstSubstring(input input: String) -> String? {
    let nsInput = input as NSString
    let inputRange = NSMakeRange(0, nsInput.length)

    guard let match = self.firstMatchInString(input, options: [], range: inputRange) else {
      return nil
    }

    guard match.numberOfRanges > 0 else {
      return nil
    }

    let range = match.rangeAtIndex(1)
    return nsInput.substringWithRange(range)
  }
}
