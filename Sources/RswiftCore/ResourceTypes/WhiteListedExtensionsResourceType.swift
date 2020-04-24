//
//  ResourceType.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 10-12-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
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
      throw ResourceParsingError.unsupportedExtension(givenExtension: pathExtension, supportedExtensions: supportedExtensions)
    }
  }
}
