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
  
  init(strings: Strings) {
    externalStruct = Struct(
      type: Type(module: .Host, name: "string"),
      implements: [],
      typealiasses: [],
      properties: [],
      functions: strings.localizedKeys.keys.map(StringsGenerator.stringFunction),
      structs: []
    )
  }

  private static func stringFunction(key: String) -> Function {
    return Function(
      comments: [],
      isStatic: true,
      name: key,
      generics: nil,
      parameters: [
        Function.Parameter(name: "_", type: Type._Void)
      ],
      doesThrow: false,
      returnType: Type._String,
      body: "return NSLocalizedString(\"\(key)\", comment: \"\")"
    )
  }
}
