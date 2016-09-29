//
//  TypePrinter.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 14-01-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

struct TypePrinter: SwiftCodeConverible, UsedTypesProvider {
  let type: Type

  var usedTypes: [UsedType] {
    return type.usedTypes
  }

  var swiftCode: String {
    let optionalString = type.optional ? "?" : ""

    let withoutModule: String
    if type.genericArgs.count > 0 {
      let args = type.genericArgs.joinWithSeparator(", ")
      withoutModule = "\(type.name)<\(args)>\(optionalString)"
    } else {
      withoutModule = "\(type.name)\(optionalString)"
    }

    if case let .custom(name: moduleName) = type.module {
      return "\(moduleName).\(withoutModule)"
    } else {
      return withoutModule
    }
  }

  init(type: Type) {
    self.type = type
  }
}

