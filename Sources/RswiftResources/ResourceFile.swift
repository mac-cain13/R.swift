//
//  ResourceFile.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 09-12-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

public struct ResourceFile {
    public let fullname: String
    public let name: String
    public let pathExtension: String

    public init(fullname: String, name: String, pathExtension: String) {
        self.fullname = fullname
        self.name = name
        self.pathExtension = pathExtension
    }
}
