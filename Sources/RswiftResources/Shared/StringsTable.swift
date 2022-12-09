//
//  LocalizableStrings.swift
//  R.swift
//
//  Created by Tom Lokhorst on 2016-04-24.
//

import Foundation

public struct StringsTable {
    public let filename: String
    public let locale: LocaleReference
    public let dictionary: [Key: Value]

    public init(filename: String, locale: LocaleReference, dictionary: [Key: Value]) {
        self.filename = filename
        self.locale = locale
        self.dictionary = dictionary
    }

    public typealias Key = String
    public struct Value {
        public let params: [StringParam]
        public let originalValue: String

        public init(params: [StringParam], originalValue: String) {
            self.params = params
            self.originalValue = originalValue
        }
    }
}
