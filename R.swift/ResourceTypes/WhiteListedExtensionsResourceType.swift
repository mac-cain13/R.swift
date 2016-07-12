//
//  ResourceType.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 10-12-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import Foundation

protocol WhiteListedExtensionsResourceType {
  static var supportedExtensions: Set<String> { get }
}

extension WhiteListedExtensionsResourceType {
  // Convenience function to check if the path extension is supported, but feels a bit dirty since it throws and takes an optional
  static func throwIfUnsupportedExtension(_ pathExtension: String?) throws {
    let pathExtension = pathExtension ?? ""
    
    if !supportedExtensions.contains(pathExtension.lowercased()) {
      throw ResourceParsingError.UnsupportedExtension(givenExtension: pathExtension, supportedExtensions: supportedExtensions)
    }
  }
}
