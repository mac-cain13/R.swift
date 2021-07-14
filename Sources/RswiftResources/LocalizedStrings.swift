//
//  LocalizedStrings.swift
//  R.swift
//
//  Created by Tom Lokhorst on 2016-04-24.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

public struct LocalizedStrings {
    public let filename: String
    public let locale: Locale
    public let identifiers: [String] = ["someNiceString", "someOtherNiceString"]

    public init(filename: String, locale: Locale) {
        self.filename = filename
        self.locale = locale
    }
}

