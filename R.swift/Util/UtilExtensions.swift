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

extension SequenceType where Generator.Element : CustomStringConvertible {
  func joinWithSeparator(separator: String) -> String {
    return map { $0.description }.joinWithSeparator(separator)
  }
}

extension SequenceType where Generator.Element : SequenceType {
  func flatten() -> [Generator.Element.Generator.Element] {
    return flatMap { $0 }
  }
}

// MARK: String operations

extension String {
  var lowercaseFirstCharacter: String {
    if self.characters.count <= 1 { return self.lowercaseString }
    let index = startIndex.advancedBy(1)
    return substringToIndex(index).lowercaseString + substringFromIndex(index)
  }

  var uppercaseFirstCharacter: String {
    if self.characters.count <= 1 { return self.uppercaseString }
    let index = startIndex.advancedBy(1)
    return substringToIndex(index).uppercaseString + substringFromIndex(index)
  }

  func indentWithString(indentation: String) -> String {
    let components = componentsSeparatedByString("\n")
    return indentation + components.joinWithSeparator("\n\(indentation)")
  }

  var escapedStringLiteral: String {
    return self
      .stringByReplacingOccurrencesOfString("\\", withString: "\\\\")
      .stringByReplacingOccurrencesOfString("\"", withString: "\\\"")
      .stringByReplacingOccurrencesOfString("\t", withString: "\\t")
      .stringByReplacingOccurrencesOfString("\n", withString: "\\n")
  }
}

// MARK: NSURL operations 

extension NSURL {
  var filename: String? {
    return URLByDeletingPathExtension?.lastPathComponent
  }
}
