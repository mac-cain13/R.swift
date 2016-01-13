//
//  TypeSequenceProvider.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 16-12-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import Foundation

protocol TypeSequenceProvider {
  var usedTypes: [UsedType] { get }
}

func getUsedTypes(provider: TypeSequenceProvider) -> [UsedType] {
  return provider.usedTypes
}
