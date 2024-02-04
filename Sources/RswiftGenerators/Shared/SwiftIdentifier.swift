//
//  SwiftIdentifier.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 11-12-15.
//

import Foundation

private let numberPrefixRegex = try! NSRegularExpression(pattern: "^[0-9]+")
private let upperCasedPrefixRegex = try! NSRegularExpression(pattern: "^([A-Z]+)(?=[^a-z]{1})")

/*
 Disallowed characters: whitespace, mathematical symbols, arrows, private-use and invalid Unicode points, line- and boxdrawing characters
 Special rules: Can't begin with a number
 */
public struct SwiftIdentifier: Hashable, Comparable {
    public let value: String

    public init(name: String, lowercaseStartingCharacters: Bool = true) {
        // Remove all disallowed characters from the name and uppercase the character after a disallowed character
        var nameComponents = name.components(separatedBy: disallowedCharacters)
        let firstComponent = nameComponents.remove(at: 0)
        let cleanedSwiftName = nameComponents.reduce(firstComponent) { $0 + $1.uppercaseFirstCharacter }

        // Remove numbers at the start of the name
        let sanitizedSwiftName = numberPrefixRegex.stringByReplacingMatches(in: cleanedSwiftName, options: [], range: cleanedSwiftName.fullRange, withTemplate: "")

        // Lowercase the start of the name
        let capitalizedSwiftName = lowercaseStartingCharacters ? SwiftIdentifier.lowercasePrefix(sanitizedSwiftName) : sanitizedSwiftName

        // Escape the name if it is a keyword
        if SwiftKeywords.contains(capitalizedSwiftName) {
            value = "`\(capitalizedSwiftName)`"
        } else {
            value = capitalizedSwiftName
        }
    }

    public init(rawValue: String) {
        value = rawValue
    }

    private static func lowercasePrefix(_ name: String) -> String {
        let prefixRange = upperCasedPrefixRegex.rangeOfFirstMatch(in: name, options: [], range: name.fullRange)

        if prefixRange.location == NSNotFound {
            return name.lowercaseFirstCharacter
        } else {
            let lowercasedPrefix = (name as NSString).substring(with: prefixRange).lowercased()
            return (name as NSString).replacingCharacters(in: prefixRange, with: lowercasedPrefix)
        }
    }

    static func +(lhs: SwiftIdentifier, rhs: SwiftIdentifier) -> SwiftIdentifier {
        return SwiftIdentifier(rawValue: "\(lhs.value).\(rhs.value)")
    }

    public static func < (lhs: SwiftIdentifier, rhs: SwiftIdentifier) -> Bool {
        lhs.value < rhs.value
    }
}


struct SwiftNameGroups<T> {
    let uniques: [T]
    let duplicates: [(SwiftIdentifier, [String])] // Identifiers that result in duplicate Swift names
    let empties: [String] // Identifiers (wrapped in quotes) that result in empty swift names

    // Example:
    // source: "xib", container: nil, result: "file"
    // "Skipping 1 xib, because ... for all these files"
    //
    // source: "segue", container: "for MyViewController", result: "segue"
    // "Skipping 2 segues for MyViewController, because ... for all these segues"
    func reportWarningsForDuplicatesAndEmpties(source: String, container: String? = nil, result: String, warning: (String) -> Void) {
        let sourceSingular = [source, container].compactMap { $0 }.joined(separator: " ")
        let sourcePlural = ["\(source)s", container].compactMap { $0 }.joined(separator: " ")

        let resultSingular = result
        let resultPlural = "\(result)s"

        for (sanitizedName, dups) in duplicates {
            let source = dups.count == 1 ? sourceSingular : sourcePlural
            warning("Skipping \(dups.count) \(source) because symbol '\(sanitizedName.value)' would be generated for all of these \(resultPlural): \(dups.joined(separator: ", "))")
        }

        if let empty = empties.first , empties.count == 1 {
            warning("Skipping 1 \(sourceSingular) because no swift identifier can be generated for \(resultSingular): \(empty)")
        }
        else if empties.count > 1 {
            warning("Skipping \(empties.count) \(sourcePlural) because no swift identifier can be generated for all of these \(resultPlural): \(empties.joined(separator: ", "))")
        }
    }

    func reportWarningsForReservedNames(source: String, container: String? = nil, result: String, warning: (String) -> Void) {
        let sourceSingular = [source, container].compactMap { $0 }.joined(separator: " ")
        let sourcePlural = ["\(source)s", container].compactMap { $0 }.joined(separator: " ")

        for (sanitizedName, dups) in duplicates {
            let count = dups.count - 1
            let source = count == 1 ? sourceSingular : sourcePlural
            warning("Skipping \(count) \(source) because symbol '\(sanitizedName.value)' would conflict with reserved name")
        }
    }
}

extension Sequence {
    func grouped(bySwiftIdentifier identifierSelector: @escaping (Iterator.Element) -> String) -> SwiftNameGroups<Iterator.Element> {
        var groupedBy = Dictionary(grouping: self, by: { SwiftIdentifier(name: identifierSelector($0)) })
        let empty = SwiftIdentifier(name: "")
        let empties = groupedBy[empty]?.map { "'\(identifierSelector($0))'" }.sorted()
        groupedBy[empty] = nil

        let uniques = Array(groupedBy.values.filter { $0.count == 1 }.joined())
            .sorted { identifierSelector($0) < identifierSelector($1) }
        let duplicates = groupedBy
            .filter { $0.1.count > 1 }
            .map { ($0.0, $0.1.map(identifierSelector).sorted()) }
            .sorted { $0.0.value < $1.0.value }

        return SwiftNameGroups(uniques: uniques, duplicates: duplicates, empties: empties ?? [])
    }
}

private let disallowedCharacters: CharacterSet = {
    var disallowed = CharacterSet(charactersIn: "")
    disallowed.formUnion(CharacterSet.whitespacesAndNewlines)
    disallowed.formUnion(CharacterSet.punctuationCharacters)
    disallowed.formUnion(CharacterSet.symbols)
    disallowed.formUnion(CharacterSet.illegalCharacters)
    disallowed.formUnion(CharacterSet.controlCharacters)
    disallowed.remove(charactersIn: "_")

    // Emoji ranges, roughly based on http://www.unicode.org/Public/emoji/1.0//emoji-data.txt
    [
        0x2600...0x27BF,
        0x1F300...0x1F6FF,
        0x1F900...0x1F9FF,
        0x1F1E6...0x1F1FF,
    ].forEach { range in range.compactMap(UnicodeScalar.init).forEach { scalar in disallowed.remove(scalar) } }

    return disallowed
}()

// Based on https://docs.swift.org/swift-book/ReferenceManual/LexicalStructure.html#ID413
private let SwiftKeywords = [
    // Keywords used in declarations
    "associatedtype", "class", "deinit", "enum", "extension", "fileprivate", "func", "import", "init", "inout", "internal", "let", "open", "operator", "private", "protocol", "public", "static", "struct", "subscript", "typealias", "var",

    // Keywords used in statements
    "break", "case", "continue", "default", "defer", "do", "else", "fallthrough", "for", "guard", "if", "in", "repeat", "return", "switch", "where", "while",

    // Keywords used in expressions and types
    "as", "Any", "catch", "false", "is", "nil", "rethrows", "super", "self", "Self", "throw", "throws", "true", "try",

    // Keywords that begin with a number sign (#)
    "#available", "#colorLiteral", "#column", "#else", "#elseif", "#endif", "#error", "#file", "#fileLiteral", "#function", "#if", "#imageLiteral", "#line", "#selector", "#sourceLocation", "#warning",

    // Keywords from Swift 2 that are still reserved
    "__COLUMN__", "__FILE__", "__FUNCTION__", "__LINE__",
]
