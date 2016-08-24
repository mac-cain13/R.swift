//
//  Var.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 10-12-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import Foundation

struct Var: Property {
  let isStatic: Bool
  let name: SwiftIdentifier
  let type: Type
  let getter: String

  var usedTypes: [UsedType] {
    return type.usedTypes
  }

  var description: String {
    let staticString = isStatic ? "static " : ""
    return "\(staticString)var \(name): \(type) { \(getter) }"
  }
}
