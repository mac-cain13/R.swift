//
//  StringsGenerator.swift
//  R.swift
//
//  Created by Nolan Warner on 2016/02/23.
//  Copyright © 2016 Nolan Warner. All rights reserved.
//

import Foundation

struct StringsGenerator: Generator {
  let externalStruct: Struct?
  let internalStruct: Struct? = nil
  
  init(strings: Strings?) {
    externalStruct = Struct(
      type: Type(module: .Host, name: "string"),
      implements: [],
      typealiasses: [],
      properties: strings?.localizedKeys.keys.map {
        Let(isStatic: true, name: $0, typeDefinition: .Inferred(Type.Strings), value: "NSLocalizedString(\"\($0)\", comment: \"\")")
      } ?? [],
      functions: [],
      structs: []
    )
  }
}
