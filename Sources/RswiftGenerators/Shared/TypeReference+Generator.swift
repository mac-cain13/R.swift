//
//  File.swift
//  
//
//  Created by Tom Lokhorst on 2022-07-24.
//

import Foundation
import RswiftResources

extension TypeReference {
    func codeString() -> String {
        let args = genericArgs.map { $0.codeString() }.joined(separator: ", ")
        let rawName = args.isEmpty ? name : "\(name)<\(args)>"

        if case .custom(let module) = module {
            return "\(module).\(rawName)"
        } else {
            return rawName
        }
    }

//    static func someIteratorProtocol(_ element: TypeReference) -> TypeReference {
//        var result = TypeReference(module: .stdLib, rawName: "some IteratorProtocol")
//        result.genericArgs = [element]
//        return result
//    }

    static func indexingIterator(_ element: TypeReference) -> TypeReference {
        var result = TypeReference(module: .stdLib, rawName: "IndexingIterator")
        result.genericArgs = [TypeReference(module: .stdLib, rawName: "[\(element.codeString())]")]
        return result
    }

    static let bundle: TypeReference = .init(module: .foundation, rawName: "Bundle")
    static let locale: TypeReference = .init(module: .foundation, rawName: "Locale")
    static let void: TypeReference = .init(module: .stdLib, rawName: "Void")
    static let bool: TypeReference = .init(module: .stdLib, rawName: "Bool")
    static let string: TypeReference = .init(module: .stdLib, rawName: "String")
    static let sequence: TypeReference = .init(module: .stdLib, rawName: "Sequence")
    static let someIteratorProtocol: TypeReference = .init(module: .stdLib, rawName: "some IteratorProtocol")
    static let uiView: TypeReference = .init(module: .uiKit, rawName: "UIView")
    static let uiViewController: TypeReference = .init(module: .uiKit, rawName: "UIViewController")
    static let nsViewController: TypeReference = .init(module: .appKit, rawName: "NSViewController")


    static let fontResource: TypeReference = .init(module: .rswiftResources, rawName: "FontResource")
}
