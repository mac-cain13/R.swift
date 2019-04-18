//
//  Function.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 10-12-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

struct Function: UsedTypesProvider, SwiftCodeConverible, ObjcCodeConvertible {
  let availables: [String]
  let comments: [String]
  let accessModifier: AccessLevel
  let isStatic: Bool
  let name: SwiftIdentifier
  let generics: String?
  let parameters: [Parameter]
  let doesThrow: Bool
  let returnType: Type
  let body: String

  var usedTypes: [UsedType] {
    return [
      returnType.usedTypes,
      parameters.flatMap(getUsedTypes),
    ]
    .joined()
    .array()
  }

  var swiftCode: String {
    let commentsString = comments.map { "/// \($0)\n" }.joined(separator: "")
    let availablesString = availables.map { "@available(\($0))\n" }.joined(separator: "")
    let accessModifierString = accessModifier.swiftCode
    let staticString = isStatic ? "static " : ""
    let genericsString = generics.map { "<\($0)>" } ?? ""
    let parameterString = parameters.map { $0.description }.joined(separator: ", ")
    let throwString = doesThrow ? " throws" : ""
    let returnString = Type._Void == returnType ? "" : " -> \(returnType)"
    let bodyString = body.indent(with: "  ")

    return "\(commentsString)\(availablesString)\(accessModifierString)\(staticString)func \(name)\(genericsString)(\(parameterString))\(throwString)\(returnString) {\n\(bodyString)\n}"
  }
    
  func objcCode(prefix: String) -> String {
    guard returnType == Type._UIImage || returnType == Type._UIImage.asOptional() else { return "" }
    //let commentsString = comments.map { "/// \($0)\n" }.joined(separator: "")
    let availablesString = availables.map { "@available(\($0))\n" }.joined(separator: "")
    let accessModifierString = accessModifier.swiftCode
    let staticString = isStatic ? "static " : ""
    let genericsString = generics.map { "<\($0)>" } ?? ""
    let parameterString = parameters.map { $0.description }.joined(separator: ", ")
    let parameterInjection = parameters
        .map {
            let argName = ($0.name == "_") ? "" : "\($0.name): "
            return "\(argName)\($0.localName ?? $0.name)"
        }
        .joined(separator: ", ")
    let throwString = doesThrow ? " throws" : ""
    let returnString = Type._Void == returnType ? "" : " -> \(returnType)"
    //let bodyStringWithParams = "return \(prefix).\(name)(\(parameterInjection))".indent(with: "  ")
    let bodyStringWithoutParams = "return \(prefix).\(name)()".indent(with: "  ")
    let functionName = "\(prefix)_\(name)"
        .replacingOccurrences(of: ".", with: "_")
        .replacingOccurrences(of: "R_", with: "")
    
    // This is really all I need. Unsure if I should make all options available to Obj-C.
    return "  \(availablesString)\(accessModifierString)\(staticString)func \(functionName)\(genericsString)()\(throwString)\(returnString){ \(bodyStringWithoutParams) }"
    
//    let withParams = "\(commentsString)\(availablesString)\(accessModifierString)\(staticString)func \(functionName)\(genericsString)(\(parameterString))\(throwString)\(returnString) {\n\(bodyStringWithParams)\n}"
//
//    let withoutParams = "\(commentsString)\(availablesString)\(accessModifierString)\(staticString)func \(functionName)\(genericsString)()\(throwString)\(returnString) {\n\(bodyStringWithoutParams)\n}"
//
//    return "\(withParams)\n\n\(withoutParams)"
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
