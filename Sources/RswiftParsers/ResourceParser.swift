//
//  ResourceParser.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 10-12-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

public protocol ResourceParser {
    associatedtype ResourceType

    var supportedExtensions: Set<String> { get }

    func parse(url: URL) throws -> ResourceType
}

extension ResourceParser {
    func throwIfUnsupportedExtension(_ url: URL) throws {
        let pathExtension = url.pathExtension

        if !supportedExtensions.contains(pathExtension.lowercased()) {
            throw ResourceUnsupportedExtensionError(url: url, typeName: "\(Self.self)", supportedExtensions: supportedExtensions)
        }
    }
}
