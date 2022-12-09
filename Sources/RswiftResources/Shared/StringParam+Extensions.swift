//
//  StringParam.swift
//  R.swift
//
//  Created by Tom Lokhorst on 2016-04-18.
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

extension FormatSpecifier {
    public var typeReference: TypeReference {
        switch self {
        case .object:
            return TypeReference(module: .stdLib, rawName: "String")
        case .double:
            return TypeReference(module: .stdLib, rawName: "Double")
        case .int:
            return TypeReference(module: .stdLib, rawName: "Int")
        case .uInt:
            return TypeReference(module: .stdLib, rawName: "UInt")
        case .character:
            return TypeReference(module: .stdLib, rawName: "Character")
        case .cStringPointer:
            return TypeReference(module: .stdLib, rawName: "UnsafePointer<CChar>")
        case .voidPointer:
            return TypeReference(module: .stdLib, rawName: "UnsafePointer<Void>")
        case .topType:
            return TypeReference(module: .stdLib, rawName: "Any")
        }
    }
}
