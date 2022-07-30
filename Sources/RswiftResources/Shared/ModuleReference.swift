//
//  ModuleReference.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 11-12-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

public enum ModuleReference: Hashable {
    case host
    case stdLib
    case custom(name: String)

    var isCustom: Bool {
        switch self {
        case .custom:
            return true
        default:
            return false
        }
    }

    public init(name: String?, fallback: ModuleReference = .host) {
        let cleaned = name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        self = cleaned.isEmpty ? fallback : .custom(name: cleaned)
    }
}

extension ModuleReference {
    public static var foundation: ModuleReference { .custom(name: "Foundation") }
    public static var uiKit: ModuleReference { .custom(name: "UIKit") }
    public static var rswiftResources: ModuleReference { .custom(name: "RswiftResources") }
}
