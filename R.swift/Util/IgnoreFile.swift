//
//  IgnoreFile.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 01-10-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

class IgnoreFile {
  private let ignoredURLs: [URL]

  init() {
    ignoredURLs = []
  }

  init(ignoreFileURL: URL) throws {
    let workingDirectory = ignoreFileURL.deletingLastPathComponent()

    ignoredURLs = try String(contentsOf: ignoreFileURL)
      .components(separatedBy: .newlines)
      .filter(IgnoreFile.isPattern)
      .map { workingDirectory.path + "/" + $0 } // This is a glob pattern, so we don't use URL here
      .flatMap(IgnoreFile.listFilePaths)
      .map { URL(fileURLWithPath: $0).standardizedFileURL }
  }

  static private func isPattern(potentialPattern: String) -> Bool {
    // Check for empty line
    if potentialPattern.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return false }

    // Check for commented line
    if potentialPattern.characters.first == "#" { return false }

    return true
  }

  static private func listFilePaths(pattern: String) -> [String] {
    guard !pattern.isEmpty else {
      return []
    }

    return Glob(pattern: pattern).paths
  }
  
  func matches(url: URL) -> Bool {
    return ignoredURLs.contains(url)
  }
}
