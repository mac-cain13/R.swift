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
    public let bundle: Bundle?
    public let onDemandResourceTags: [String]?

    public init(name: String, path: [String], bundle: Bundle?, onDemandResourceTags: [String]?) {
        self.name = name
        self.path = path
        self.bundle = bundle
        self.onDemandResourceTags = onDemandResourceTags
    }
}
