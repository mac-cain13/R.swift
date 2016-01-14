//
//  TypePrinter.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 14-01-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

struct TypePrinter: SwiftCodeConverible, UsedTypesProvider {
  enum Style {
    case FullyQualified
    case WithoutModule
  }

  let type: Type
  let style: Style

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

    switch (style, type.module) {
    case (.FullyQualified, let .Custom(moduleName)):
      return "\(moduleName).\(withoutModule)"
    case (.FullyQualified, _), (.WithoutModule, _):
      return withoutModule
    }
  }

  init(type: Type) {
    self.type = type
    self.style = .WithoutModule
  }

  init(type: Type, style: Style) {
    self.type = type
    self.style = style
  }
}

