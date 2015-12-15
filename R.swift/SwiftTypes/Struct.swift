//
//  Struct.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 10-12-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import Foundation

struct Struct: CustomStringConvertible {
  let type: Type
  let implements: [Type]
  let typealiasses: [Typealias]
  let vars: [Var]
  let functions: [Function]
  let structs: [Struct]
  
  init(type: Type, implements: [Type], typealiasses: [Typealias], vars: [Var], functions: [Function], structs: [Struct]) {
    self.type = type
    self.implements = implements
    self.typealiasses = typealiasses
    self.vars = vars
    self.functions = functions
    self.structs = structs
  }

  var description: String {
    let implementsString = implements.count > 0 ? ": " + implements.joinWithSeparator(", ") : ""

    let typealiasString = typealiasses
      .sort { $0.alias < $1.alias }
      .joinWithSeparator("\n")

    let varsString = vars
      .sort { sanitizedSwiftName($0.name) < sanitizedSwiftName($1.name) }
      .joinWithSeparator("\n")
    let functionsString = functions
      .sort { $0.callName < $1.callName }
      .map { $0.description }
      .joinWithSeparator("\n\n")
    let structsString = structs
      .sort { $0.type.description < $1.type.description }
      .joinWithSeparator("\n\n")

    let bodyComponents = [typealiasString, varsString, functionsString, structsString].filter { $0 != "" }
    let bodyString = bodyComponents.joinWithSeparator("\n\n").indentWithString(IndentationString)
    return "struct \(type)\(implementsString) {\n\(bodyString)\n}"
  }
}
