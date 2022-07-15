//
//  FontResource.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 09-12-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

public struct FontResource {
    public let name: String
    public let filename: String

    public init(name: String, filename: String) {
        self.name = name
        self.filename = filename
    }
}
