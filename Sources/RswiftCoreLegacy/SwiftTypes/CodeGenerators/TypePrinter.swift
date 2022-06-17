//
//  TypePrinter.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 14-01-16.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

struct TypePrinter: SwiftCodeConverible, UsedTypesProvider {
  let type: Type

  var usedTypes: [UsedType] {
    return type.usedTypes
  }

  var swiftCode: String {
    let optionalSuffix = type.optional ? "?" : ""
    let args = type.genericArgs.map { $0.description }.joined(separator: ", ")

    let withoutModule: String
    if type.genericArgs.isEmpty {
      withoutModule = "\(type.name)"
    } else if type.name == Type._Tuple.name {
      withoutModule = "(\(args))"
    } else if type.name == Type._Array.name {
      withoutModule = "[\(args)]"
    } else {
      withoutModule = "\(type.name)<\(args)>"
    }

    if case let .custom(name: moduleName) = type.module {
      return "\(moduleName).\(withoutModule)\(optionalSuffix)"
    } else {
      return "\(withoutModule)\(optionalSuffix)"
    }
  }

  init(type: Type) {
    self.type = type
  }
}

