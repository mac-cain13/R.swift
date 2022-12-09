//
//  Validatable.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 17-12-15.
//  From: https://github.com/mac-cain13/R.swift
//

import Foundation

/// Error thrown during validation
public struct ValidationError: Error, CustomStringConvertible {
    /// Human readable description
    public let description: String

    public init(_ description: String) {
        self.description = description
    }
}
