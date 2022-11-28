//
//  StringResource+Integrations.swift
//  
//
//  Created by Tom Lokhorst on 2022-07-30.
//

import Foundation
import SwiftUI

extension String {
    init(key: StaticString, tableName: String, source: StringResource.Source, developmentValue: String?) {
        switch source {
        case let .hosting(bundle):
            // With fallback to developmentValue
            self = NSLocalizedString(key.description, tableName: tableName, bundle: bundle, value: developmentValue ?? "", comment: "")

        case let .selected(bundle, _):
            // Don't use developmentValue with selected bundle/locale
            self = NSLocalizedString(key.description, tableName: tableName, bundle: bundle, value: "", comment: "")

        case .none:
            self = key.description
        }
    }

    init(key: StaticString, tableName: String, source: StringResource.Source, developmentValue: String?, preferredLanguages: [String]) {
        guard let (bundle, locale) = source.bundle?.firstBundleAndLocale(tableName: tableName, preferredLanguages: preferredLanguages) else {
            self = key.description
            return
        }

        self.init(key: key, tableName: tableName, source: .selected(bundle, locale), developmentValue: developmentValue)
    }

    init(key: StaticString, tableName: String, source: StringResource.Source, developmentValue: String?, arguments: [CVarArg]) {
        switch source {
        case let .hosting(bundle):
            // With fallback to developmentValue
            let format = NSLocalizedString(key.description, tableName: tableName, bundle: bundle, value: developmentValue ?? "", comment: "")
            self = String(format: format, arguments: arguments)

        case let .selected(bundle, locale):
            // Don't use developmentValue with selected bundle/locale
            let format = NSLocalizedString(key.description, tableName: tableName, bundle: bundle, value: "", comment: "")
            self = String(format: format, locale: locale, arguments: arguments)

        case .none:
            self = key.description
        }
    }

    init(key: StaticString, tableName: String, source: StringResource.Source, developmentValue: String?, preferredLanguages: [String], arguments: [CVarArg]) {
        guard let (bundle, locale) = source.bundle?.firstBundleAndLocale(tableName: tableName, preferredLanguages: preferredLanguages) else {
            self = key.description
            return
        }

        self.init(key: key, tableName: tableName, source: .selected(bundle, locale), developmentValue: developmentValue, arguments: arguments)
    }
}

extension String {
    public init(resource: StringResource) {
        self.init(key: resource.key, tableName: resource.tableName, source: resource.source, developmentValue: resource.developmentValue)
    }

    public init(resource: StringResource, preferredLanguages: [String]) {
        self.init(key: resource.key, tableName: resource.tableName, source: resource.source, developmentValue: resource.developmentValue, preferredLanguages: preferredLanguages)
    }

    public init<Arg1: CVarArg>(format resource: StringResource1<Arg1>, _ arg1: Arg1) {
        self.init(key: resource.key, tableName: resource.tableName, source: resource.source, developmentValue: resource.developmentValue, arguments: [arg1])
    }

    public init<Arg1: CVarArg>(format resource: StringResource1<Arg1>, preferredLanguages: [String], _ arg1: Arg1) {
        self.init(key: resource.key, tableName: resource.tableName, source: resource.source, developmentValue: resource.developmentValue, preferredLanguages: preferredLanguages, arguments: [arg1])
    }

    public init<Arg1: CVarArg, Arg2: CVarArg>(format resource: StringResource2<Arg1, Arg2>, _ arg1: Arg1, _ arg2: Arg2) {
        self.init(key: resource.key, tableName: resource.tableName, source: resource.source, developmentValue: resource.developmentValue, arguments: [arg1, arg2])
    }

    public init<Arg1: CVarArg, Arg2: CVarArg>(format resource: StringResource2<Arg1, Arg2>, preferredLanguages: [String], _ arg1: Arg1, _ arg2: Arg2) {
        self.init(key: resource.key, tableName: resource.tableName, source: resource.source, developmentValue: resource.developmentValue, preferredLanguages: preferredLanguages, arguments: [arg1, arg2])
    }

    public init<Arg1: CVarArg, Arg2: CVarArg, Arg3: CVarArg>(format resource: StringResource3<Arg1, Arg2, Arg3>, _ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3) {
        self.init(key: resource.key, tableName: resource.tableName, source: resource.source, developmentValue: resource.developmentValue, arguments: [arg1, arg2, arg3])
    }

    public init<Arg1: CVarArg, Arg2: CVarArg, Arg3: CVarArg>(format resource: StringResource3<Arg1, Arg2, Arg3>, preferredLanguages: [String], _ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3) {
        self.init(key: resource.key, tableName: resource.tableName, source: resource.source, developmentValue: resource.developmentValue, preferredLanguages: preferredLanguages, arguments: [arg1, arg2, arg3])
    }

    public init<Arg1: CVarArg, Arg2: CVarArg, Arg3: CVarArg, Arg4: CVarArg>(format resource: StringResource4<Arg1, Arg2, Arg3, Arg4>, _ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4) {
        self.init(key: resource.key, tableName: resource.tableName, source: resource.source, developmentValue: resource.developmentValue, arguments: [arg1, arg2, arg3, arg4])
    }

    public init<Arg1: CVarArg, Arg2: CVarArg, Arg3: CVarArg, Arg4: CVarArg>(format resource: StringResource4<Arg1, Arg2, Arg3, Arg4>, preferredLanguages: [String], _ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4) {
        self.init(key: resource.key, tableName: resource.tableName, source: resource.source, developmentValue: resource.developmentValue, preferredLanguages: preferredLanguages, arguments: [arg1, arg2, arg3, arg4])
    }

    public init<Arg1: CVarArg, Arg2: CVarArg, Arg3: CVarArg, Arg4: CVarArg, Arg5: CVarArg>(format resource: StringResource5<Arg1, Arg2, Arg3, Arg4, Arg5>, _ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4, _ arg5: Arg5) {
        self.init(key: resource.key, tableName: resource.tableName, source: resource.source, developmentValue: resource.developmentValue, arguments: [arg1, arg2, arg3, arg4, arg5])
    }

    public init<Arg1: CVarArg, Arg2: CVarArg, Arg3: CVarArg, Arg4: CVarArg, Arg5: CVarArg>(format resource: StringResource5<Arg1, Arg2, Arg3, Arg4, Arg5>, preferredLanguages: [String], _ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4, _ arg5: Arg5) {
        self.init(key: resource.key, tableName: resource.tableName, source: resource.source, developmentValue: resource.developmentValue, preferredLanguages: preferredLanguages, arguments: [arg1, arg2, arg3, arg4, arg5])
    }

    public init<Arg1: CVarArg, Arg2: CVarArg, Arg3: CVarArg, Arg4: CVarArg, Arg5: CVarArg, Arg6: CVarArg>(format resource: StringResource6<Arg1, Arg2, Arg3, Arg4, Arg5, Arg6>, _ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4, _ arg5: Arg5, _ arg6: Arg6) {
        self.init(key: resource.key, tableName: resource.tableName, source: resource.source, developmentValue: resource.developmentValue, arguments: [arg1, arg2, arg3, arg4, arg5, arg6])
    }

    public init<Arg1: CVarArg, Arg2: CVarArg, Arg3: CVarArg, Arg4: CVarArg, Arg5: CVarArg, Arg6: CVarArg>(format resource: StringResource6<Arg1, Arg2, Arg3, Arg4, Arg5, Arg6>, preferredLanguages: [String], _ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4, _ arg5: Arg5, _ arg6: Arg6) {
        self.init(key: resource.key, tableName: resource.tableName, source: resource.source, developmentValue: resource.developmentValue, preferredLanguages: preferredLanguages, arguments: [arg1, arg2, arg3, arg4, arg5, arg6])
    }

    public init<Arg1: CVarArg, Arg2: CVarArg, Arg3: CVarArg, Arg4: CVarArg, Arg5: CVarArg, Arg6: CVarArg, Arg7: CVarArg>(format resource: StringResource7<Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7>, _ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4, _ arg5: Arg5, _ arg6: Arg6, _ arg7: Arg7) {
        self.init(key: resource.key, tableName: resource.tableName, source: resource.source, developmentValue: resource.developmentValue, arguments: [arg1, arg2, arg3, arg4, arg5, arg6, arg7])
    }

    public init<Arg1: CVarArg, Arg2: CVarArg, Arg3: CVarArg, Arg4: CVarArg, Arg5: CVarArg, Arg6: CVarArg, Arg7: CVarArg>(format resource: StringResource7<Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7>, preferredLanguages: [String], _ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4, _ arg5: Arg5, _ arg6: Arg6, _ arg7: Arg7) {
        self.init(key: resource.key, tableName: resource.tableName, source: resource.source, developmentValue: resource.developmentValue, preferredLanguages: preferredLanguages, arguments: [arg1, arg2, arg3, arg4, arg5, arg6, arg7])
    }

    public init<Arg1: CVarArg, Arg2: CVarArg, Arg3: CVarArg, Arg4: CVarArg, Arg5: CVarArg, Arg6: CVarArg, Arg7: CVarArg, Arg8: CVarArg>(format resource: StringResource8<Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8>, _ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4, _ arg5: Arg5, _ arg6: Arg6, _ arg7: Arg7, _ arg8: Arg8) {
        self.init(key: resource.key, tableName: resource.tableName, source: resource.source, developmentValue: resource.developmentValue, arguments: [arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8])
    }

    public init<Arg1: CVarArg, Arg2: CVarArg, Arg3: CVarArg, Arg4: CVarArg, Arg5: CVarArg, Arg6: CVarArg, Arg7: CVarArg, Arg8: CVarArg>(format resource: StringResource8<Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8>, preferredLanguages: [String], _ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4, _ arg5: Arg5, _ arg6: Arg6, _ arg7: Arg7, _ arg8: Arg8) {
        self.init(key: resource.key, tableName: resource.tableName, source: resource.source, developmentValue: resource.developmentValue, preferredLanguages: preferredLanguages, arguments: [arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8])
    }

    public init<Arg1: CVarArg, Arg2: CVarArg, Arg3: CVarArg, Arg4: CVarArg, Arg5: CVarArg, Arg6: CVarArg, Arg7: CVarArg, Arg8: CVarArg, Arg9: CVarArg>(format resource: StringResource9<Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Arg9>, _ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4, _ arg5: Arg5, _ arg6: Arg6, _ arg7: Arg7, _ arg8: Arg8, _ arg9: Arg9) {
        self.init(key: resource.key, tableName: resource.tableName, source: resource.source, developmentValue: resource.developmentValue, arguments: [arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9])
    }

    public init<Arg1: CVarArg, Arg2: CVarArg, Arg3: CVarArg, Arg4: CVarArg, Arg5: CVarArg, Arg6: CVarArg, Arg7: CVarArg, Arg8: CVarArg, Arg9: CVarArg>(format resource: StringResource9<Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Arg9>, preferredLanguages: [String], _ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4, _ arg5: Arg5, _ arg6: Arg6, _ arg7: Arg7, _ arg8: Arg8, _ arg9: Arg9) {
        self.init(key: resource.key, tableName: resource.tableName, source: resource.source, developmentValue: resource.developmentValue, preferredLanguages: preferredLanguages, arguments: [arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9])
    }
}


@available(macOS 10, iOS 13, tvOS 13, watchOS 6, *)
extension Text {
    public init(_ resource: StringResource) {
        self.init(String(resource: resource))
    }

    public init<Arg1: CVarArg>(_ resource: StringResource1<Arg1>, _ arg1: Arg1) {
        self.init(String(key: resource.key, tableName: resource.tableName, source: resource.source, developmentValue: resource.developmentValue, arguments: [arg1]))
    }

    public init<Arg1: CVarArg, Arg2: CVarArg>(_ resource: StringResource2<Arg1, Arg2>, _ arg1: Arg1, _ arg2: Arg2) {
        self.init(String(key: resource.key, tableName: resource.tableName, source: resource.source, developmentValue: resource.developmentValue, arguments: [arg1, arg2]))
    }

    public init<Arg1: CVarArg, Arg2: CVarArg, Arg3: CVarArg>(_ resource: StringResource3<Arg1, Arg2, Arg3>, _ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3) {
        self.init(String(key: resource.key, tableName: resource.tableName, source: resource.source, developmentValue: resource.developmentValue, arguments: [arg1, arg2, arg3]))
    }

    public init<Arg1: CVarArg, Arg2: CVarArg, Arg3: CVarArg, Arg4: CVarArg>(_ resource: StringResource4<Arg1, Arg2, Arg3, Arg4>, _ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4) {
        self.init(String(key: resource.key, tableName: resource.tableName, source: resource.source, developmentValue: resource.developmentValue, arguments: [arg1, arg2, arg3, arg4]))
    }

    public init<Arg1: CVarArg, Arg2: CVarArg, Arg3: CVarArg, Arg4: CVarArg, Arg5: CVarArg>(_ resource: StringResource5<Arg1, Arg2, Arg3, Arg4, Arg5>, _ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4, _ arg5: Arg5) {
        self.init(String(key: resource.key, tableName: resource.tableName, source: resource.source, developmentValue: resource.developmentValue, arguments: [arg1, arg2, arg3, arg4, arg5]))
    }

    public init<Arg1: CVarArg, Arg2: CVarArg, Arg3: CVarArg, Arg4: CVarArg, Arg5: CVarArg, Arg6: CVarArg>(_ resource: StringResource6<Arg1, Arg2, Arg3, Arg4, Arg5, Arg6>, _ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4, _ arg5: Arg5, _ arg6: Arg6) {
        self.init(String(key: resource.key, tableName: resource.tableName, source: resource.source, developmentValue: resource.developmentValue, arguments: [arg1, arg2, arg3, arg4, arg5, arg6]))
    }

    public init<Arg1: CVarArg, Arg2: CVarArg, Arg3: CVarArg, Arg4: CVarArg, Arg5: CVarArg, Arg6: CVarArg, Arg7: CVarArg>(_ resource: StringResource7<Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7>, _ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4, _ arg5: Arg5, _ arg6: Arg6, _ arg7: Arg7) {
        self.init(String(key: resource.key, tableName: resource.tableName, source: resource.source, developmentValue: resource.developmentValue, arguments: [arg1, arg2, arg3, arg4, arg5, arg6, arg7]))
    }

    public init<Arg1: CVarArg, Arg2: CVarArg, Arg3: CVarArg, Arg4: CVarArg, Arg5: CVarArg, Arg6: CVarArg, Arg7: CVarArg, Arg8: CVarArg>(_ resource: StringResource8<Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8>, _ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4, _ arg5: Arg5, _ arg6: Arg6, _ arg7: Arg7, _ arg8: Arg8) {
        self.init(String(key: resource.key, tableName: resource.tableName, source: resource.source, developmentValue: resource.developmentValue, arguments: [arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8]))
    }

    public init<Arg1: CVarArg, Arg2: CVarArg, Arg3: CVarArg, Arg4: CVarArg, Arg5: CVarArg, Arg6: CVarArg, Arg7: CVarArg, Arg8: CVarArg, Arg9: CVarArg>(_ resource: StringResource9<Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Arg9>, _ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4, _ arg5: Arg5, _ arg6: Arg6, _ arg7: Arg7, _ arg8: Arg8, _ arg9: Arg9) {
        self.init(String(key: resource.key, tableName: resource.tableName, source: resource.source, developmentValue: resource.developmentValue, arguments: [arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9]))
    }
}

extension StringResource.Source {
    public init(bundle: Bundle, tableName: String, preferredLanguages: [String]?) {
        guard let preferredLanguages = preferredLanguages else {
            self = .hosting(bundle)
            return
        }
        if let (bundle, locale) = bundle.firstBundleAndLocale(tableName: tableName, preferredLanguages: preferredLanguages) {
            self = .selected(bundle, locale)
        } else {
            self = .none
        }
    }
}

extension StringResource {
    public func callAsFunction() -> String {
        String(resource: self)
    }

    @available(*, deprecated, message: "Use R.string(preferredLanguages:).*.* instead")
    public func callAsFunction(preferredLanguages: [String]) -> String {
        String(resource: self, preferredLanguages: preferredLanguages)
    }

//    @available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
//    public var localizedStringResource: LocalizedStringResource {
//        LocalizedStringResource(key, defaultValue: String.LocalizationValue(stringLiteral: defaultValue), bundle: bundle == .main ? .main : .atURL(bundle.bundleURL), comment: comment)
//    }
}

extension StringResource1 {
    public func callAsFunction(_ arg1: Arg1) -> String {
        String(format: self, arg1)
    }

    @available(*, deprecated, message: "Use R.string(preferredLanguages:).*.* instead")
    public func callAsFunction(_ arg1: Arg1, preferredLanguages: [String]) -> String {
        String(format: self, preferredLanguages: preferredLanguages, arg1)
    }
}

extension StringResource2 {
    public func callAsFunction(_ arg1: Arg1, _ arg2: Arg2) -> String {
        String(format: self, arg1, arg2)
    }

    @available(*, deprecated, message: "Use R.string(preferredLanguages:).*.* instead")
    public func callAsFunction(_ arg1: Arg1, _ arg2: Arg2, preferredLanguages: [String]) -> String {
        String(format: self, preferredLanguages: preferredLanguages, arg1, arg2)
    }
}

extension StringResource3 {
    public func callAsFunction(_ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3) -> String {
        String(format: self, arg1, arg2, arg3)
    }

    @available(*, deprecated, message: "Use R.string(preferredLanguages:).*.* instead")
    public func callAsFunction(_ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, preferredLanguages: [String]) -> String {
        String(format: self, preferredLanguages: preferredLanguages, arg1, arg2, arg3)
    }
}

extension StringResource4 {
    public func callAsFunction(_ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4) -> String {
        String(format: self, arg1, arg2, arg3, arg4)
    }

    @available(*, deprecated, message: "Use R.string(preferredLanguages:).*.* instead")
    public func callAsFunction(_ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4, preferredLanguages: [String]) -> String {
        String(format: self, preferredLanguages: preferredLanguages, arg1, arg2, arg3, arg4)
    }
}

extension StringResource5 {
    public func callAsFunction(_ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4, _ arg5: Arg5) -> String {
        String(format: self, arg1, arg2, arg3, arg4, arg5)
    }

    @available(*, deprecated, message: "Use R.string(preferredLanguages:).*.* instead")
    public func callAsFunction(_ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4, _ arg5: Arg5, preferredLanguages: [String]) -> String {
        String(format: self, preferredLanguages: preferredLanguages, arg1, arg2, arg3, arg4, arg5)
    }
}

extension StringResource6 {
    public func callAsFunction(_ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4, _ arg5: Arg5, _ arg6: Arg6) -> String {
        String(format: self, arg1, arg2, arg3, arg4, arg5, arg6)
    }

    @available(*, deprecated, message: "Use R.string(preferredLanguages:).*.* instead")
    public func callAsFunction(_ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4, _ arg5: Arg5, _ arg6: Arg6, preferredLanguages: [String]) -> String {
        String(format: self, preferredLanguages: preferredLanguages, arg1, arg2, arg3, arg4, arg5, arg6)
    }
}

extension StringResource7 {
    public func callAsFunction(_ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4, _ arg5: Arg5, _ arg6: Arg6, _ arg7: Arg7) -> String {
        String(format: self, arg1, arg2, arg3, arg4, arg5, arg6, arg7)
    }

    @available(*, deprecated, message: "Use R.string(preferredLanguages:).*.* instead")
    public func callAsFunction(_ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4, _ arg5: Arg5, _ arg6: Arg6, _ arg7: Arg7, preferredLanguages: [String]) -> String {
        String(format: self, preferredLanguages: preferredLanguages, arg1, arg2, arg3, arg4, arg5, arg6, arg7)
    }
}

extension StringResource8 {
    public func callAsFunction(_ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4, _ arg5: Arg5, _ arg6: Arg6, _ arg7: Arg7, _ arg8: Arg8) -> String {
        String(format: self, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
    }

    @available(*, deprecated, message: "Use R.string(preferredLanguages:).*.* instead")
    public func callAsFunction(_ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4, _ arg5: Arg5, _ arg6: Arg6, _ arg7: Arg7, _ arg8: Arg8, preferredLanguages: [String]) -> String {
        String(format: self, preferredLanguages: preferredLanguages, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
    }
}

extension StringResource9 {
    public func callAsFunction(_ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4, _ arg5: Arg5, _ arg6: Arg6, _ arg7: Arg7, _ arg8: Arg8, _ arg9: Arg9) -> String {
        String(format: self, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
    }

    @available(*, deprecated, message: "Use R.string(preferredLanguages:).*.* instead")
    public func callAsFunction(_ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4, _ arg5: Arg5, _ arg6: Arg6, _ arg7: Arg7, _ arg8: Arg8, _ arg9: Arg9, preferredLanguages: [String]) -> String {
        String(format: self, preferredLanguages: preferredLanguages, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
    }
}
