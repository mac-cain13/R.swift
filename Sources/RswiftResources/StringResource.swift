//
//  StringResource.swift
//  
//
//  Created by Tom Lokhorst on 2022-07-24.
//

import Foundation

public struct StringResource {
    public enum LoadingStrategy {
        /// Load strings directly using `NSLocalizedString` without changing the locale used for formatting
        public static let `default`: LoadingStrategy = .default(locale: nil)

        /// Load strings directly using `NSLocalizedString` using a custom `Locale` to format arguments
        case `default`(locale: Locale?)

        /// Load strings in the preferred languages only
        case preferredLanguages([String], locale: Locale? = nil)

        /// Load strings using a custom implementation
        case custom((_ key: StaticString, _ tableName: String, _ bundle: Bundle, _ developmentValue: String?, _ overrideLocale: Locale?, _ arguments: [CVarArg]) -> String)
    }

    public let key: StaticString
    public let tableName: String
    public let bundle: Bundle
    public let loadingStrategy: LoadingStrategy
    public let developmentValue: String?
    public let comment: StaticString?

    public init(key: StaticString, tableName: String, bundle: Bundle, loadingStrategy: LoadingStrategy, developmentValue: String?, comment: StaticString?) {
        self.key = key
        self.tableName = tableName
        self.bundle = bundle
        self.loadingStrategy = loadingStrategy
        self.developmentValue = developmentValue
        self.comment = comment
    }
}

public struct StringResource1<Arg1: CVarArg> {
    public let key: StaticString
    public let tableName: String
    public let bundle: Bundle
    public let loadingStrategy: StringResource.LoadingStrategy
    public let developmentValue: String?
    public let comment: StaticString?

    public init(key: StaticString, tableName: String, bundle: Bundle, loadingStrategy: StringResource.LoadingStrategy, developmentValue: String?, comment: StaticString?) {
        self.key = key
        self.tableName = tableName
        self.bundle = bundle
        self.loadingStrategy = loadingStrategy
        self.developmentValue = developmentValue
        self.comment = comment
    }
}

public struct StringResource2<Arg1: CVarArg, Arg2: CVarArg> {
    public let key: StaticString
    public let tableName: String
    public let bundle: Bundle
    public let loadingStrategy: StringResource.LoadingStrategy
    public let developmentValue: String?
    public let comment: StaticString?

    public init(key: StaticString, tableName: String, bundle: Bundle, loadingStrategy: StringResource.LoadingStrategy, developmentValue: String?, comment: StaticString?) {
        self.key = key
        self.tableName = tableName
        self.bundle = bundle
        self.loadingStrategy = loadingStrategy
        self.developmentValue = developmentValue
        self.comment = comment
    }
}

public struct StringResource3<Arg1: CVarArg, Arg2: CVarArg, Arg3: CVarArg> {
    public let key: StaticString
    public let tableName: String
    public let bundle: Bundle
    public let loadingStrategy: StringResource.LoadingStrategy
    public let developmentValue: String?
    public let comment: StaticString?

    public init(key: StaticString, tableName: String, bundle: Bundle, loadingStrategy: StringResource.LoadingStrategy, developmentValue: String?, comment: StaticString?) {
        self.key = key
        self.tableName = tableName
        self.bundle = bundle
        self.loadingStrategy = loadingStrategy
        self.developmentValue = developmentValue
        self.comment = comment
    }
}

public struct StringResource4<Arg1: CVarArg, Arg2: CVarArg, Arg3: CVarArg, Arg4: CVarArg> {
    public let key: StaticString
    public let tableName: String
    public let bundle: Bundle
    public let loadingStrategy: StringResource.LoadingStrategy
    public let developmentValue: String?
    public let comment: StaticString?

    public init(key: StaticString, tableName: String, bundle: Bundle, loadingStrategy: StringResource.LoadingStrategy, developmentValue: String?, comment: StaticString?) {
        self.key = key
        self.tableName = tableName
        self.bundle = bundle
        self.loadingStrategy = loadingStrategy
        self.developmentValue = developmentValue
        self.comment = comment
    }
}

public struct StringResource5<Arg1: CVarArg, Arg2: CVarArg, Arg3: CVarArg, Arg4: CVarArg, Arg5: CVarArg> {
    public let key: StaticString
    public let tableName: String
    public let bundle: Bundle
    public let loadingStrategy: StringResource.LoadingStrategy
    public let developmentValue: String?
    public let comment: StaticString?

    public init(key: StaticString, tableName: String, bundle: Bundle, loadingStrategy: StringResource.LoadingStrategy, developmentValue: String?, comment: StaticString?) {
        self.key = key
        self.tableName = tableName
        self.bundle = bundle
        self.loadingStrategy = loadingStrategy
        self.developmentValue = developmentValue
        self.comment = comment
    }
}

public struct StringResource6<Arg1: CVarArg, Arg2: CVarArg, Arg3: CVarArg, Arg4: CVarArg, Arg5: CVarArg, Arg6: CVarArg> {
    public let key: StaticString
    public let tableName: String
    public let bundle: Bundle
    public let loadingStrategy: StringResource.LoadingStrategy
    public let developmentValue: String?
    public let comment: StaticString?

    public init(key: StaticString, tableName: String, bundle: Bundle, loadingStrategy: StringResource.LoadingStrategy, developmentValue: String?, comment: StaticString?) {
        self.key = key
        self.tableName = tableName
        self.bundle = bundle
        self.loadingStrategy = loadingStrategy
        self.developmentValue = developmentValue
        self.comment = comment
    }
}

public struct StringResource7<Arg1: CVarArg, Arg2: CVarArg, Arg3: CVarArg, Arg4: CVarArg, Arg5: CVarArg, Arg6: CVarArg, Arg7: CVarArg> {
    public let key: StaticString
    public let tableName: String
    public let bundle: Bundle
    public let loadingStrategy: StringResource.LoadingStrategy
    public let developmentValue: String?
    public let comment: StaticString?

    public init(key: StaticString, tableName: String, bundle: Bundle, loadingStrategy: StringResource.LoadingStrategy, developmentValue: String?, comment: StaticString?) {
        self.key = key
        self.tableName = tableName
        self.bundle = bundle
        self.loadingStrategy = loadingStrategy
        self.developmentValue = developmentValue
        self.comment = comment
    }
}

public struct StringResource8<Arg1: CVarArg, Arg2: CVarArg, Arg3: CVarArg, Arg4: CVarArg, Arg5: CVarArg, Arg6: CVarArg, Arg7: CVarArg, Arg8: CVarArg> {
    public let key: StaticString
    public let tableName: String
    public let bundle: Bundle
    public let loadingStrategy: StringResource.LoadingStrategy
    public let developmentValue: String?
    public let comment: StaticString?

    public init(key: StaticString, tableName: String, bundle: Bundle, loadingStrategy: StringResource.LoadingStrategy, developmentValue: String?, comment: StaticString?) {
        self.key = key
        self.tableName = tableName
        self.bundle = bundle
        self.loadingStrategy = loadingStrategy
        self.developmentValue = developmentValue
        self.comment = comment
    }
}

public struct StringResource9<Arg1: CVarArg, Arg2: CVarArg, Arg3: CVarArg, Arg4: CVarArg, Arg5: CVarArg, Arg6: CVarArg, Arg7: CVarArg, Arg8: CVarArg, Arg9: CVarArg> {
    public let key: StaticString
    public let tableName: String
    public let bundle: Bundle
    public let loadingStrategy: StringResource.LoadingStrategy
    public let developmentValue: String?
    public let comment: StaticString?

    public init(key: StaticString, tableName: String, bundle: Bundle, loadingStrategy: StringResource.LoadingStrategy, developmentValue: String?, comment: StaticString?) {
        self.key = key
        self.tableName = tableName
        self.bundle = bundle
        self.loadingStrategy = loadingStrategy
        self.developmentValue = developmentValue
        self.comment = comment
    }
}
