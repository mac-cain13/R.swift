//
//  ValidatedStructGenerator.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 05-10-16.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

class ValidatedStructGenerator: StructGenerator {
  private let validationSubject: StructGenerator.Result

  init(validationSubject: StructGenerator.Result) {
    self.validationSubject = validationSubject
  }

  func generatedStructs(at externalAccessLevel: AccessLevel, prefix: SwiftIdentifier, bundle: BundleExpression) -> StructGenerator.Result {

    let internalStruct = validationSubject.internalStruct?
      .addingChildStructValidationMethods(at: externalAccessLevel)

    let validationFunctionBody: String
    if let internalStruct = internalStruct, internalStruct.implements.map({ $0.type }).contains(Type.Validatable) {
      validationFunctionBody = OSPrinter(code: "try \(internalStruct.type).validate()", supportedOS: internalStruct.os).swiftCode
    } else {
      validationFunctionBody = "// There are no resources to validate"
    }

    let validationStruct = Struct(
      availables: [],
      comments: [],
      accessModifier: .filePrivate,
      type: Type(module: .host, name: "intern"),
      implements: [TypePrinter(type: Type.Validatable)],
      typealiasses: [],
      properties: [],
      functions: [
        Function(
          availables: [],
          comments: [],
          accessModifier: .filePrivate,
          isStatic: true,
          name: "validate",
          generics: nil,
          parameters: [],
          doesThrow: true,
          returnType: Type._Void,
          body: validationFunctionBody,
          os: []
        )
      ],
      structs: [],
      classes: [],
      os: []
    )

    var externalStruct = validationSubject.externalStruct
    externalStruct.structs.append(validationStruct)

    return (
      externalStruct.addingChildStructValidationMethods(at: externalAccessLevel),
      internalStruct
    )
  }
}

private extension Struct {
  /// Implements the Validatable protocol on this and child struct if one or more childs already implement the
  /// Validatable protocol. The newly created validate methods will call their child validate methods.
  func addingChildStructValidationMethods(at externalAccessLevel: AccessLevel) -> Struct {
    if implements.map({ $0.type }).contains(Type.Validatable) {
      return self
    }

    let childStructs = structs
      .map { $0.addingChildStructValidationMethods(at: externalAccessLevel) }

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
        availables: [],
        comments: [],
        accessModifier: externalAccessLevel,
        isStatic: true,
        name: "validate",
        generics: nil,
        parameters: [],
        doesThrow: true,
        returnType: Type._Void,
        body: validatableStructs
          .map { OSPrinter(code: "try \($0.type).validate()", supportedOS: $0.os).swiftCode }
            .joined(separator: "\n"),
        os: []
      )
    )

    return outputStruct
  }
}
