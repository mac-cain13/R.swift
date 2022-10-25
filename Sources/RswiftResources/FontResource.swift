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
    public let bundle: Bundle
    public let filename: String

    public init(name: String, bundle: Bundle, filename: String) {
        self.name = name
        self.bundle = bundle
        self.filename = filename
    }
}
