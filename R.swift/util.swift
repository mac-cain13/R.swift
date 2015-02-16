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

  func flatMap<U>(f: T -> [U]) -> [U] {
    return flatten(map(f))
  }
}

func flatten<T>(coll : [[T]]) -> [T] {
  return coll.reduce([], combine: +)
}

func distinct<T: Equatable>(source: [T]) -> [T] {
  var unique = [T]()
  source.each {
    if !contains(unique, $0) {
      unique.append($0)
    }
  }
  return unique
}

func zip<T, U>(a: [T], b: [U]) -> [(T, U)] {
  return Array(Zip2(a, b))
}

func join<S where S: Printable>(separator: String, components: [S]) -> String {
  return join(separator, components.map { $0.description })
}

// MARK: String operations

extension String {
  var lowercaseFirstCharacter: String {
    if count(self) <= 1 { return self.lowercaseString }
    let index = advance(startIndex, 1)
    return substringToIndex(index).lowercaseString + substringFromIndex(index)
  }
}

func indentWithString(indentation: String) -> String -> String {
  return { string in
    let components = string.componentsSeparatedByString("\n")
    return indentation + join("\n\(indentation)", components)
  }
}

// MARK: NSURL operations 

extension NSURL {
  var isDirectory: Bool {
    var urlIsDirectoryValue: AnyObject?
    self.getResourceValue(&urlIsDirectoryValue, forKey: NSURLIsDirectoryKey, error: nil)

    return (urlIsDirectoryValue as? Bool) ?? false
  }

  var filename: String? {
    return lastPathComponent?.stringByDeletingPathExtension
  }
}
