//
//  ResourceParsingError.swift
//  RswiftCore
//
//  Created by Tom Lokhorst on 2021-04-16.
//

import Foundation

public struct ResourceParsingError: LocalizedError {
    public var errorDescription: String

    public init(_ errorDescription: String) {
        self.errorDescription = errorDescription
    }
}
