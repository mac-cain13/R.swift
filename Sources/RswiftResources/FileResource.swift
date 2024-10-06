//
//  FileResource.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 09-12-15.
//

import Foundation

public struct FileResource: Sendable {
    public let name: String
    public let pathExtension: String
    public let bundle: Bundle
    public let locale: LocaleReference?

    public init(name: String, pathExtension: String, bundle: Bundle, locale: LocaleReference?) {
        self.name = name
        self.pathExtension = pathExtension
        self.bundle = bundle
        self.locale = locale
    }

    public var filename: String {
        name.isEmpty || pathExtension.isEmpty
            ? "\(name)\(pathExtension)"
            : "\(name).\(pathExtension)"
    }
}
