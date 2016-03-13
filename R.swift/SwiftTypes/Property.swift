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

struct AnyProperty: Property {
  let property: Property

  init(property: Property) {
    self.property = property
  }

  var name: String {
    return self.property.name
  }

  var usedTypes: [UsedType] {
    return self.property.usedTypes
  }

  var description: String {
    return self.property.description
  }
}

extension Property {
  var callName: String {
    return sanitizedSwiftName(name, lowercaseFirstCharacter: true)
  }
}

/// Type-erasure function
func anyProperty(property: Property) -> Property {
  return property
}
