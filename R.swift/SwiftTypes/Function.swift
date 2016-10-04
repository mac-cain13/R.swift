//
//  Function.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 10-12-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import Foundation

struct Function: UsedTypesProvider, SwiftCodeConverible {
  let comments: [String]
  let accessModifier: AccessModifier
  let isStatic: Bool
  let name: SwiftIdentifier
  let generics: String?
  let parameters: [Parameter]
  let doesThrow: Bool
  let returnType: Type
  let body: String

  init(comments: [String], accessModifier: AccessModifier, isStatic: Bool, name: SwiftIdentifier, generics: String?, parameters: [Parameter], doesThrow: Bool, returnType: Type, body: String) {
    self.comments = comments
    self.accessModifier = accessModifier
    self.isStatic = isStatic
    self.name = name
    self.generics = generics
    self.parameters = parameters
    self.doesThrow = doesThrow
    self.returnType = returnType
    self.body = body
  }

  var usedTypes: [UsedType] {
    return [
      returnType.usedTypes,
      parameters.flatMap(getUsedTypes),
    ].flatten()
  }

  var swiftCode: String {
    let commentsString = comments.map { "/// \($0)\n" }.joined(separator: "")
    let accessModifierString = (accessModifier == .Internal) ? "" : accessModifier.rawValue + " "
    let staticString = isStatic ? "static " : ""
    let genericsString = generics.map { "<\($0)>" } ?? ""
    let parameterString = parameters.joinWithSeparator(", ")
    let throwString = doesThrow ? " throws" : ""
    let returnString = Type._Void == returnType ? "" : " -> \(returnType)"
    let bodyString = body.indentWithString(IndentationString)

    return "\(commentsString)\(accessModifierString)\(staticString)func \(name)\(genericsString)(\(parameterString))\(throwString)\(returnString) {\n\(bodyString)\n}"
  }

  struct Parameter: UsedTypesProvider, CustomStringConvertible {
    let name: String
    let localName: String?
    let type: Type
    let defaultValue: String?

    var usedTypes: [UsedType] {
      return type.usedTypes
    }

    var swiftIdentifier: SwiftIdentifier {
      return SwiftIdentifier(name: name, lowercaseFirstCharacter: true)
    }

    var description: String {
      let definition = localName.map({ "\(swiftIdentifier) \($0): \(type)" }) ?? "\(swiftIdentifier): \(type)"
      return defaultValue.map({ "\(definition) = \($0)" }) ?? definition
    }

    init(name: String, type: Type, defaultValue: String? = nil) {
      self.name = name
      self.localName = nil
      self.type = type
      self.defaultValue = defaultValue
    }

    init(name: String, localName: String?, type: Type, defaultValue: String? = nil) {
      self.name = name
      self.localName = localName
      self.type = type
      self.defaultValue = defaultValue
    }
  }
}
