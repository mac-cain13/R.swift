//
//  Struct+ChildValidation.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 22-12-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import Foundation

extension Struct {
  /// Implements the Validatable protocol on this and child struct if one or more childs already implement the 
  /// Validatable protocol. The newly created validate methods will call their child validate methods.
  func addChildStructValidationMethods() -> Struct {
    if implements.map({ $0.type }).contains(Type.Validatable) {
      return self
    }

    let childStructs = structs
      .map { $0.addChildStructValidationMethods() }

    let validatableStructs = childStructs
      .filter { $0.implements.map({ $0.type }).contains(Type.Validatable) }

    guard validatableStructs.count > 0 else {
      return self
    }

    var outputStruct = self
    outputStruct.structs = childStructs
    outputStruct.implements.append(TypePrinter(type: Type.Validatable))
    outputStruct.functions.append(
      Function(
        isStatic: true,
        name: "validate",
        generics: nil,
        parameters: [],
        doesThrow: true,
        returnType: Type._Void,
        body: validatableStructs
          .map { "try \($0.type).validate()" }
          .joined(separator: "\n")
      )
    )
    
    return outputStruct
  }
}
