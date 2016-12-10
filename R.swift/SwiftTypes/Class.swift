//
//  Class.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 10-12-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

struct Class: SwiftCodeConverible {
  let accessModifier: AccessLevel
  let type: Type

  var swiftCode: String {
    let accessModifierString = (accessModifier == .Internal) ? "" : accessModifier.rawValue + " "

    return "\(accessModifierString)class \(type) {}"
  }
}
