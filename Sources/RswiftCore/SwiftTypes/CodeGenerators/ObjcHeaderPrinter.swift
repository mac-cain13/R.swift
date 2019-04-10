//
//  ObjcHeaderPrinter.swift
//  RswiftCore
//
//  Created by Brian Clymer on 4/10/19.
//

import Foundation

/// Prints a static header for the beginning of the Objective-C portion of the file.
struct ObjcHeaderPrinter: ObjcCodeConvertible {
    func objcCode(prefix: String?) -> String {
        return [
            "//",
            "// Compatibility layer so resources can be used in ObjC",
            "//",
            "",
            "@objcMembers",
            "@available(swift, obsoleted: 1.0, message: \"Use R. instead\")",
            "public class RObjc: Foundation.NSObject {",
            ].joined(separator: "\n")
    }
}

/// Prints a static header for the beginning of the Objective-C portion of the file.
struct ObjcFooterPrinter: ObjcCodeConvertible {
    func objcCode(prefix: String?) -> String {
        return "}"
    }
}
