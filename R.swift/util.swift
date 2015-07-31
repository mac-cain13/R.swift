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
  func each(f: Element -> Void) {
    map(f)
  }

  func skip(items: Int) -> [Element] {
    return Array(self[items..<count])
  }

  func flatMap<U>(f: Element -> [U]) -> [U] {
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
  return Array(Zip2Sequence(a, b))
}

func join<S where S: CustomStringConvertible>(separator: String, components: [S]) -> String {
  return separator.join(components.map { $0.description })
}

// MARK: String operations

extension String {
  var lowercaseFirstCharacter: String {
    if self.characters.count <= 1 { return self.lowercaseString }
    let index = advance(startIndex, 1)
    return substringToIndex(index).lowercaseString + substringFromIndex(index)
  }
}

func indentWithString(indentation: String) -> String -> String {
  return { string in
    let components = string.componentsSeparatedByString("\n")
    return indentation + "\n\(indentation)".join(components)
  }
}

// MARK: NSURL operations 

extension NSURL {
  var isDirectory: Bool {
    var urlIsDirectoryValue: AnyObject?
    do {
      try self.getResourceValue(&urlIsDirectoryValue, forKey: NSURLIsDirectoryKey)
    } catch _ {
    }

    return (urlIsDirectoryValue as? Bool) ?? false
  }

  var filename: String? {
    return lastPathComponent?.stringByDeletingPathExtension
  }
}
