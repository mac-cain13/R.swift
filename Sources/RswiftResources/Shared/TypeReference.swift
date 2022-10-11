//
//  TypeReference.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 10-12-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

public struct TypeReference: Hashable {
    public let module: ModuleReference
    public let name: String
    public var genericArgs: [TypeReference]

    public init(module: ModuleReference, rawName: String) {
        self.module = module
        self.name = rawName
        self.genericArgs = []
    }

    public init(module: ModuleReference, name: String, genericArgs: [TypeReference]) {
        self.module = module
        self.name = name
        self.genericArgs = genericArgs
    }

    public var allModuleReferences: Set<ModuleReference> {
        Set(genericArgs.flatMap(\.allModuleReferences)).union([module])
    }
}
