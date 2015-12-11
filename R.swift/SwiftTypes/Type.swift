//
//  Type.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 10-12-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import Foundation

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
    return fullyQualifiedName.hashValue
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
