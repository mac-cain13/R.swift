//
//  Typealias.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 10-12-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

struct Typealias: UsedTypesProvider, CustomStringConvertible {
  let accessModifier: AccessLevel
  let alias: String
  let type: Type?

  var usedTypes: [UsedType] {
    return type?.usedTypes ?? []
  }

  var description: String {
    let accessModifierString = (accessModifier == .Internal) ? "" : accessModifier.rawValue + " "
    let typeString = type.map { " = \($0)" } ?? ""

    return "\(accessModifierString)typealias \(alias)\(typeString)"
  }
}
