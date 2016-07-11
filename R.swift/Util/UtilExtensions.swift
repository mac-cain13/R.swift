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

extension Sequence where Iterator.Element : CustomStringConvertible {
  func joined(separator: String) -> String {
    return map { $0.description }.joined(separator: separator)
  }
}

extension Sequence where Iterator.Element : Sequence {
  func flatten() -> [Iterator.Element.Iterator.Element] {
    return flatMap { $0 }
  }
}

// MARK: String operations

extension String {
  var lowercaseFirstCharacter: String {
    if self.characters.count <= 1 { return self.lowercased() }
    let secondIndex = index(after: startIndex)
    return substring(to: secondIndex).lowercased() + substring(from: secondIndex)
  }

  var uppercaseFirstCharacter: String {
    if self.characters.count <= 1 { return self.uppercased() }
    let secondIndex = index(after: startIndex)
    return substring(to: secondIndex).uppercased() + substring(from: secondIndex)
  }

  func indent(with indentation: String) -> String {
    return indentation + components(separatedBy: "\n").joined(separator: "\n\(indentation)")
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
    return (try? deletingPathExtension())?.lastPathComponent
  }
}
