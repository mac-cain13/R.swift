//
//  StringParam.swift
//  R.swift
//
//  Created by Tom Lokhorst on 2016-04-18.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//
//  Parts of the content of this file are loosly based on StringsFileParser.swift from SwiftGen/GenumKit.
//  We don't feel this is a "substantial portion of the Software" so are not including their MIT license,
//  eventhough we would like to give credit where credit is due by referring to SwiftGen thanking Olivier
//  Halligon for creating SwiftGen and GenumKit.
//
//  See: https://github.com/AliSoftware/SwiftGen/blob/master/GenumKit/Parsers/StringsFileParser.swift
//

import Foundation
import RswiftResources

extension StringParam: Unifiable {
    public func unify(_ other: StringParam) -> StringParam? {
        if let name = name, let otherName = other.name , name != otherName {
            return nil
        }

        if let spec = spec.unify(other.spec) {
            return StringParam(name: name ?? other.name, spec: spec)
        }

        return nil
    }
}

extension FormatPart: Unifiable {
    static public func formatParts(formatString: String) -> [FormatPart] {
        createFormatParts(formatString)
    }

    public func unify(_ other: FormatPart) -> FormatPart? {
        switch (self, other) {
        case let (.spec(l), .spec(r)):
            if let spec = l.unify(r) {
                return .spec(spec)
            }
            else {
                return nil
            }

        case let (.reference(l), .reference(r)) where l == r:
            return .reference(l)

        default:
            return nil
        }
    }
}

extension FormatSpecifier {
    var type: TypeReference {
        switch self {
        case .object:
            return ._String
        case .double:
            return ._Double
        case .int:
            return ._Int
        case .uInt:
            return ._UInt
        case .character:
            return ._Character
        case .cStringPointer:
            return ._CStringPointer
        case .voidPointer:
            return ._VoidPointer
        case .topType:
            return ._Any
        }
    }
}

extension FormatSpecifier : Unifiable {

    // Convenience initializer, uses last character of string,
    // ignoring lengt modifiers, e.g. "lld"
    public init?(formatString string: String) {
        guard let last = string.last else {
            return nil
        }

        self.init(formatChar: last)
    }

    public init?(formatChar char: Swift.Character) {
        let lcChar = Swift.String(char).lowercased().first!
        switch lcChar {
        case "@":
            self = .object
        case "a", "e", "f", "g":
            self = .double
        case "d", "i":
            self = .int
        case "o", "u", "x":
            self = .uInt
        case "c":
            self = .character
        case "s":
            self = .cStringPointer
        case "p":
            self = .voidPointer
        default:
            return nil
        }
    }

    public func unify(_ other: FormatSpecifier) -> FormatSpecifier? {
        if self == .topType {
            return other
        }

        if other == .topType {
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
        return try NSRegularExpression(pattern: "#@([^@]+)@", options: [.caseInsensitive])
    } catch {
        fatalError("Error building the regular expression used to match reference")
    }
}()

private let formatTypesRegEx: NSRegularExpression = {
    let pattern_int = "(?:h|hh|l|ll|q|z|t|j)?([dioux])" // %d/%i/%o/%u/%x with their optional length modifiers like in "%lld"
    let pattern_float = "[aefg]"
    let position = "([1-9]\\d*\\$)?" // like in "%3$" to make positional specifiers
    let precision = "[-+]?\\d*(?:\\.\\d*)?" // precision like in "%1.2f" or "%012.10"
    let reference = "#@([^@]+)@" // reference to NSStringFormatSpecType in .stringsdict
    do {
        return try NSRegularExpression(pattern: "(?<!%)%\(position)\(precision)(@|\(pattern_int)|\(pattern_float)|[csp]|\(reference))", options: [.caseInsensitive])
    } catch {
        fatalError("Error building the regular expression used to match string formats")
    }
}()

// "I give %d apples to %@ %#@named@" --> [.Spec(.Int), .Spec(.String), .Reference("named")]
private func createFormatParts(_ formatString: String) -> [FormatPart] {
    let nsString = formatString as NSString
    let range = NSRange(location: 0, length: nsString.length)

    // Extract the list of chars (conversion specifiers) and their optional positional specifier
    let chars = formatTypesRegEx.matches(in: formatString, options: [], range: range).map { match -> (String, Int?) in
        let range: NSRange
        if match.range(at: 3).location != NSNotFound {
            // [dioux] are in range #3 because in #2 there may be length modifiers (like in "lld")
            range = match.range(at: 3)
        } else {
            // otherwise, no length modifier, the conversion specifier is in #2
            range = match.range(at: 2)
        }
        let char = nsString.substring(with: range)

        let posRange = match.range(at: 1)
        if posRange.location == NSNotFound {
            // No positional specifier
            return (char, nil)
        } else {
            // Remove the "$" at the end of the positional specifier, and convert to Int
            let posRange1 = NSRange(location: posRange.location, length: posRange.length-1)
            let pos = nsString.substring(with: posRange1)
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
            param = FormatPart.reference(reference)
        }
        else if let char = str.first, let fs = FormatSpecifier(formatChar: char)
        {
            param = FormatPart.spec(fs)
        }
        else {
            param = nil
        }

        if let param = param {
            if insertionPos > 0 {
                while params.count <= insertionPos - 1 {
                    params.append(FormatPart.spec(FormatSpecifier.topType))
                }

                params[insertionPos - 1] = param
            }
        }
    }

    return params
}

extension NSRegularExpression {
    fileprivate func firstSubstring(input: String) -> String? {
        let nsInput = input as NSString
        let inputRange = NSMakeRange(0, nsInput.length)

        guard let match = self.firstMatch(in: input, options: [], range: inputRange) else {
            return nil
        }

        guard match.numberOfRanges > 0 else {
            return nil
        }

        let range = match.range(at: 1)
        return nsInput.substring(with: range)
    }
}
