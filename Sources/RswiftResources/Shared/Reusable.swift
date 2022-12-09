//
//  ReusableContainer.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 10-12-15.
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
