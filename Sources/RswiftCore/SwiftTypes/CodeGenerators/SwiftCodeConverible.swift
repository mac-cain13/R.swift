//
//  SwiftCodeConverible.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 14-01-16.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

protocol SwiftCodeConverible {
  var swiftCode: String { get }
}

protocol ObjcCodeConvertible {
  func objcCode(prefix: String) -> String
}
