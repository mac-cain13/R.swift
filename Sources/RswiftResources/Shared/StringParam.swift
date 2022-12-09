//
//  StringParam.swift
//  R.swift
//
//  Created by Tom Lokhorst on 2016-04-18.
//

import Foundation

public struct StringParam: Equatable {
    public let name: String?
    public let spec: FormatSpecifier

    public init(name: String?, spec: FormatSpecifier) {
        self.name = name
        self.spec = spec
    }
}

public enum FormatPart {
    case spec(FormatSpecifier)
    case reference(String)

    public var formatSpecifier: FormatSpecifier? {
        switch self {
        case .spec(let formatSpecifier):
            return formatSpecifier

        case .reference:
            return nil
        }
    }
}

// https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/Strings/Articles/formatSpecifiers.html#//apple_ref/doc/uid/TP40004265-SW1
public enum FormatSpecifier {
    case object
    case double
    case int
    case uInt
    case character
    case cStringPointer
    case voidPointer
    case topType
}
