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
  func each(f: T -> Void) {
    map(f)
  }

  func skip(items: Int) -> [T] {
    return Array(self[items..<count])
  }
}

func distinct<T: Equatable>(source: [T]) -> [T] {
  var unique = [T]()
  for item in source {
    if !contains(unique, item) {
      unique.append(item)
    }
  }
  return unique
}

// MARK: String operations

extension String {
  var lowercaseFirstCharacter: String {
    if countElements(self) <= 1 { return self.lowercaseString }
    let index = advance(startIndex, 1)
    return substringToIndex(index).lowercaseString + substringFromIndex(index)
  }
}

// MARK: NSURL operations 

extension NSURL {
  var isDirectory: Bool {
    var urlIsDirectoryValue: AnyObject?
    self.getResourceValue(&urlIsDirectoryValue, forKey: NSURLIsDirectoryKey, error: nil)

    return urlIsDirectoryValue as? Bool ?? false
  }

  var filename: String? {
    return lastPathComponent?.stringByDeletingPathExtension
  }
}
