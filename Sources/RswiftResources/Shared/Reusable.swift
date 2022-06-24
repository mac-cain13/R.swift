//
//  ReusableContainer.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 10-12-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

public struct Reusable: Hashable {
    public let identifier: String
    public let type: TypeReference

    public init(identifier: String, type: TypeReference) {
        self.identifier = identifier
        self.type = type
    }
}
