//
//  String+Extensions.swift
//  RswiftGenerators
//
//  Created by Tom Lokhorst on 2021-04-18.
//

import Foundation

extension String {
    var lowercaseFirstCharacter: String {
        if self.count <= 1 { return self.lowercased() }
        let index = self.index(startIndex, offsetBy: 1)
        return self[..<index].lowercased() + self[index...]
    }

    var uppercaseFirstCharacter: String {
        if self.count <= 1 { return self.uppercased() }
        let index = self.index(startIndex, offsetBy: 1)
        return self[..<index].uppercased() + self[index...]
    }

    func indent(with indentation: String) -> String {
        return self
            .components(separatedBy: "\n")
            .map { line in line .isEmpty ? "" : "\(indentation)\(line)" }
            .joined(separator: "\n")
    }

    var fullRange: NSRange {
        return NSRange(location: 0, length: self.count)
    }

    var escapedStringLiteral: String {
        return self
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\t", with: "\\t")
            .replacingOccurrences(of: "\r", with: "\\r")
            .replacingOccurrences(of: "\n", with: "\\n")
    }

    var commentString: String {
        return self
            .replacingOccurrences(of: "\r\n", with: " ")
            .replacingOccurrences(of: "\r", with: " ")
            .replacingOccurrences(of: "\n", with: " ")
    }
}
