//
//  IgnoreFile.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 01-10-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

class IgnoreFile {
  private let patterns: [NSURL]

  init() {
    patterns = []
  }

  init(ignoreFileURL: URL) throws {
    let parentDirString = ignoreFileURL.deletingLastPathComponent().path + "/"
    patterns = try String(contentsOf: ignoreFileURL)
      .components(separatedBy: CharacterSet.newlines)
      .filter(IgnoreFile.isPattern)
      .flatMap { IgnoreFile.listFilePaths(pattern: parentDirString + $0) }
      .map { $0.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) }
      .flatMap { $0 }
      .map { NSURL.init(string: $0) }
      .flatMap { $0 }
  }

  static private func isPattern(potentialPattern: String) -> Bool {
    // Check for empty line
    if potentialPattern.characters.count == 0 { return false }

    // Check for commented line
    if potentialPattern.characters.first == "#" { return false }

    return true
  }

  static private func listFilePaths(pattern: String) -> [String] {
    if (pattern.isEmpty) { return [] }
    return Glob.init(pattern: pattern).paths
  }
  
  func match(url: NSURL) -> Bool {
    return patterns.any { url.path == $0.path }
  }
}
