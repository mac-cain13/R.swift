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
    public let locale: LocaleReference?
    public let onDemandResourceTags: [String]?
    public let filename: String

    public init(name: String, locale: LocaleReference?, onDemandResourceTags: [String]?, filename: String) {
        self.name = name
        self.locale = locale
        self.onDemandResourceTags = onDemandResourceTags
        self.filename = filename
    }
}
