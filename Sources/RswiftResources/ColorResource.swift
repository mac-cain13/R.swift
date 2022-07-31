//
//  ColorResource.swift
//  
//
//  Created by Tom Lokhorst on 2022-07-23.
//

import Foundation

public struct ColorResource {
    public let name: String
    public let path: [String]
    public let bundle: Bundle?

    public init(name: String, path: [String], bundle: Bundle?) {
        self.name = name
        self.path = path
        self.bundle = bundle
    }
}
