//
//  File.swift
//  
//
//  Created by Tom Lokhorst on 2022-07-22.
//

import RswiftResources

extension LocaleReference {
    func codeString() -> String {
        switch self {
        case .none:
            return "LocaleReference.none" // Plain `.none` is ambiguous whith Optional<LocaleReference>
        case .base:
            return ".base"
        case .language(let string):
            return ".language(\(string))"
        }
    }
}
