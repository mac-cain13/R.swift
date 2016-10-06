//
//  Struct.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 10-12-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import Foundation

struct Struct: UsedTypesProvider, SwiftCodeConverible {
  let comments: [String]
  let accessModifier: AccessLevel
  let type: Type
  var implements: [TypePrinter]
  let typealiasses: [Typealias]
  var properties: [Let]
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

  init(comments: [String], accessModifier: AccessLevel, type: Type, implements: [TypePrinter], typealiasses: [Typealias], properties: [Let], functions: [Function], structs: [Struct]) {
    self.comments = comments
    self.accessModifier = accessModifier
    self.type = type
    self.implements = implements
    self.typealiasses = typealiasses
    self.properties = properties
    self.functions = functions
    self.structs = structs
  }

  var swiftCode: String {
    let commentsString = comments.map { "/// \($0)\n" }.joined(separator: "")
    let accessModifierString = (accessModifier == .Internal) ? "" : accessModifier.rawValue + " "
    let implementsString = implements.count > 0 ? ": " + implements.map { $0.swiftCode }.joined(separator: ", ") : ""

    let typealiasString = typealiasses
      .sorted { $0.alias < $1.alias }
      .joinWithSeparator("\n")

    let varsString = properties
      .map { $0.swiftCode }
      .sorted()
      .joined(separator: "\n")

    let functionsString = functions
      .map { $0.swiftCode }
      .sorted()
      .joined(separator: "\n\n")
    
    let structsString = structs
      .map { $0.swiftCode }
      .sorted()
      .joined(separator: "\n\n")


    // File private `init`, so that struct can't be initialized from the outside world
    let fileprivateInit = "fileprivate init() {}"

    let bodyComponents = [typealiasString, varsString, functionsString, structsString, fileprivateInit].filter { $0 != "" }
    let bodyString = bodyComponents.joined(separator: "\n\n").indentWithString(IndentationString)

    return "\(commentsString)\(accessModifierString)struct \(type)\(implementsString) {\n\(bodyString)\n}"
  }
}
