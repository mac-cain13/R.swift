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
    public let filename: String
    public let name: String

    public init(filename: String, name: String) {
        self.filename = filename
        self.name = name
    }
}
