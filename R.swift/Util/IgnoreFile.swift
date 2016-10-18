//
//  IgnoreFile.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 01-10-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

class IgnoreFile {
  private let patterns: [String]

  init(ignoreFileURL: URL) throws {
    let ignoreFileParentPath = ignoreFileURL.baseURL?.absoluteString ?? ""
    patterns = try String(contentsOf: ignoreFileURL)
      .components(separatedBy: CharacterSet.newlines)
      .filter(IgnoreFile.isPattern)
      .map { ignoreFileParentPath + $0 }
  }

  static private func isPattern(potentialPattern: String) -> Bool {
    // Check for empty line
    if potentialPattern.characters.count == 0 { return false }

    // Check for commented line
    if potentialPattern.characters.first == "#" { return false }

    return true
  }

  func match(url: NSURL) -> Bool {
    return patterns
      .map { NSURL.init(string: $0) }
      .any { url == $0 }
  }
}
