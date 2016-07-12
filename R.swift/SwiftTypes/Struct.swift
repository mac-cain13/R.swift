//
//  Struct.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 10-12-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import Foundation

struct Struct: UsedTypesProvider, CustomStringConvertible {
  var comments: [String] = []
  var accessModifier: AccessModifier = .Internal
  let type: Type
  var implements: [TypePrinter]
  let typealiasses: [Typealias]
  let properties: [Property]
  var functions: [Function]
  var structs: [Struct]

  var usedTypes: [UsedType] {
    return [
        type.usedTypes,
        implements.flatMap(getUsedTypes),
        typealiasses.flatMap(getUsedTypes),
        properties.flatMap(getUsedTypes),
        functions.flatMap(getUsedTypes),
        structs.flatMap(getUsedTypes),
      ].flatten()
  }

  init(accessModifier: AccessModifier, type: Type, implements: [TypePrinter], typealiasses: [Typealias], properties: [Property], functions: [Function], structs: [Struct]) {
    self.accessModifier = accessModifier
    self.type = type
    self.implements = implements
    self.typealiasses = typealiasses
    self.properties = properties
    self.functions = functions
    self.structs = structs
  }

  init(comments: [String], type: Type, implements: [TypePrinter], typealiasses: [Typealias], properties: [Property], functions: [Function], structs: [Struct]) {
    self.comments = comments
    self.type = type
    self.implements = implements
    self.typealiasses = typealiasses
    self.properties = properties
    self.functions = functions
    self.structs = structs
  }

  init(type: Type, implements: [TypePrinter], typealiasses: [Typealias], properties: [Property], functions: [Function], structs: [Struct]) {
    self.type = type
    self.implements = implements
    self.typealiasses = typealiasses
    self.properties = properties
    self.functions = functions
    self.structs = structs
  }

  var description: String {
    let commentsString = comments.map { "/// \($0)\n" }.joined(separator: "")
    let accessModifierString = (accessModifier == .Internal) ? "" : accessModifier.rawValue + " "
    let implementsString = implements.count > 0 ? ": " + implements.map { $0.swiftCode }.joined(separator: ", ") : ""

    let typealiasString = typealiasses
      .sorted { $0.alias < $1.alias }
      .joined(separator: "\n")

    let varsString = properties
      .sorted {  $0.callName < $1.callName }
      .map { $0.description }
      .joined(separator: "\n")
    let functionsString = functions
      .sorted { $0.callName < $1.callName }
      .map { $0.description }
      .joined(separator: "\n\n")
    let structsString = structs
      .sorted { $0.type.description < $1.type.description }
      .joined(separator: "\n\n")


    // Private `init`, so that struct can't be initialized externally.
    let privateInit = "private init() {}"

    let bodyComponents = [typealiasString, varsString, functionsString, structsString, privateInit].filter { $0 != "" }
    let bodyString = bodyComponents.joined(separator: "\n\n").indent(with: IndentationString)

    return "\(commentsString)\(accessModifierString)struct \(type)\(implementsString) {\n\(bodyString)\n}"
  }
}
