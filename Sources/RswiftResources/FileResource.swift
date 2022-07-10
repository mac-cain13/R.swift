//
//  FileResource.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 09-12-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

public struct FileResource {
    public let fullname: String
    public let locale: LocaleReference?
    public let name: String
    public let pathExtension: String

    public init(fullname: String, locale: LocaleReference?, name: String, pathExtension: String) {
        self.fullname = fullname
        self.locale = locale
        self.name = name
        self.pathExtension = pathExtension
    }
}
