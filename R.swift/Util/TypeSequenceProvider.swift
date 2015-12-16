//
//  TypeSequenceProvider.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 16-12-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import Foundation

protocol TypeSequenceProvider {
  var usedTypes: [Type] { get }
}

func getUsedTypes(provider: TypeSequenceProvider) -> [Type] {
  return provider.usedTypes
}
