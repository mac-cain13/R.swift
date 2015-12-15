//
//  Module.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 11-12-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import Foundation

struct Module: StringLiteralConvertible, Hashable {
  typealias UnicodeScalarLiteralType = StringLiteralType
  typealias ExtendedGraphemeClusterLiteralType = StringLiteralType

  let name: String

  var hashValue: Int {
    return name.hashValue
  }

  init(name: String) {
    self.name = name
  }

  init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
    name = "\(value)"
  }

  init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
    name = value
  }

  init(stringLiteral value: StringLiteralType) {
    name = value
  }
}

func ==(lhs: Module, rhs: Module) -> Bool {
  return lhs.hashValue == rhs.hashValue
}
