//
//  FontResource.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 09-12-15.
//

import Foundation

public struct FontResource: Sendable {
    public let name: String
    public let bundle: Bundle
    public let filename: String

    public init(name: String, bundle: Bundle, filename: String) {
        self.name = name
        self.bundle = bundle
        self.filename = filename
    }
}
