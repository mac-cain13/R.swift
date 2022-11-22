//
//  StringResource+Integrations.swift
//  
//
//  Created by Tom Lokhorst on 2022-07-30.
//

import Foundation
import SwiftUI

extension String {
    public init(resource: StringResource) {
        self = resource.callAsFunction()
    }
}


@available(macOS 10, iOS 13, tvOS 13, watchOS 6, *)
extension Text {
    public init(_ resource: StringResource) {
        self.init(resource.callAsFunction())
    }

    public init<Arg1: CVarArg>(_ resource: StringResource1<Arg1>, _ arg1: Arg1) {
        self.init(resource.callAsFunction(arg1))
    }

    public init<Arg1: CVarArg, Arg2: CVarArg>(_ resource: StringResource2<Arg1, Arg2>, _ arg1: Arg1, _ arg2: Arg2) {
        self.init(resource.callAsFunction(arg1, arg2))
    }

    public init<Arg1: CVarArg, Arg2: CVarArg, Arg3: CVarArg>(_ resource: StringResource3<Arg1, Arg2, Arg3>, _ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3) {
        self.init(resource.callAsFunction(arg1, arg2, arg3))
    }

    public init<Arg1: CVarArg, Arg2: CVarArg, Arg3: CVarArg, Arg4: CVarArg>(_ resource: StringResource4<Arg1, Arg2, Arg3, Arg4>, _ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4) {
        self.init(resource.callAsFunction(arg1, arg2, arg3, arg4))
    }

    public init<Arg1: CVarArg, Arg2: CVarArg, Arg3: CVarArg, Arg4: CVarArg, Arg5: CVarArg>(_ resource: StringResource5<Arg1, Arg2, Arg3, Arg4, Arg5>, _ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4, _ arg5: Arg5) {
        self.init(resource.callAsFunction(arg1, arg2, arg3, arg4, arg5))
    }

    public init<Arg1: CVarArg, Arg2: CVarArg, Arg3: CVarArg, Arg4: CVarArg, Arg5: CVarArg, Arg6: CVarArg>(_ resource: StringResource6<Arg1, Arg2, Arg3, Arg4, Arg5, Arg6>, _ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4, _ arg5: Arg5, _ arg6: Arg6) {
        self.init(resource.callAsFunction(arg1, arg2, arg3, arg4, arg5, arg6))
    }

    public init<Arg1: CVarArg, Arg2: CVarArg, Arg3: CVarArg, Arg4: CVarArg, Arg5: CVarArg, Arg6: CVarArg, Arg7: CVarArg>(_ resource: StringResource7<Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7>, _ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4, _ arg5: Arg5, _ arg6: Arg6, _ arg7: Arg7) {
        self.init(resource.callAsFunction(arg1, arg2, arg3, arg4, arg5, arg6, arg7))
    }

    public init<Arg1: CVarArg, Arg2: CVarArg, Arg3: CVarArg, Arg4: CVarArg, Arg5: CVarArg, Arg6: CVarArg, Arg7: CVarArg, Arg8: CVarArg>(_ resource: StringResource8<Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8>, _ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4, _ arg5: Arg5, _ arg6: Arg6, _ arg7: Arg7, _ arg8: Arg8) {
        self.init(resource.callAsFunction(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8))
    }

    public init<Arg1: CVarArg, Arg2: CVarArg, Arg3: CVarArg, Arg4: CVarArg, Arg5: CVarArg, Arg6: CVarArg, Arg7: CVarArg, Arg8: CVarArg, Arg9: CVarArg>(_ resource: StringResource9<Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Arg9>, _ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4, _ arg5: Arg5, _ arg6: Arg6, _ arg7: Arg7, _ arg8: Arg8, _ arg9: Arg9) {
        self.init(resource.callAsFunction(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9))
    }
}

extension StringResource {
    public func callAsFunction() -> String {
//        bundle.localizedString(forKey: key, value: defaultValue, table: table)
        NSLocalizedString(key.description, tableName: tableName, bundle: bundle, value: defaultValue ?? "", comment: "")
    }

    @available(*, deprecated, message: "Use R.string(preferredLanguages:).*.* instead")
    public func callAsFunction(preferredLanguages: [String]) -> String {
        guard let (bundle, _) = bundle.firstBundleAndLocale(tableName: tableName, preferredLanguages: preferredLanguages) else {
            return key.description
        }
        return NSLocalizedString(key.description, tableName: tableName, bundle: bundle, value: "", comment: "")
    }

//    @available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
//    public var localizedStringResource: LocalizedStringResource {
//        LocalizedStringResource(key, defaultValue: String.LocalizationValue(stringLiteral: defaultValue), bundle: bundle == .main ? .main : .atURL(bundle.bundleURL), comment: comment)
//    }
}

extension StringResource1 {
    public func callAsFunction(_ arg1: Arg1) -> String {
        let format = NSLocalizedString(key.description, tableName: tableName, bundle: bundle, value: defaultValue ?? "", comment: "")
        return String(format: format, locale: locale, arguments: [arg1])
    }

    @available(*, deprecated, message: "Use R.string(preferredLanguages:).*.* instead")
    public func callAsFunction(_ arg1: Arg1, preferredLanguages: [String]) -> String {
        guard let (bundle, locale) = bundle.firstBundleAndLocale(tableName: tableName, preferredLanguages: preferredLanguages) else {
            return key.description
        }
        let format = NSLocalizedString(key.description, tableName: tableName, bundle: bundle, value: "", comment: "")
        return String(format: format, locale: locale, arguments: [arg1])
    }
}

extension StringResource2 {
    public func callAsFunction(_ arg1: Arg1, _ arg2: Arg2) -> String {
        let format = NSLocalizedString(key.description, tableName: tableName, bundle: bundle, value: defaultValue ?? "", comment: "")
        return String(format: format, locale: locale, arguments: [arg1, arg2])
    }

    @available(*, deprecated, message: "Use R.string(preferredLanguages:).*.* instead")
    public func callAsFunction(_ arg1: Arg1, _ arg2: Arg2, preferredLanguages: [String]) -> String {
        guard let (bundle, locale) = bundle.firstBundleAndLocale(tableName: tableName, preferredLanguages: preferredLanguages) else {
            return key.description
        }
        let format = NSLocalizedString(key.description, tableName: tableName, bundle: bundle, value: "", comment: "")
        return String(format: format, locale: locale, arguments: [arg1, arg2])
    }
}

extension StringResource3 {
    public func callAsFunction(_ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3) -> String {
        let format = NSLocalizedString(key.description, tableName: tableName, bundle: bundle, value: defaultValue ?? "", comment: "")
        return String(format: format, locale: locale, arguments: [arg1, arg2, arg3])
    }

    @available(*, deprecated, message: "Use R.string(preferredLanguages:).*.* instead")
    public func callAsFunction(_ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, preferredLanguages: [String]) -> String {
        guard let (bundle, locale) = bundle.firstBundleAndLocale(tableName: tableName, preferredLanguages: preferredLanguages) else {
            return key.description
        }
        let format = NSLocalizedString(key.description, tableName: tableName, bundle: bundle, value: "", comment: "")
        return String(format: format, locale: locale, arguments: [arg1, arg2, arg3])
    }
}

extension StringResource4 {
    public func callAsFunction(_ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4) -> String {
        let format = NSLocalizedString(key.description, tableName: tableName, bundle: bundle, value: defaultValue ?? "", comment: "")
        return String(format: format, locale: locale, arguments: [arg1, arg2, arg3, arg4])
    }

    @available(*, deprecated, message: "Use R.string(preferredLanguages:).*.* instead")
    public func callAsFunction(_ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4, preferredLanguages: [String]) -> String {
        guard let (bundle, locale) = bundle.firstBundleAndLocale(tableName: tableName, preferredLanguages: preferredLanguages) else {
            return key.description
        }
        let format = NSLocalizedString(key.description, tableName: tableName, bundle: bundle, value: "", comment: "")
        return String(format: format, locale: locale, arguments: [arg1, arg2, arg3, arg4])
    }
}

extension StringResource5 {
    public func callAsFunction(_ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4, _ arg5: Arg5) -> String {
        let format = NSLocalizedString(key.description, tableName: tableName, bundle: bundle, value: defaultValue ?? "", comment: "")
        return String(format: format, locale: locale, arguments: [arg1, arg2, arg3, arg4, arg5])
    }

    @available(*, deprecated, message: "Use R.string(preferredLanguages:).*.* instead")
    public func callAsFunction(_ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4, _ arg5: Arg5, preferredLanguages: [String]) -> String {
        guard let (bundle, locale) = bundle.firstBundleAndLocale(tableName: tableName, preferredLanguages: preferredLanguages) else {
            return key.description
        }
        let format = NSLocalizedString(key.description, tableName: tableName, bundle: bundle, value: "", comment: "")
        return String(format: format, locale: locale, arguments: [arg1, arg2, arg3, arg4, arg5])
    }
}

extension StringResource6 {
    public func callAsFunction(_ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4, _ arg5: Arg5, _ arg6: Arg6) -> String {
        let format = NSLocalizedString(key.description, tableName: tableName, bundle: bundle, value: defaultValue ?? "", comment: "")
        return String(format: format, locale: locale, arguments: [arg1, arg2, arg3, arg4, arg5, arg6])
    }

    @available(*, deprecated, message: "Use R.string(preferredLanguages:).*.* instead")
    public func callAsFunction(_ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4, _ arg5: Arg5, _ arg6: Arg6, preferredLanguages: [String]) -> String {
        guard let (bundle, locale) = bundle.firstBundleAndLocale(tableName: tableName, preferredLanguages: preferredLanguages) else {
            return key.description
        }
        let format = NSLocalizedString(key.description, tableName: tableName, bundle: bundle, value: "", comment: "")
        return String(format: format, locale: locale, arguments: [arg1, arg2, arg3, arg4, arg5, arg6])
    }
}

extension StringResource7 {
    public func callAsFunction(_ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4, _ arg5: Arg5, _ arg6: Arg6, _ arg7: Arg7) -> String {
        let format = NSLocalizedString(key.description, tableName: tableName, bundle: bundle, value: defaultValue ?? "", comment: "")
        return String(format: format, locale: locale, arguments: [arg1, arg2, arg3, arg4, arg5, arg6, arg7])
    }

    @available(*, deprecated, message: "Use R.string(preferredLanguages:).*.* instead")
    public func callAsFunction(_ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4, _ arg5: Arg5, _ arg6: Arg6, _ arg7: Arg7, preferredLanguages: [String]) -> String {
        guard let (bundle, locale) = bundle.firstBundleAndLocale(tableName: tableName, preferredLanguages: preferredLanguages) else {
            return key.description
        }
        let format = NSLocalizedString(key.description, tableName: tableName, bundle: bundle, value: "", comment: "")
        return String(format: format, locale: locale, arguments: [arg1, arg2, arg3, arg4, arg5, arg6, arg7])
    }
}

extension StringResource8 {
    public func callAsFunction(_ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4, _ arg5: Arg5, _ arg6: Arg6, _ arg7: Arg7, _ arg8: Arg8) -> String {
        let format = NSLocalizedString(key.description, tableName: tableName, bundle: bundle, value: defaultValue ?? "", comment: "")
        return String(format: format, locale: locale, arguments: [arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8])
    }

    @available(*, deprecated, message: "Use R.string(preferredLanguages:).*.* instead")
    public func callAsFunction(_ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4, _ arg5: Arg5, _ arg6: Arg6, _ arg7: Arg7, _ arg8: Arg8, preferredLanguages: [String]) -> String {
        guard let (bundle, locale) = bundle.firstBundleAndLocale(tableName: tableName, preferredLanguages: preferredLanguages) else {
            return key.description
        }
        let format = NSLocalizedString(key.description, tableName: tableName, bundle: bundle, value: "", comment: "")
        return String(format: format, locale: locale, arguments: [arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8])
    }
}

extension StringResource9 {
    public func callAsFunction(_ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4, _ arg5: Arg5, _ arg6: Arg6, _ arg7: Arg7, _ arg8: Arg8, _ arg9: Arg9) -> String {
        let format = NSLocalizedString(key.description, tableName: tableName, bundle: bundle, value: defaultValue ?? "", comment: "")
        return String(format: format, locale: locale, arguments: [arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9])
    }

    @available(*, deprecated, message: "Use R.string(preferredLanguages:).*.* instead")
    public func callAsFunction(_ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4, _ arg5: Arg5, _ arg6: Arg6, _ arg7: Arg7, _ arg8: Arg8, _ arg9: Arg9, preferredLanguages: [String]) -> String {
        guard let (bundle, locale) = bundle.firstBundleAndLocale(tableName: tableName, preferredLanguages: preferredLanguages) else {
            return key.description
        }
        let format = NSLocalizedString(key.description, tableName: tableName, bundle: bundle, value: "", comment: "")
        return String(format: format, locale: locale, arguments: [arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9])
    }
}
