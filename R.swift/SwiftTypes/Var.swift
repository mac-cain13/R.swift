//
//  Var.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 10-12-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import Foundation

struct Var: TypeSequenceProvider, CustomStringConvertible {
  let isStatic: Bool
  let name: String
  let type: Type
  let getter: String

  var usedTypes: [Type] {
    return [type]
  }

  var callName: String {
    return sanitizedSwiftName(name, lowercaseFirstCharacter: true)
  }

  var description: String {
    let staticString = isStatic ? "static " : ""
    return "\(staticString)var \(callName): \(type) { \(getter) }"
  }
}
