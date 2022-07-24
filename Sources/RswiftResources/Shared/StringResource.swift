//
//  File.swift
//  
//
//  Created by Tom Lokhorst on 2022-07-24.
//

import Foundation

public struct StringResource {
    public let key: String
    public let tableName: String
    public let locales: [String]

    public init(key: String, tableName: String, locales: [String]) {
        self.key = key
        self.tableName = tableName
        self.locales = locales
    }
}
