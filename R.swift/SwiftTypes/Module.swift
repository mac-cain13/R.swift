//
//  Module.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 11-12-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import Foundation

enum Module: StringLiteralConvertible, NilLiteralConvertible, CustomStringConvertible, Hashable {
  case Host
  case Custom(name: String)

  typealias UnicodeScalarLiteralType = StringLiteralType
  typealias ExtendedGraphemeClusterLiteralType = StringLiteralType

  var hashValue: Int {
    switch self {
    case .Host: return "".hashValue
    case let .Custom(name: name): return name.hashValue
    }
  }

  var description: String {
    switch self {
    case .Host: return ""
    case let .Custom(name: name): return name
    }
  }

  init(name: String?) {
    switch name {
    case .None: self = .Host
    case let .Some(name): self = .Custom(name: name)
    }
  }

  init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
    self = .Custom(name: value)
  }

  init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
    self = .Custom(name: value)
  }

  init(stringLiteral value: StringLiteralType) {
    self = .Custom(name: value)
  }

  init(nilLiteral: ()) {
    self = .Host
  }
}

func ==(lhs: Module, rhs: Module) -> Bool {
  return lhs.hashValue == rhs.hashValue
}
