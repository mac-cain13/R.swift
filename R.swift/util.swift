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

func distinct<T: Equatable>(source: [T]) -> [T] {
  var unique = [T]()
  source.each {
    if !unique.contains($0) {
      unique.append($0)
    }
  }
  return unique
}

func zip<T, U>(a: [T], b: [U]) -> [(T, U)] {
  return Array(Zip2Sequence(a, b))
}

func join<S where S: CustomStringConvertible>(separator: String, components: [S]) -> String {
  return join(separator, components: components.map { $0.description })
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
    return indentation + join("\n\(indentation)", components: components)
  }
}

// MARK: NSURL operations 

extension NSURL {
  var isDirectory: Bool {
    var urlIsDirectoryValue: AnyObject?
    do {
        try self.getResourceValue(&urlIsDirectoryValue, forKey: NSURLIsDirectoryKey)
    } catch {
    }

    return (urlIsDirectoryValue as? Bool) ?? false
  }

  var filename: String? {
    return lastPathComponent?.stringByDeletingPathExtension
  }
}
