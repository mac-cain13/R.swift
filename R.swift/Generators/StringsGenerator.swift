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
  let internalStruct: Struct?

  init(strings: Strings?) {
    externalStruct = Struct(
      type: Type(module: .Host, name: "string"),
      implements: [],
      typealiasses: [],
      properties: strings?.localizedKeys.keys.map {
        Let(isStatic: true, name: $0, typeDefinition: .Inferred(Type.Strings), value: "_R.string.localizedString(\"\($0)\")")
      } ?? [],
      functions: [],
      structs: []
    )

    internalStruct = Struct(
      type: Type(module: .Host, name: "string"),
      implements: [],
      typealiasses: [],
      properties: [],
      functions: [StringsGenerator.localizedStringFunction()],
      structs: []
    )
  }

  private static func localizedStringFunction() -> Function {
    return Function(
      isStatic: true,
      name: "LocalizedString",
      generics: nil,
      parameters: [
        Function.Parameter(name: "key", localName: nil, type: Type._String),
        Function.Parameter(name: "arguments", localName: nil, type: Type._CVarArgType)
      ],
      doesThrow: false,
      returnType: Type._String,
      body: "return String(format: NSLocalizedString(key, comment: \"\"), arguments: arguments)"
    )
  }
}
