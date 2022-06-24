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
    public let rawName: String

    public init(module: ModuleReference, rawName: String) {
        self.module = module
        self.rawName = rawName
    }
}
