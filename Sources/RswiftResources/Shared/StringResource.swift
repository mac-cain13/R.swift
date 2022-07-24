//
//  File.swift
//  
//
//  Created by Tom Lokhorst on 2022-07-24.
//

import Foundation

public struct StringResource {
    public let key: String
    public let tableName: String
    public let locales: [String]
    public let developmentValue: String

    public init(key: String, tableName: String, locales: [String], developmentValue: String) {
        self.key = key
        self.tableName = tableName
        self.locales = locales
        self.developmentValue = developmentValue
    }

    public func callAsFunction() -> String {
        NSLocalizedString(key, tableName: tableName, bundle: Bundle.main, value: developmentValue, comment: "Comment")
    }
}

public struct StringResource1<Arg1: CVarArg> {
    public let key: String
    public let tableName: String
    public let locales: [String]
    public let developmentValue: String

    public init(key: String, tableName: String, locales: [String], developmentValue: String) {
        self.key = key
        self.tableName = tableName
        self.locales = locales
        self.developmentValue = developmentValue
    }

    public func callAsFunction(_ arg1: Arg1) -> String {
        let format = NSLocalizedString(key, tableName: tableName, bundle: Bundle.main, value: developmentValue, comment: "Comment")
        return String(format: format, arguments: [arg1])
    }
}

public struct StringResource2<Arg1: CVarArg, Arg2: CVarArg> {
    public let key: String
    public let tableName: String
    public let locales: [String]
    public let developmentValue: String

    public init(key: String, tableName: String, locales: [String], developmentValue: String) {
        self.key = key
        self.tableName = tableName
        self.locales = locales
        self.developmentValue = developmentValue
    }

    public func callAsFunction(_ arg1: Arg1, _ arg2: Arg2) -> String {
        let format = NSLocalizedString(key, tableName: tableName, bundle: Bundle.main, value: developmentValue, comment: "Comment")
        return String(format: format, arguments: [arg1, arg2])
    }
}
