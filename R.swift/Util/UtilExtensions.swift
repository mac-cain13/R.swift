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

extension SequenceType {
  func groupUniquesAndDuplicates<U: Hashable>(keySelector: Generator.Element -> U) -> (uniques: [Generator.Element], duplicates: [[Generator.Element]]) {
    let groupedBy = Array(groupBy(keySelector).values)
    let uniques = groupedBy.filter { $0.count == 1 }.reduce([], combine: +)
    let duplicates = groupedBy.filter { $0.count > 1 }

    return (uniques: uniques, duplicates: duplicates)
  }
}

extension SequenceType where Generator.Element : CustomStringConvertible {
  func joinWithSeparator(separator: String) -> String {
    return map { $0.description }.joinWithSeparator(separator)
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
}

// MARK: NSURL operations 

extension NSURL {
  var filename: String? {
    return URLByDeletingPathExtension?.lastPathComponent
  }
}
