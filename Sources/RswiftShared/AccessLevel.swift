//
//  AccessLevel.swift
//  R.swift
//
//  Created by Joe Newton on 2024-07-11.
//

public enum AccessLevel: String, Decodable {
    case publicLevel = "public"
    case internalLevel = "internal"
    case filePrivate = "fileprivate"
    case privateLevel = "private"
}
