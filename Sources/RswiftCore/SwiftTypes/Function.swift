//
//  Function.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 10-12-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

struct Function: UsedTypesProvider, SwiftCodeConverible {
  let availables: [String]
  let comments: [String]
  let accessModifier: AccessLevel
  let isStatic: Bool
  let isMainActor: Bool
  let name: SwiftIdentifier
  let generics: String?
  let parameters: [Parameter]
  let doesThrow: Bool
  let returnType: Type
  let body: String
  let os: [String]

  var usedTypes: [UsedType] {
    return [
      returnType.usedTypes,
      parameters.flatMap(getUsedTypes),
    ]
    .joined()
    .array()
  }

  var swiftCode: String {
    let commentsString = comments.map { $0.isEmpty ? "///\n" : "/// \($0)\n" }.joined(separator: "")
    let availablesString = availables.map { "@available(\($0))\n" }.joined(separator: "")
    let mainActorString = isMainActor ? "@MainActor\n" : ""
    let accessModifierString = accessModifier.swiftCode
    let staticString = isStatic ? "static " : ""
    let genericsString = generics.map { "<\($0)>" } ?? ""
    let parameterString = parameters.map { $0.description }.joined(separator: ", ")
    let throwString = doesThrow ? " throws" : ""
    let returnString = Type._Void == returnType ? "" : " -> \(returnType)"
    let bodyString = body.indent(with: "  ")

    return OSPrinter(code: "\(commentsString)\(availablesString)\(mainActorString)\(accessModifierString)\(staticString)func \(name)\(genericsString)(\(parameterString))\(throwString)\(returnString) {\n\(bodyString)\n}", supportedOS: os).swiftCode
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
      return SwiftIdentifier(name: name, lowercaseStartingCharacters: true)
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
