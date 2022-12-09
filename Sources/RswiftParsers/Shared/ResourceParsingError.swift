//
//  ResourceParsingError.swift
//  R.swift
//
//  Created by Tom Lokhorst on 2021-04-16.
//

import Foundation

public struct ResourceParsingError: Error {
    public var description: String

    public init(_ description: String) {
        self.description = description
    }
}
