//
//  Let.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 05-01-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

struct Let: Property {
  let isStatic: Bool
  let name: String
  let type: Type?
  let value: String

  var usedTypes: [UsedType] {
    return type?.usedTypes ?? []
  }

  var description: String {
    let staticString = isStatic ? "static " : ""
    let typeString = type.map { ": \($0)" } ?? ""
    return "\(staticString)let \(callName)\(typeString) = \(value)"
  }
}
