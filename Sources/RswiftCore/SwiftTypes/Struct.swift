//
//  Struct.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 10-12-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

struct Struct: UsedTypesProvider, SwiftCodeConverible, ObjcCodeConvertible {
  let availables: [String]
  let comments: [String]
  let accessModifier: AccessLevel
  let type: Type
  var implements: [TypePrinter]
  let typealiasses: [Typealias]
  var properties: [Let]
  var functions: [Function]
  var structs: [Struct]
  var classes: [Class]

  var isEmpty: Bool {
    return properties.isEmpty
      && functions.isEmpty
      && (structs.isEmpty || structs.all { $0.isEmpty })
      && classes.isEmpty
  }

  var usedTypes: [UsedType] {
    return [
        type.usedTypes,
        implements.flatMap(getUsedTypes),
        typealiasses.flatMap(getUsedTypes),
        properties.flatMap(getUsedTypes),
        functions.flatMap(getUsedTypes),
        structs.flatMap(getUsedTypes),
      ]
      .joined()
      .array()
  }

  var swiftCode: String {
    let commentsString = comments.map { "/// \($0)\n" }.joined(separator: "")
    let availablesString = availables.map { "@available(\($0))\n" }.joined(separator: "")
    let accessModifierString = accessModifier.swiftCode
    let implementsString = implements.count > 0 ? ": " + implements.map { $0.swiftCode }.joined(separator: ", ") : ""

    let typealiasString = typealiasses
      .sorted { $0.alias < $1.alias }
      .map { $0.description }
      .joined(separator: "\n")

    let varsString = properties
      .map { $0.swiftCode }
      .sorted()
      .map { $0.description }
      .joined(separator: "\n")

    let functionsString = functions
      .map { $0.swiftCode }
      .sorted()
      .map { $0.description }
      .joined(separator: "\n\n")
    
    let structsString = structs
      .map { $0.swiftCode }
      .sorted()
      .map { $0.description }
      .joined(separator: "\n\n")

    let classesString = classes
      .map { $0.swiftCode }
      .sorted()
      .map { $0.description }
      .joined(separator: "\n\n")

    // File private `init`, so that struct can't be initialized from the outside world
    let fileprivateInit = "fileprivate init() {}"

    let bodyComponents = [typealiasString, varsString, functionsString, structsString, classesString, fileprivateInit].filter { $0 != "" }
    let bodyString = bodyComponents.joined(separator: "\n\n").indent(with: "  ")

    return "\(commentsString)\(availablesString)\(accessModifierString)struct \(type)\(implementsString) {\n\(bodyString)\n}"
  }
    
    func objcCode(prefix: String?) -> String {
        switch type.name.description {
        case "R":
            return "// Images yay"
        default:
            return ""
        }
    }
}
