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
  private let ignoreFileURL: URL?
  
  init() {
    patterns = []
    ignoreFileURL = nil
  }

  init(ignoreFileURL: URL) throws {
    self.ignoreFileURL = ignoreFileURL
    patterns = try String(contentsOf: ignoreFileURL)
      .components(separatedBy: CharacterSet.newlines)
      .filter(IgnoreFile.isPattern)
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
      .flatMap { listFilePaths(pattern: $0) }
      .map { NSURL.init(string: $0, relativeTo: ignoreFileURL?.baseURL)?.absoluteURL }
      .flatMap { $0 }
      .any { url == $0 as NSURL }
  }
  
  private func listFilePaths(pattern: String) -> [String] {
    if (pattern.isEmpty) { return [] }
    
    var globObj = glob_t()
    var paths = [String]()
    glob(pattern, 0, nil, &globObj)
    for i in 0 ..< Int(globObj.gl_matchc) {
      let mutablePointer = globObj.gl_pathv[Int(i)]
      if let charPointer = UnsafePointer<CChar>(mutablePointer) {
        let filePath = String.init(cString: charPointer)
        paths.append(filePath)
      }
    }
    globfree(&globObj)
    return paths
  }
}
