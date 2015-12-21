//
//  Type.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 10-12-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import Foundation

struct TypeVar: TypeSequenceProvider, CustomStringConvertible {
  let description: String
  let usedTypes: [UsedType]

  init(type: Type) {
    assert(type.genericArgs.count == 0, "TypeVars may not have generic args")

    description = type.description
    usedTypes = [type]
      .map { $0.withGenericArgs([] as [TypeVar]) } // Defensively handle if there are generic types
      .flatMap(getUsedTypes)
  }

  init(description: String, usedTypes: [Type]) {
    assert(usedTypes.flatMap { $0.genericArgs }.count == 0, "TypeVars may not have generic args")

    self.description = description
    self.usedTypes = usedTypes
      .map { $0.withGenericArgs([] as [TypeVar]) } // Defensively handle if there are generic types
      .flatMap(getUsedTypes)
  }
}

struct UsedType {
  let type: Type

  private init(type: Type) {
    self.type = type
  }
}

struct Type: TypeSequenceProvider, CustomStringConvertible, Hashable {
  static let _Void = Type(module: .StdLib, name: "Void")
  static let _AnyObject = Type(module: .StdLib, name: "AnyObject")
  static let _String = Type(module: .StdLib, name: "String")
  static let _NSURL = Type(module: "Foundation", name: "NSURL")
  static let _UINib = Type(module: "UIKit", name: "UINib")
  static let _UIView = Type(module: "UIKit", name: "UIView")
  static let _UIImage = Type(module: "UIKit", name: "UIImage")
  static let _NSBundle = Type(module: "Foundation", name: "NSBundle")
  static let _UIStoryboard = Type(module: "UIKit", name: "UIStoryboard")
  static let _UITableViewCell = Type(module: "UIKit", name: "UITableViewCell")
  static let _UICollectionViewCell = Type(module: "UIKit", name: "UICollectionViewCell")
  static let _UIStoryboardSegue = Type(module: "UIKit", name: "UIStoryboardSegue")
  static let _UIViewController = Type(module: "UIKit", name: "UIViewController")
  static let _UIFont = Type(module: "UIKit", name: "UIFont")
  static let _CGFloat = Type(module: .StdLib, name: "CGFloat")

  static let ReuseIdentifier = Type(module: "Rswift", name: "ReuseIdentifier", genericArgs: [TypeVar(description: "T", usedTypes: [])])
  static let ReuseIdentifierProtocol = Type(module: "Rswift", name: "ReuseIdentifierProtocol")
  static let NibResourceProtocol = Type(module: "Rswift", name: "NibResource")

  let module: Module
  let name: String
  let genericArgs: [TypeVar]
  let optional: Bool

  var usedTypes: [UsedType] {
    return [UsedType(type: self)] + genericArgs.flatMap(getUsedTypes)
  }

  var description: String {
    let optionalString = optional ? "?" : ""

    if genericArgs.count > 0 {
      let args = genericArgs.joinWithSeparator(", ")
      return "\(name)<\(args)>\(optionalString)"
    }

    return "\(name)\(optionalString)"
  }

  var hashValue: Int {
    return description.hashValue
  }

  init(module: Module, name: String, genericArgs: [TypeVar] = [], optional: Bool = false) {
    self.module = module
    self.name = name
    self.genericArgs = genericArgs
    self.optional = optional
  }

  init(module: Module, name: String, genericArgs: [Type], optional: Bool = false) {
    self.module = module
    self.name = name
    self.genericArgs = genericArgs.map { TypeVar(type: $0) }
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

  func withGenericArgs(genericArgs: [Type]) -> Type {
    return Type(module: module, name: name, genericArgs: genericArgs, optional: optional)
  }
}

func ==(lhs: Type, rhs: Type) -> Bool {
  return (lhs.hashValue == rhs.hashValue)
}
