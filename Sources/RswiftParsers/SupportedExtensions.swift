//
//  SupportedExtensions.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 10-12-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

protocol SupportedExtensions {
    static var supportedExtensions: Set<String> { get }
}

extension SupportedExtensions {
    static func throwIfUnsupportedExtension(_ url: URL) throws {
        let pathExtension = url.pathExtension

        if !supportedExtensions.contains(pathExtension.lowercased()) {
            throw ResourceUnsupportedExtensionError(url: url, typeName: "\(Self.self)", supportedExtensions: supportedExtensions)
        }
    }
}

public struct ResourceUnsupportedExtensionError: LocalizedError {
    public let url: URL
    public let typeName: String
    public let supportedExtensions: Set<String>

    public init(url: URL, typeName: String, supportedExtensions: Set<String>) {
        self.url = url
        self.typeName = typeName
        self.supportedExtensions = supportedExtensions
    }

    public var errorDescription: String {
        "URL '\(url)' has not supported extension, for type '\(typeName)', supported extensions \(supportedExtensions.joined(separator: ", "))"
    }
}
