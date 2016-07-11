//
//  Function.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 10-12-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import Foundation

struct Function: UsedTypesProvider {
  let comments: [String]
  let isStatic: Bool
  let name: String
  let generics: String?
  let parameters: [Parameter]
  let doesThrow: Bool
  let returnType: Type
  let body: String

  init(isStatic: Bool, name: String, generics: String?, parameters: [Parameter], doesThrow: Bool, returnType: Type, body: String) {
    self.comments = []
    self.isStatic = isStatic
    self.name = name
    self.generics = generics
    self.parameters = parameters
    self.doesThrow = doesThrow
    self.returnType = returnType
    self.body = body
  }

  init(comments: [String], isStatic: Bool, name: String, generics: String?, parameters: [Parameter], doesThrow: Bool, returnType: Type, body: String) {
    self.comments = comments
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

  var callName: String {
    return sanitizedSwiftName(name, lowercaseFirstCharacter: true)
  }

  var description: String {
    let commentsString = comments.map { "/// \($0)\n" }.joined(separator: "")
    let staticString = isStatic ? "static " : ""
    let genericsString = generics.map { "<\($0)>" } ?? ""
    let parameterString = parameters.joined(separator: ", ")
    let throwString = doesThrow ? " throws" : ""
    let returnString = Type._Void == returnType ? "" : " -> \(returnType)"
    let bodyString = body.indent(with: IndentationString)

    return "\(commentsString)\(staticString)func \(callName)\(genericsString)(\(parameterString))\(throwString)\(returnString) {\n\(bodyString)\n}"
  }

  struct Parameter: UsedTypesProvider, CustomStringConvertible {
    let name: String
    let localName: String?
    let type: Type
    let defaultValue: String?

    var usedTypes: [UsedType] {
      return type.usedTypes
    }

    var swiftName: String {
      return sanitizedSwiftName(name, lowercaseFirstCharacter: true)
    }

    var description: String {
      let definition = localName.map({ "\(self.swiftName) \($0): \(type)" }) ?? "\(swiftName): \(type)"
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
