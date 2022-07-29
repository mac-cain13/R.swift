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

    static var bundle: TypeReference = .init(module: .foundation, rawName: "Bundle")
    static var locale: TypeReference = .init(module: .foundation, rawName: "Locale")
    static var string: TypeReference = .init(module: .stdLib, rawName: "String")
    static var uiView: TypeReference = .init(module: .uiKit, rawName: "UIView")
    static var uiViewController: TypeReference = .init(module: .uiKit, rawName: "UIViewController")
}
