//
//  StringResource.swift
//  
//
//  Created by Tom Lokhorst on 2022-07-24.
//

import Foundation

public struct StringResource: Sendable {
    public enum Source: Sendable {
        case hosting(Bundle)
        case selected(Bundle, Locale)
        case none

        public var bundle: Bundle? {
            switch self {
            case .hosting(let bundle): return bundle
            case .selected(let bundle, _): return bundle
            case .none: return nil
            }
        }
    }

    public let key: StaticString
    public let tableName: String
    public let source: Source
    public let developmentValue: String?
    public let comment: StaticString?

    public init(key: StaticString, tableName: String, source: Source, developmentValue: String?, comment: StaticString?) {
        self.key = key
        self.tableName = tableName
        self.source = source
        self.developmentValue = developmentValue
        self.comment = comment
    }
}

public struct StringResource1<Arg1: CVarArg>: Sendable {
    public let key: StaticString
    public let tableName: String
    public let source: StringResource.Source
    public let developmentValue: String?
    public let comment: StaticString?

    public init(key: StaticString, tableName: String, source: StringResource.Source, developmentValue: String?, comment: StaticString?) {
        self.key = key
        self.tableName = tableName
        self.source = source
        self.developmentValue = developmentValue
        self.comment = comment
    }
}

public struct StringResource2<Arg1: CVarArg, Arg2: CVarArg>: Sendable {
    public let key: StaticString
    public let tableName: String
    public let source: StringResource.Source
    public let developmentValue: String?
    public let comment: StaticString?

    public init(key: StaticString, tableName: String, source: StringResource.Source, developmentValue: String?, comment: StaticString?) {
        self.key = key
        self.tableName = tableName
        self.source = source
        self.developmentValue = developmentValue
        self.comment = comment
    }
}

public struct StringResource3<Arg1: CVarArg, Arg2: CVarArg, Arg3: CVarArg>: Sendable {
    public let key: StaticString
    public let tableName: String
    public let source: StringResource.Source
    public let developmentValue: String?
    public let comment: StaticString?

    public init(key: StaticString, tableName: String, source: StringResource.Source, developmentValue: String?, comment: StaticString?) {
        self.key = key
        self.tableName = tableName
        self.source = source
        self.developmentValue = developmentValue
        self.comment = comment
    }
}

public struct StringResource4<Arg1: CVarArg, Arg2: CVarArg, Arg3: CVarArg, Arg4: CVarArg>: Sendable {
    public let key: StaticString
    public let tableName: String
    public let source: StringResource.Source
    public let developmentValue: String?
    public let comment: StaticString?

    public init(key: StaticString, tableName: String, source: StringResource.Source, developmentValue: String?, comment: StaticString?) {
        self.key = key
        self.tableName = tableName
        self.source = source
        self.developmentValue = developmentValue
        self.comment = comment
    }
}

public struct StringResource5<Arg1: CVarArg, Arg2: CVarArg, Arg3: CVarArg, Arg4: CVarArg, Arg5: CVarArg>: Sendable {
    public let key: StaticString
    public let tableName: String
    public let source: StringResource.Source
    public let developmentValue: String?
    public let comment: StaticString?

    public init(key: StaticString, tableName: String, source: StringResource.Source, developmentValue: String?, comment: StaticString?) {
        self.key = key
        self.tableName = tableName
        self.source = source
        self.developmentValue = developmentValue
        self.comment = comment
    }
}

public struct StringResource6<Arg1: CVarArg, Arg2: CVarArg, Arg3: CVarArg, Arg4: CVarArg, Arg5: CVarArg, Arg6: CVarArg>: Sendable {
    public let key: StaticString
    public let tableName: String
    public let source: StringResource.Source
    public let developmentValue: String?
    public let comment: StaticString?

    public init(key: StaticString, tableName: String, source: StringResource.Source, developmentValue: String?, comment: StaticString?) {
        self.key = key
        self.tableName = tableName
        self.source = source
        self.developmentValue = developmentValue
        self.comment = comment
    }
}

public struct StringResource7<Arg1: CVarArg, Arg2: CVarArg, Arg3: CVarArg, Arg4: CVarArg, Arg5: CVarArg, Arg6: CVarArg, Arg7: CVarArg>: Sendable {
    public let key: StaticString
    public let tableName: String
    public let source: StringResource.Source
    public let developmentValue: String?
    public let comment: StaticString?

    public init(key: StaticString, tableName: String, source: StringResource.Source, developmentValue: String?, comment: StaticString?) {
        self.key = key
        self.tableName = tableName
        self.source = source
        self.developmentValue = developmentValue
        self.comment = comment
    }
}

public struct StringResource8<Arg1: CVarArg, Arg2: CVarArg, Arg3: CVarArg, Arg4: CVarArg, Arg5: CVarArg, Arg6: CVarArg, Arg7: CVarArg, Arg8: CVarArg>: Sendable {
    public let key: StaticString
    public let tableName: String
    public let source: StringResource.Source
    public let developmentValue: String?
    public let comment: StaticString?

    public init(key: StaticString, tableName: String, source: StringResource.Source, developmentValue: String?, comment: StaticString?) {
        self.key = key
        self.tableName = tableName
        self.source = source
        self.developmentValue = developmentValue
        self.comment = comment
    }
}

public struct StringResource9<Arg1: CVarArg, Arg2: CVarArg, Arg3: CVarArg, Arg4: CVarArg, Arg5: CVarArg, Arg6: CVarArg, Arg7: CVarArg, Arg8: CVarArg, Arg9: CVarArg>: Sendable {
    public let key: StaticString
    public let tableName: String
    public let source: StringResource.Source
    public let developmentValue: String?
    public let comment: StaticString?

    public init(key: StaticString, tableName: String, source: StringResource.Source, developmentValue: String?, comment: StaticString?) {
        self.key = key
        self.tableName = tableName
        self.source = source
        self.developmentValue = developmentValue
        self.comment = comment
    }
}
