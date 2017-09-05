//
//  util.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 12-12-14.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

// MARK: Array operations

extension Array {
  subscript (safe index: Int) -> Element? {
    return indices ~= index ? self[index] : nil
  }
}

// MARK: Sequence operations

extension Sequence {
  func grouped<Key>(by keyForValue: (Element) -> Key) -> [Key: [Element]] {
    return Dictionary(grouping: self, by: keyForValue)
  }

  func all(where predicate: (Element) throws -> Bool) rethrows -> Bool {
    return !(try contains(where: { !(try predicate($0)) }))
  }

  func array() -> [Element] {
    return Array(self)
  }
}

// MARK: String operations

extension String {
  var lowercaseFirstCharacter: String {
    if self.characters.count <= 1 { return self.lowercased() }
    let index = characters.index(startIndex, offsetBy: 1)
    return self[..<index].lowercased() + self[index...]
  }

  var uppercaseFirstCharacter: String {
    if self.characters.count <= 1 { return self.uppercased() }
    let index = characters.index(startIndex, offsetBy: 1)
    return self[..<index].uppercased() + self[index...]
  }

  func indent(with indentation: String) -> String {
    let components = self.components(separatedBy: "\n")
    return indentation + components.joined(separator: "\n\(indentation)")
  }

  var fullRange: NSRange {
    return NSRange(location: 0, length: characters.count)
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

// MARK: URL operations 

extension URL {
  var filename: String? {
    let filename = deletingPathExtension().lastPathComponent
    return filename.characters.count == 0 ? nil : filename
  }
}
