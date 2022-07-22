//
//  SegueIdentifier.swift
//  
//
//  Created by Tom Lokhorst on 2022-07-22.
//

import Foundation

public struct SegueIdentifier<Segue, Source, Destination> {
    public let identifier: String

    public init(identifier: String) {
        self.identifier = identifier
    }
}
