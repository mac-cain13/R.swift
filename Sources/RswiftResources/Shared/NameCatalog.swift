//
//  NameCatalog.swift
//  R.swift
//
//  Created by Tom Lokhorst on 2020-05-08.
//

import Foundation

public struct NameCatalog: Hashable, Comparable {
    public let name: String
    public let catalog: String?

    public var isSystemCatalog: Bool {
            catalog == "System" // for colors
         || catalog == "system" // for images
    }

    public init(name: String, catalog: String?) {
        self.name = name
        self.catalog = catalog
    }

    static public func < (lhs: NameCatalog, rhs: NameCatalog) -> Bool {
        lhs.name < rhs.name
    }
}
