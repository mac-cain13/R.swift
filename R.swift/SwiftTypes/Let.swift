//
//  Let.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 05-01-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

enum TypeDefinition: UsedTypesProvider {
  case Specified(Type)
  case Inferred(Type?)

  var type: Type? {
    switch self {
    case let .Specified(type): return type
    case let .Inferred(type): return type
    }
  }

  var usedTypes: [UsedType] {
    return type?.usedTypes ?? []
  }
}

struct Let: Property {
  let isStatic: Bool
  let name: String
  let typeDefinition: TypeDefinition
  let value: String

  var usedTypes: [UsedType] {
    return typeDefinition.usedTypes
  }

  var description: String {
    let staticString = isStatic ? "static " : ""

    let typeString: String
    switch typeDefinition {
    case let .Specified(type): typeString = ": \(type)"
    case .Inferred: typeString = ""
    }

    return "\(staticString)let \(callName)\(typeString) = \(value)"
  }
}
