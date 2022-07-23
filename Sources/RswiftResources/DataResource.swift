//
//  DataResource.swift
//  
//
//  Created by Tom Lokhorst on 2022-07-23.
//

import Foundation

public struct DataResource {
    public let name: String
    public let path: [String]
    public let onDemandResourceTags: [String]?

    public init(name: String, path: [String], onDemandResourceTags: [String]?) {
        self.name = name
        self.path = path
        self.onDemandResourceTags = onDemandResourceTags
    }
}
