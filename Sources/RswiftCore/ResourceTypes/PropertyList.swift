//
//  PropertyList.swift
//  R.swift
//
//  Created by Tom Lokhorst on 2018-07-08.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

struct PropertyList {
  typealias Contents = [String: Any]

  let buildConfigurationName: String
  let contents: Contents
  let url: URL

  init(buildConfigurationName: String, url: URL) throws {
    guard
      let nsDictionary = NSDictionary(contentsOf: url),
      let dictionary = nsDictionary as? [String: Any]
    else {
      throw ResourceParsingError.parsingFailed("File could not be parsed as InfoPlist from URL: \(url.absoluteString)")
    }

    self.buildConfigurationName = buildConfigurationName
    self.contents = dictionary
    self.url = url
  }
}
