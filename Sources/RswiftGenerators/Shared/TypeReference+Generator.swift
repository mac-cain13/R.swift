//
//  File.swift
//  
//
//  Created by Tom Lokhorst on 2022-07-24.
//

import Foundation
import RswiftResources

extension TypeReference {
    init(module: ModuleReference, name: String, genericArgs: [TypeReference]) {
        let args = genericArgs.map { $0.codeString() }.joined(separator: ", ")
        let rawName = args.isEmpty ? name : "\(name)<\(args)>"

        self.init(module: module, rawName: rawName)
    }
}

extension TypeReference {
    func codeString() -> String {
        if case .custom(let module) = module {
            return "\(module).\(rawName)"
        } else {
            return rawName
        }
    }
}
