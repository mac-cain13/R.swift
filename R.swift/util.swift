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
  func skip(items: Int) -> [Element] {
    return Array(self[items..<count])
  }
}

extension SequenceType {
  func groupBy<U: Hashable>(keySelector: Generator.Element -> U) -> [[Generator.Element]] {
    var groupedBy = Dictionary<U, [Generator.Element]>()

    for element in self {
      let key = keySelector(element)
      if let group = groupedBy[key] {
        groupedBy[key] = group + [element]
      } else {
        groupedBy[key] = [element]
      }
    }

    return Array(groupedBy.values)
  }

  func groupUniquesAndDuplicates<U: Hashable>(keySelector: Generator.Element -> U) -> (uniques: [Generator.Element], duplicates: [[Generator.Element]]) {
    let groupedBy = groupBy(keySelector)
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
}

func indentWithString(indentation: String) -> String -> String {
  return { string in
    let components = string.componentsSeparatedByString("\n")
    return indentation + components.joinWithSeparator("\n\(indentation)")
  }
}

// MARK: NSURL operations 

extension NSURL {
  var isDirectory: Bool {
    var urlIsDirectoryValue: AnyObject?
    do {
      try getResourceValue(&urlIsDirectoryValue, forKey: NSURLIsDirectoryKey)
    } catch _ {}

    return (urlIsDirectoryValue as? Bool) ?? false
  }

  var filename: String? {
    return (lastPathComponent as NSString?)?.stringByDeletingPathExtension
  }
}
