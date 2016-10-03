//
//  UsedTypesProvider.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 16-12-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import Foundation

protocol UsedTypesProvider {
  var usedTypes: [UsedType] { get }
}

func getUsedTypes(from provider: UsedTypesProvider) -> [UsedType] {
  return provider.usedTypes
}
