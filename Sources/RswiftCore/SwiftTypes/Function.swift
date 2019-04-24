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
    guard
      name != "validate", // We won't be calling this from Objective-C code.
      returnType.name != Type.TypedStoryboardSegueInfo.name, // This is a Swift only type.
      !availables.contains(where: { $0.contains("deprecated") }), // Don't bring over deprecated functions.
      !name.description.contains("`") // Don't convert functions with a name Objective-C can't understand
    else {
      return ""
    }
    let commentsString = comments.map { "/// \($0)\n" }.joined(separator: "")
    let availablesString = availables.map { "@available(\($0))\n" }.joined(separator: "")
    let accessModifierString = accessModifier.swiftCode
    let staticString = isStatic ? "static " : ""
    let genericsString = generics.map { "<\($0)>" } ?? ""

    let objcParams = parameters.filter { $0.type != Type._Void }
    
    let allParameterString = objcParams.map { $0.descriptionWithoutDefaultValue }.joined(separator: ", ")
    let allParameterInjection = objcParams
      .map {
        let argName = ($0.name == "_") ? "" : "\($0.name): "
        return "\(argName)\($0.localName ?? $0.name)"
      }
      .joined(separator: ", ")

    // Required if the param is not optional, or there isn't a default value.
    let requiredParams = objcParams.filter { !$0.type.optional || $0.defaultValue == nil }
    let requiredParameterString = requiredParams.map { $0.descriptionWithoutDefaultValue }.joined(separator: ", ")
    let requiredParameterInjection = requiredParams
      .map {
        let argName = ($0.name == "_") ? "" : "\($0.name): "
        return "\(argName)\($0.localName ?? $0.name)"
      }
      .joined(separator: ", ")
    
    let shouldHaveShortenedFunction = requiredParams.count != objcParams.count
    
    let throwString = doesThrow ? " throws" : ""
    let returnString = Type._Void == returnType ? "" : " -> \(returnType)"
    let bodyStringAllParams = "return \(prefix).\(name)(\(allParameterInjection))".indent(with: "  ")
    let bodyStringRequiredParams = "return \(prefix).\(name)(\(requiredParameterInjection))".indent(with: "  ")
    let functionName = "\(prefix)_\(name)"
      .replacingOccurrences(of: ".", with: "_")
      .replacingOccurrences(of: "R_", with: "")
    
    let requiredParamsFunction = "\(commentsString)\(availablesString)\(accessModifierString)\(staticString)func \(functionName)\(genericsString)(\(requiredParameterString))\(throwString)\(returnString) {\n\(bodyStringRequiredParams)\n}"
    let allParamsFunction = "\(commentsString)\(availablesString)\(accessModifierString)\(staticString)func \(functionName)\(genericsString)(\(allParameterString))\(throwString)\(returnString) {\n\(bodyStringAllParams)\n}"
    if shouldHaveShortenedFunction {
      return "\(requiredParamsFunction)\n\n\(allParamsFunction)\n"
    } else {
      return "\(allParamsFunction)\n"
    }
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
      return defaultValue.map({ "\(descriptionWithoutDefaultValue) = \($0)" }) ?? descriptionWithoutDefaultValue
    }
    
    var descriptionWithoutDefaultValue: String {
        return localName.map({ "\(swiftIdentifier) \($0): \(type)" }) ?? "\(swiftIdentifier): \(type)"
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
