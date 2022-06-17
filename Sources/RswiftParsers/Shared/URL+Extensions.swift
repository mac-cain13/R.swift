//
//  URL+Extensions.swift
//  RswiftResources
//
//  Created by Tom Lokhorst on 2021-04-25.
//

import Foundation

internal extension URL {
    var filenameWithoutExtension: String? {
        let name = self.deletingPathExtension().lastPathComponent
        return name == "" ? nil : name
    }
}
