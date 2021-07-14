//
//  File.swift
//  
//
//  Created by Mathijs on 13/07/2021.
//

import Foundation
import RswiftResources

public struct LocalizedStringsParser: ResourceParser {
    public let supportedExtensions: Set<String> = ["strings", "stringsdict"]

    public init() {}
    
    public func parse(url: URL) throws -> LocalizedStrings {
        try throwIfUnsupportedExtension(url)
        return LocalizedStrings(filename: url.lastPathComponent, locale: .current)
    }
}
