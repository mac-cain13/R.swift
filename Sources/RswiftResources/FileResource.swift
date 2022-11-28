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

//    public let filename: String
    public let name: String
    public let pathExtension: String
    public let bundle: Bundle
    public let locale: LocaleReference?
//
//    public init(filename: String, bundle: Bundle?, locale: LocaleReference?) {
//        self.filename = filename
//        self.bundle = bundle
//        self.locale = locale
//    }

    public var filename: String {
        name.isEmpty || pathExtension.isEmpty
            ? "\(name)\(pathExtension)"
            : "\(name).\(pathExtension)"
    }

    public init(name: String, pathExtension: String, bundle: Bundle, locale: LocaleReference?) {
        self.name = name
        self.pathExtension = pathExtension
        self.bundle = bundle
        self.locale = locale
    }
}
