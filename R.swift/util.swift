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

func catOptionals<T>(c: [T?]) -> [T] {
  return c.flatMap(list)
}

func list<T>(x: T?) -> [T] {
  return x.map { [$0] } ?? []
}

func flatten<T>(coll: [[T]]) -> [T] {
  return coll.reduce([], combine: +)
}

func groupBy<T: SequenceType, U: Hashable>(sequence: T, keySelector: T.Generator.Element -> U) -> Dictionary<U, [T.Generator.Element]> {
  var groupedBy = Dictionary<U, [T.Generator.Element]>()

  for element in sequence {
    let key = keySelector(element)
    if let group = groupedBy[key] {
      groupedBy[key] = group + [element]
    } else {
      groupedBy[key] = [element]
    }
  }

  return groupedBy
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
