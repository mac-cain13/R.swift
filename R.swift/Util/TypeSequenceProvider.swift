//
//  UsedTypesProvider.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 16-12-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

protocol UsedTypesProvider {
  var usedTypes: [UsedType] { get }
}

func getUsedTypes(from provider: UsedTypesProvider) -> [UsedType] {
  return provider.usedTypes
}
