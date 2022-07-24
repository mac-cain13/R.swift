//
//  StringParam.swift
//  R.swift
//
//  Created by Tom Lokhorst on 2016-04-18.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//
//  Parts of the content of this file are loosly based on StringsFileParser.swift from SwiftGen/GenumKit.
//  We don't feel this is a "substantial portion of the Software" so are not including their MIT license,
//  eventhough we would like to give credit where credit is due by referring to SwiftGen thanking Olivier
//  Halligon for creating SwiftGen and GenumKit.
//
//  See: https://github.com/AliSoftware/SwiftGen/blob/master/GenumKit/Parsers/StringsFileParser.swift
//

import Foundation

extension StringParam: Unifiable {
    public func unify(_ other: StringParam) -> StringParam? {
        if let name = name, let otherName = other.name , name != otherName {
            return nil
        }

        if let spec = spec.unify(other.spec) {
            return StringParam(name: name ?? other.name, spec: spec)
        }

        return nil
    }
}

extension FormatPart: Unifiable {
    public func unify(_ other: FormatPart) -> FormatPart? {
        switch (self, other) {
        case let (.spec(l), .spec(r)):
            if let spec = l.unify(r) {
                return .spec(spec)
            }
            else {
                return nil
            }

        case let (.reference(l), .reference(r)) where l == r:
            return .reference(l)

        default:
            return nil
        }
    }
}

extension FormatSpecifier: Unifiable {

    public func unify(_ other: FormatSpecifier) -> FormatSpecifier? {
        if self == .topType {
            return other
        }

        if other == .topType {
            return self
        }

        if self == other {
            return self
        }

        return nil
    }
}
