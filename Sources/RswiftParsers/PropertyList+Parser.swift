//
//  PropertyList.swift
//  R.swift
//
//  Created by Tom Lokhorst on 2018-07-08.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation
import RswiftResources

extension PropertyListResource {
    static public func parse(url: URL, buildConfigurationName: String) throws -> PropertyListResource {
        guard
          let nsDictionary = NSDictionary(contentsOf: url),
          let dictionary = nsDictionary as? [String: Any]
        else {
          throw ResourceParsingError("File could not be parsed as InfoPlist from URL: \(url.absoluteString)")
        }

        return PropertyListResource(buildConfigurationName: buildConfigurationName, contents: dictionary, url: url)
    }
}
