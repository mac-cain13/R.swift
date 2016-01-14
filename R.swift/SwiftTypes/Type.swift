//
//  Type.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 10-12-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import Foundation

struct UsedType {
  let type: Type

  private init(type: Type) {
    self.type = type
  }
}

struct Type: UsedTypesProvider, CustomStringConvertible, Hashable {
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
  static let _UITraitCollection = Type(module: "UIKit", name: "UITraitCollection")
  static let _UIViewController = Type(module: "UIKit", name: "UIViewController")
  static let _UIFont = Type(module: "UIKit", name: "UIFont")
  static let _CGFloat = Type(module: .StdLib, name: "CGFloat")

  static let ReuseIdentifier = Type(module: "Rswift", name: "ReuseIdentifier", genericArgs: [TypeVar(description: "T", usedTypes: [])])
  static let ReuseIdentifierType = Type(module: "Rswift", name: "ReuseIdentifierType")
  static let StoryboardResourceType = Type(module: "Rswift", name: "StoryboardResourceType")
  static let StoryboardResourceWithInitialControllerType = Type(module: "Rswift", name: "StoryboardResourceWithInitialControllerType")
  static let NibResourceType = Type(module: "Rswift", name: "NibResourceType")
  static let FileResource = Type(module: "Rswift", name: "FileResource")
  static let FontResource = Type(module: "Rswift", name: "FontResource")
  static let ImageResource = Type(module: "Rswift", name: "ImageResource")
  static let Validatable = Type(module: "Rswift", name: "Validatable")
  static let TypedStoryboardSegueInfo = Type(module: "Rswift", name: "TypedStoryboardSegueInfo", genericArgs: [TypeVar(description: "Segue", usedTypes: []), TypeVar(description: "Source", usedTypes: []), TypeVar(description: "Destination", usedTypes: [])])

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
