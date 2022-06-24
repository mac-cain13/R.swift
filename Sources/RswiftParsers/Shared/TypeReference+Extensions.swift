//
//  TypeReference+Extensions.swift
//  
//
//  Created by Tom Lokhorst on 2022-06-24.
//

import Foundation
import RswiftResources

extension TypeReference {
    static let _Void = TypeReference(module: .stdLib, rawName: "Void")
    static let _Any = TypeReference(module: .stdLib, rawName: "Any")
    static let _AnyObject = TypeReference(module: .stdLib, rawName: "AnyObject")
    static let _String = TypeReference(module: .stdLib, rawName: "String")
    static let _Bool = TypeReference(module: .stdLib, rawName: "Bool")
    static let _Array = TypeReference(module: .stdLib, rawName: "Array")
    static let _Tuple = TypeReference(module: .stdLib, rawName: "_TUPLE_")
    static let _Int = TypeReference(module: .stdLib, rawName: "Int")
    static let _UInt = TypeReference(module: .stdLib, rawName: "UInt")
    static let _Double = TypeReference(module: .stdLib, rawName: "Double")
    static let _Character = TypeReference(module: .stdLib, rawName: "Character")
    static let _CStringPointer = TypeReference(module: .stdLib, rawName: "UnsafePointer<CChar>")
    static let _VoidPointer = TypeReference(module: .stdLib, rawName: "UnsafePointer<Void>")
    static let _URL = TypeReference(module: .foundation, rawName: "URL")
    static let _Bundle = TypeReference(module: .foundation, rawName: "Bundle")
    static let _Locale = TypeReference(module: .foundation, rawName: "Locale")
    static let _UINib = TypeReference(module: .uiKit, rawName: "UINib")
    static let _UIView = TypeReference(module: .uiKit, rawName: "UIView")
    static let _UIImage = TypeReference(module: .uiKit, rawName: "UIImage")
    static let _UIStoryboard = TypeReference(module: .uiKit, rawName: "UIStoryboard")
    static let _UITableViewCell = TypeReference(module: .uiKit, rawName: "UITableViewCell")
    static let _UICollectionViewCell = TypeReference(module: .uiKit, rawName: "UICollectionViewCell")
    static let _UICollectionReusableView = TypeReference(module: .uiKit, rawName: "UICollectionReusableView")
    static let _UIStoryboardSegue = TypeReference(module: .uiKit, rawName: "UIStoryboardSegue")
    static let _UITraitCollection = TypeReference(module: .uiKit, rawName: "UITraitCollection")
    static let _UIViewController = TypeReference(module: .uiKit, rawName: "UIViewController")
    static let _UIFont = TypeReference(module: .uiKit, rawName: "UIFont")
    static let _UIColor = TypeReference(module: .uiKit, rawName: "UIColor")
    static let _CGFloat = TypeReference(module: .stdLib, rawName: "CGFloat")
    static let _CVarArgType = TypeReference(module: .stdLib, rawName: "CVarArgType...")
}
