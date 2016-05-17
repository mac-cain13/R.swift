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
  static let _Any = Type(module: .StdLib, name: "Any")
  static let _AnyObject = Type(module: .StdLib, name: "AnyObject")
  static let _String = Type(module: .StdLib, name: "String")
  static let _Int = Type(module: .StdLib, name: "Int")
  static let _UInt = Type(module: .StdLib, name: "UInt")
  static let _Double = Type(module: .StdLib, name: "Double")
  static let _Character = Type(module: .StdLib, name: "Character")
  static let _CStringPointer = Type(module: .StdLib, name: "UnsafePointer<unichar>")
  static let _VoidPointer = Type(module: .StdLib, name: "UnsafePointer<Void>")
  static let _NSURL = Type(module: "Foundation", name: "NSURL")
  static let _UINib = Type(module: "UIKit", name: "UINib")
  static let _UIView = Type(module: "UIKit", name: "UIView")
  static let _UIImage = Type(module: "UIKit", name: "UIImage")
  static let _NSBundle = Type(module: "Foundation", name: "NSBundle")
  static let _NSLocale = Type(module: "Foundation", name: "NSLocale")
  static let _UIStoryboard = Type(module: "UIKit", name: "UIStoryboard")
  static let _UITableViewCell = Type(module: "UIKit", name: "UITableViewCell")
  static let _UICollectionViewCell = Type(module: "UIKit", name: "UICollectionViewCell")
  static let _UICollectionReusableView = Type(module: "UIKit", name: "UICollectionReusableView")
  static let _UIStoryboardSegue = Type(module: "UIKit", name: "UIStoryboardSegue")
  static let _UITraitCollection = Type(module: "UIKit", name: "UITraitCollection")
  static let _UIViewController = Type(module: "UIKit", name: "UIViewController")
  static let _UIFont = Type(module: "UIKit", name: "UIFont")
  static let _UIColor = Type(module: "UIKit", name: "UIColor")
  static let _CGFloat = Type(module: .StdLib, name: "CGFloat")
  static let _CVarArgType = Type(module: .StdLib, name: "CVarArgType...")

  static let ReuseIdentifier = Type(module: "Rswift", name: "ReuseIdentifier", genericArgs: [TypeVar(description: "T", usedTypes: [])])
  static let ReuseIdentifierType = Type(module: "Rswift", name: "ReuseIdentifierType")
  static let StoryboardResourceType = Type(module: "Rswift", name: "StoryboardResourceType")
  static let StoryboardResourceWithInitialControllerType = Type(module: "Rswift", name: "StoryboardResourceWithInitialControllerType")
  static let StoryboardViewControllerResource = Type(module: "Rswift", name: "StoryboardViewControllerResource")
  static let NibResourceType = Type(module: "Rswift", name: "NibResourceType")
  static let FileResource = Type(module: "Rswift", name: "FileResource")
  static let FontResource = Type(module: "Rswift", name: "FontResource")
  static let ColorResource = Type(module: "Rswift", name: "ColorResource")
  static let ImageResource = Type(module: "Rswift", name: "ImageResource")
  static let StringResource = Type(module: "Rswift", name: "StringResource")
  static let Strings = Type(module: "Rswift", name: "Strings")
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
    return TypePrinter(type: self).swiftCode
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
    self.genericArgs = genericArgs.map(TypeVar.init)
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
