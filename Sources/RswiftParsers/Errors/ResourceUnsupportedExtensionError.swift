//
//  File.swift
//  
//
//  Created by Mathijs on 14/07/2021.
//

import Foundation

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
