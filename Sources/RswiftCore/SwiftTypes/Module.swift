//
//  Module.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 11-12-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

public enum Module: ExpressibleByStringLiteral, CustomStringConvertible, Hashable {
  case host
  case stdLib
  case custom(name: String)

  public typealias UnicodeScalarLiteralType = StringLiteralType
  public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType

  public var description: String {
    switch self {
    case .host: return ""
    case .stdLib: return ""
    case let .custom(name: name): return name
    }
  }

  var isCustom: Bool {
    switch self {
    case .custom:
      return true
    default:
      return false
    }
  }

  public init(name: String?, fallback: Module = .host) {
    let cleaned = name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    self = cleaned.isEmpty ? fallback : .custom(name: cleaned)
  }

  public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
    self = .custom(name: value)
  }

  public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
    self = .custom(name: value)
  }

  public init(stringLiteral value: StringLiteralType) {
    self = .custom(name: value)
  }

  static public func ==(lhs: Module, rhs: Module) -> Bool {
    return lhs.hashValue == rhs.hashValue
  }
}
