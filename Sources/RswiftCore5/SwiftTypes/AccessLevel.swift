//
//  AccessLevel.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 09-01-16.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

public enum AccessLevel: String, SwiftCodeConverible {
  case publicLevel = "public"
  case internalLevel = "internal"
  case filePrivate = "fileprivate"
  case privateLevel = "private"

  var swiftCode: String {
    if self == .internalLevel {
      return ""
    }

    return "\(self.rawValue) "
  }
}
