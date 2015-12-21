//
//  Function.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 10-12-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import Foundation

struct Function: TypeSequenceProvider {
  let isStatic: Bool
  let name: String
  let generics: String?
  let parameters: [Parameter]
  let returnType: Type
  let body: String

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
    let staticString = isStatic ? "static " : ""
    let genericsString = generics.map { "<\($0)>" } ?? ""
    let parameterString = parameters.joinWithSeparator(", ")
    let returnString = Type._Void == returnType ? "" : " -> \(returnType)"
    let bodyString = body.indentWithString(IndentationString)
    return "\(staticString)func \(callName)\(genericsString)(\(parameterString))\(returnString) {\n\(bodyString)\n}"
  }

  struct Parameter: TypeSequenceProvider, CustomStringConvertible {
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
