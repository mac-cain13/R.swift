//
//  Property.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 05-01-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

protocol Property: UsedTypesProvider, CustomStringConvertible {
  var name: String { get }
}

extension Property {
  var callName: String {
    return sanitizedSwiftName(name, lowercaseFirstCharacter: true)
  }
}
