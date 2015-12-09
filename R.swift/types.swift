//
//  types.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 30-01-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

// MARK: Helper types

typealias Reusable = (identifier: String, type: Type)

protocol ReusableContainer {
  var reusables: [Reusable] { get }
}

/// MARK: Swift types

typealias TypeVar = String

struct Type: CustomStringConvertible, Equatable, Hashable {
  static let _Void = Type(name: "Void")
  static let _AnyObject = Type(name: "AnyObject")
  static let _String = Type(name: "String")
  static let _NSURL = Type(name: "NSURL")
  static let _UINib = Type(name: "UINib")
  static let _UIView = Type(name: "UIView")
  static let _UIImage = Type(name: "UIImage")
  static let _NSBundle = Type(name: "NSBundle")
  static let _NSIndexPath = Type(name: "NSIndexPath")
  static let _UITableView = Type(name: "UITableView")
  static let _UITableViewCell = Type(name: "UITableViewCell")
  static let _UITableViewHeaderFooterView = Type(name: "UITableViewHeaderFooterView")
  static let _UIStoryboard = Type(name: "UIStoryboard")
  static let _UIStoryboardSegue = Type(name: "UIStoryboardSegue")
  static let _UICollectionView = Type(name: "UICollectionView")
  static let _UICollectionViewCell = Type(name: "UICollectionViewCell")
  static let _UICollectionReusableView = Type(name: "UICollectionReusableView")
  static let _UIViewController = Type(name: "UIViewController")
  static let _UIFont = Type(name: "UIFont")
  static let _CGFloat = Type(name: "CGFloat")

  static let ReuseIdentifier = Type(name: "ReuseIdentifier", genericArgs: ["T"])
  static let ReuseIdentifierProtocol = Type(name: "ReuseIdentifierProtocol")
  static let NibResourceProtocol = Type(name: "NibResource")

  let module: String?
  let name: String
  let genericArgs: [TypeVar]
  let optional: Bool

  var fullyQualifiedName: String {
    let optionalString = optional ? "?" : ""

    if genericArgs.count > 0 {
      let args = genericArgs.joinWithSeparator(", ")
      return "\(fullName)<\(args)>\(optionalString)"
    }

    return "\(fullName)\(optionalString)"
  }

  private var fullName: String {
    if let module = module {
      return "\(module).\((name))"
    }

    return name
  }

  var description: String {
    if module == productModuleName {
      return Type(module: nil, name: name, genericArgs: genericArgs, optional: optional).fullyQualifiedName
    } else {
      return fullyQualifiedName
    }
  }

  var hashValue: Int {
    let optionalString = optional ? "?" : ""
    return "\(fullName)\(optionalString)".hashValue
  }

  init(name: String, genericArgs: [TypeVar] = [], optional: Bool = false) {
    self.module = nil
    self.name = name
    self.genericArgs = genericArgs
    self.optional = optional
  }

  init(module: String?, name: String, genericArgs: [TypeVar] = [], optional: Bool = false) {
    self.module = module
    self.name = name
    self.genericArgs = genericArgs
    self.optional = optional
  }

  func asOptional() -> Type {
    return Type(module: module, name: name, genericArgs: genericArgs, optional: true)
  }

  func asNonOptional() -> Type {
    return Type(module: module, name: name, genericArgs: genericArgs, optional: false)
  }

  func withGenericArgs(genericArgs: [TypeVar]) -> Type {
    return Type(module: module, name: name, genericArgs: genericArgs, optional: optional)
  }


}

func ==(lhs: Type, rhs: Type) -> Bool {
  return (lhs.hashValue == rhs.hashValue)
}

struct Typealias: CustomStringConvertible {
  let alias: Type
  let type: Type?

  var description: String {
    let typeString = type.map { " = \($0)" } ?? ""

    return "typealias \(alias)\(typeString)"
  }
}

struct Var: CustomStringConvertible {
  let isStatic: Bool
  let name: String
  let type: Type
  let getter: String

  var callName: String {
    return sanitizedSwiftName(name, lowercaseFirstCharacter: true)
  }

  var description: String {
    let staticString = isStatic ? "static " : ""
    return "\(staticString)var \(callName): \(type) { \(getter) }"
  }
}

struct Let: CustomStringConvertible {
  let name: String
  let type: Type

  var callName: String {
    return sanitizedSwiftName(name, lowercaseFirstCharacter: true)
  }

  var description: String {
    return "let \(callName): \(type)"
  }
}

protocol Func: CustomStringConvertible {
  var callName: String { get }
}

struct Function: Func {
  let isStatic: Bool
  let name: String
  let generics: String?
  let parameters: [Parameter]
  let returnType: Type
  let body: String

  var callName: String {
    return sanitizedSwiftName(name, lowercaseFirstCharacter: true)
  }

  var description: String {
    let staticString = isStatic ? "static " : ""
    let genericsString = generics.map { "<\($0)>" } ?? ""
    let parameterString = parameters.joinWithSeparator(", ")
    let returnString = Type._Void == returnType ? "" : " -> \(returnType)"
    return "\(staticString)func \(callName)\(genericsString)(\(parameterString))\(returnString) {\n\(indent(body))\n}"
  }

  struct Parameter: CustomStringConvertible {
    let name: String
    let localName: String?
    let type: Type
    let defaultValue: String?

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

struct Initializer: Func {
  let type: Type
  let isFailable: Bool
  let parameters: [Function.Parameter]
  let body: String

  let callName = "init"

  var description: String {
    let fullName = [type.description, callName].joinWithSeparator(" ")
    let optionalString = isFailable ? "?" : ""
    let parameterString = parameters.joinWithSeparator(", ")
    return "\(fullName)\(optionalString)(\(parameterString)) {\n\(indent(body))\n}"
  }

  enum Type: CustomStringConvertible {
    case Designated
    case Required
    case Convenience

    var description: String {
      switch self {
      case .Designated: return ""
      case .Required: return "required"
      case .Convenience: return "convenience"
      }
    }
  }
}

struct Protocol: CustomStringConvertible {
  let type: Type
  let typealiasses: [Typealias]
  let vars: [Var]

  var description: String {
    let typealiassesString = typealiasses
      .sort { sanitizedSwiftName($0.alias.fullyQualifiedName) < sanitizedSwiftName($1.alias.fullyQualifiedName) }
      .joinWithSeparator("\n")
    let varsString = vars
      .sort { sanitizedSwiftName($0.name) < sanitizedSwiftName($1.name) }
      .joinWithSeparator("\n")

    let bodyComponents = [typealiassesString, varsString].filter { $0 != "" }
    let bodyString = indent(bodyComponents.joinWithSeparator("\n\n"))
    return "protocol \(type) {\n\(bodyString)\n}"
  }
}

struct Extension: CustomStringConvertible {
  let type: Type
  let functions: [Func]

  var description: String {
    let functionsString = functions
      .sort { $0.callName < $1.callName }
      .map { $0.description }
      .joinWithSeparator("\n\n")

    let bodyComponents = [functionsString].filter { $0 != "" }
    let bodyString = indent(bodyComponents.joinWithSeparator("\n\n"))
    return "extension \(type) {\n\(bodyString)\n}"
  }
}

struct Struct: CustomStringConvertible {
  let type: Type
  let implements: [Type]
  let typealiasses: [Typealias]
  let vars: [Var]
  let lets: [Let]
  let functions: [Func]
  let structs: [Struct]

  init(type: Type, lets: [Let], vars: [Var], functions: [Func], structs: [Struct]) {
    self.type = type
    self.implements = []
    self.typealiasses = []
    self.lets = lets
    self.vars = vars
    self.functions = functions
    self.structs = structs
  }

  init(type: Type, implements: [Type], lets: [Let], vars: [Var], functions: [Func], structs: [Struct]) {
    self.type = type
    self.implements = implements
    self.typealiasses = []
    self.vars = vars
    self.lets = lets
    self.functions = functions
    self.structs = structs
  }

  init(type: Type, implements: [Type], typealiasses: [Typealias], lets: [Let], vars: [Var], functions: [Func], structs: [Struct]) {
    self.type = type
    self.implements = implements
    self.typealiasses = typealiasses
    self.vars = vars
    self.lets = lets
    self.functions = functions
    self.structs = structs
  }

  var description: String {
    let implementsString = implements.count > 0 ? ": " + implements.joinWithSeparator(", ") : ""

    let typealiasString = typealiasses
      .sort { $0.alias.description < $1.alias.description }
      .joinWithSeparator("\n")

    let letsString = lets
      .sort { sanitizedSwiftName($0.name) < sanitizedSwiftName($1.name) }
      .joinWithSeparator("\n")
    let varsString = vars
      .sort { sanitizedSwiftName($0.name) < sanitizedSwiftName($1.name) }
      .joinWithSeparator("\n")
    let functionsString = functions
      .sort { $0.callName < $1.callName }
      .map { $0.description }
      .joinWithSeparator("\n\n")
    let structsString = structs
      .sort { $0.type.description < $1.type.description }
      .joinWithSeparator("\n\n")

    let bodyComponents = [typealiasString, letsString, varsString, functionsString, structsString].filter { $0 != "" }
    let bodyString = indent(bodyComponents.joinWithSeparator("\n\n"))
    return "struct \(type)\(implementsString) {\n\(bodyString)\n}"
  }
}
