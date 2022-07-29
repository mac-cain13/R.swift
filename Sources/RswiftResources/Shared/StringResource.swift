//
//  StringResource.swift
//  
//
//  Created by Tom Lokhorst on 2022-07-24.
//

import Foundation

public struct StringResource {
    public let key: StaticString
    public let tableName: String
    public let bundle: Bundle
    public let locale: Locale
    public let defaultValue: String
    public let comment: StaticString?

    public init(key: StaticString, tableName: String, bundle: Bundle, locale: Locale, defaultValue: String, comment: StaticString?) {
        self.key = key
        self.tableName = tableName
        self.bundle = bundle
        self.locale = locale
        self.defaultValue = defaultValue
        self.comment = comment
    }

    public func callAsFunction() -> String {
//        bundle.localizedString(forKey: key, value: defaultValue, table: table)
        NSLocalizedString(key.description, tableName: tableName, bundle: bundle, value: defaultValue, comment: "")
    }

    @available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
    public var localizedStringResource: LocalizedStringResource {
        LocalizedStringResource(key, defaultValue: String.LocalizationValue(stringLiteral: defaultValue), bundle: bundle == .main ? .main : .atURL(bundle.bundleURL), comment: comment)
    }
}

public struct StringResource1<Arg1: CVarArg> {
    public let key: StaticString
    public let tableName: String
    public let bundle: Bundle
    public let locale: Locale
    public let defaultValue: String
    public let comment: StaticString?

    public init(key: StaticString, tableName: String, bundle: Bundle, locale: Locale, defaultValue: String, comment: StaticString?) {
        self.key = key
        self.tableName = tableName
        self.bundle = bundle
        self.locale = locale
        self.defaultValue = defaultValue
        self.comment = comment
    }

    public func callAsFunction(_ arg1: Arg1) -> String {
        let format = NSLocalizedString(key.description, tableName: tableName, bundle: bundle, value: defaultValue, comment: "")
        return String(format: format, locale: locale, arguments: [arg1])
    }
}

public struct StringResource2<Arg1: CVarArg, Arg2: CVarArg> {
    public let key: StaticString
    public let tableName: String
    public let bundle: Bundle
    public let locale: Locale
    public let defaultValue: String
    public let comment: StaticString?

    public init(key: StaticString, tableName: String, bundle: Bundle, locale: Locale, defaultValue: String, comment: StaticString?) {
        self.key = key
        self.tableName = tableName
        self.bundle = bundle
        self.locale = locale
        self.defaultValue = defaultValue
        self.comment = comment
    }

    public func callAsFunction(_ arg1: Arg1, _ arg2: Arg2) -> String {
        let format = NSLocalizedString(key.description, tableName: tableName, bundle: bundle, value: defaultValue, comment: "")
        return String(format: format, locale: locale, arguments: [arg1, arg2])
    }
}

public struct StringResource3<Arg1: CVarArg, Arg2: CVarArg, Arg3: CVarArg> {
    public let key: StaticString
    public let tableName: String
    public let bundle: Bundle
    public let locale: Locale
    public let defaultValue: String
    public let comment: StaticString?

    public init(key: StaticString, tableName: String, bundle: Bundle, locale: Locale, defaultValue: String, comment: StaticString?) {
        self.key = key
        self.tableName = tableName
        self.bundle = bundle
        self.locale = locale
        self.defaultValue = defaultValue
        self.comment = comment
    }

    public func callAsFunction(_ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3) -> String {
        let format = NSLocalizedString(key.description, tableName: tableName, bundle: bundle, value: defaultValue, comment: "")
        return String(format: format, locale: locale, arguments: [arg1, arg2, arg3])
    }
}

public struct StringResource4<Arg1: CVarArg, Arg2: CVarArg, Arg3: CVarArg, Arg4: CVarArg> {
    public let key: StaticString
    public let tableName: String
    public let bundle: Bundle
    public let locale: Locale
    public let defaultValue: String
    public let comment: StaticString?

    public init(key: StaticString, tableName: String, bundle: Bundle, locale: Locale, defaultValue: String, comment: StaticString?) {
        self.key = key
        self.tableName = tableName
        self.bundle = bundle
        self.locale = locale
        self.defaultValue = defaultValue
        self.comment = comment
    }

    public func callAsFunction(_ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4) -> String {
        let format = NSLocalizedString(key.description, tableName: tableName, bundle: bundle, value: defaultValue, comment: "")
        return String(format: format, locale: locale, arguments: [arg1, arg2, arg3, arg4])
    }
}

public struct StringResource5<Arg1: CVarArg, Arg2: CVarArg, Arg3: CVarArg, Arg4: CVarArg, Arg5: CVarArg> {
    public let key: StaticString
    public let tableName: String
    public let bundle: Bundle
    public let locale: Locale
    public let defaultValue: String
    public let comment: StaticString?

    public init(key: StaticString, tableName: String, bundle: Bundle, locale: Locale, defaultValue: String, comment: StaticString?) {
        self.key = key
        self.tableName = tableName
        self.bundle = bundle
        self.locale = locale
        self.defaultValue = defaultValue
        self.comment = comment
    }

    public func callAsFunction(_ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4, _ arg5: Arg5) -> String {
        let format = NSLocalizedString(key.description, tableName: tableName, bundle: bundle, value: defaultValue, comment: "")
        return String(format: format, locale: locale, arguments: [arg1, arg2, arg3, arg4, arg5])
    }
}

public struct StringResource6<Arg1: CVarArg, Arg2: CVarArg, Arg3: CVarArg, Arg4: CVarArg, Arg5: CVarArg, Arg6: CVarArg> {
    public let key: StaticString
    public let tableName: String
    public let bundle: Bundle
    public let locale: Locale
    public let defaultValue: String
    public let comment: StaticString?

    public init(key: StaticString, tableName: String, bundle: Bundle, locale: Locale, defaultValue: String, comment: StaticString?) {
        self.key = key
        self.tableName = tableName
        self.bundle = bundle
        self.locale = locale
        self.defaultValue = defaultValue
        self.comment = comment
    }

    public func callAsFunction(_ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4, _ arg5: Arg5, _ arg6: Arg6) -> String {
        let format = NSLocalizedString(key.description, tableName: tableName, bundle: bundle, value: defaultValue, comment: "")
        return String(format: format, locale: locale, arguments: [arg1, arg2, arg3, arg4, arg5, arg6])
    }
}

public struct StringResource7<Arg1: CVarArg, Arg2: CVarArg, Arg3: CVarArg, Arg4: CVarArg, Arg5: CVarArg, Arg6: CVarArg, Arg7: CVarArg> {
    public let key: StaticString
    public let tableName: String
    public let bundle: Bundle
    public let locale: Locale
    public let defaultValue: String
    public let comment: StaticString?

    public init(key: StaticString, tableName: String, bundle: Bundle, locale: Locale, defaultValue: String, comment: StaticString?) {
        self.key = key
        self.tableName = tableName
        self.bundle = bundle
        self.locale = locale
        self.defaultValue = defaultValue
        self.comment = comment
    }

    public func callAsFunction(_ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4, _ arg5: Arg5, _ arg6: Arg6, _ arg7: Arg7) -> String {
        let format = NSLocalizedString(key.description, tableName: tableName, bundle: bundle, value: defaultValue, comment: "")
        return String(format: format, locale: locale, arguments: [arg1, arg2, arg3, arg4, arg5, arg6, arg7])
    }
}

public struct StringResource8<Arg1: CVarArg, Arg2: CVarArg, Arg3: CVarArg, Arg4: CVarArg, Arg5: CVarArg, Arg6: CVarArg, Arg7: CVarArg, Arg8: CVarArg> {
    public let key: StaticString
    public let tableName: String
    public let bundle: Bundle
    public let locale: Locale
    public let defaultValue: String
    public let comment: StaticString?

    public init(key: StaticString, tableName: String, bundle: Bundle, locale: Locale, defaultValue: String, comment: StaticString?) {
        self.key = key
        self.tableName = tableName
        self.bundle = bundle
        self.locale = locale
        self.defaultValue = defaultValue
        self.comment = comment
    }

    public func callAsFunction(_ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4, _ arg5: Arg5, _ arg6: Arg6, _ arg7: Arg7, _ arg8: Arg8) -> String {
        let format = NSLocalizedString(key.description, tableName: tableName, bundle: bundle, value: defaultValue, comment: "")
        return String(format: format, locale: locale, arguments: [arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8])
    }
}

public struct StringResource9<Arg1: CVarArg, Arg2: CVarArg, Arg3: CVarArg, Arg4: CVarArg, Arg5: CVarArg, Arg6: CVarArg, Arg7: CVarArg, Arg8: CVarArg, Arg9: CVarArg> {
    public let key: StaticString
    public let tableName: String
    public let bundle: Bundle
    public let locale: Locale
    public let defaultValue: String
    public let comment: StaticString?

    public init(key: StaticString, tableName: String, bundle: Bundle, locale: Locale, defaultValue: String, comment: StaticString?) {
        self.key = key
        self.tableName = tableName
        self.bundle = bundle
        self.locale = locale
        self.defaultValue = defaultValue
        self.comment = comment
    }

    public func callAsFunction(_ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4, _ arg5: Arg5, _ arg6: Arg6, _ arg7: Arg7, _ arg8: Arg8, _ arg9: Arg9) -> String {
        let format = NSLocalizedString(key.description, tableName: tableName, bundle: bundle, value: defaultValue, comment: "")
        return String(format: format, locale: locale, arguments: [arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9])
    }
}
