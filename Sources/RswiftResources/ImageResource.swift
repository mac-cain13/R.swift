//
//  ImageResource.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 09-12-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

public struct ImageResource {
    public let name: String
    public let path: [String]
    public let bundle: Bundle
    public let locale: LocaleReference?
    public let onDemandResourceTags: [String]?

    public init(name: String, path: [String], bundle: Bundle, locale: LocaleReference?, onDemandResourceTags: [String]?) {
        self.name = name
        self.path = path
        self.bundle = bundle
        self.locale = locale
        self.onDemandResourceTags = onDemandResourceTags
    }
}
