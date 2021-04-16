//
//  ResourceParsingError.swift
//  RswiftCore
//
//  Created by Tom Lokhorst on 2021-04-16.
//

import Foundation

struct ResourceParsingError: LocalizedError {
    var errorDescription: String

    init(_ errorDescription: String) {
        self.errorDescription = errorDescription
    }
}
