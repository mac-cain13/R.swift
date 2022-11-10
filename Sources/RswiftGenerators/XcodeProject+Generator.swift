//
//  XcodeProjectGenerator.swift
//  
//
//  Created by Tom Lokhorst on 2022-11-03.
//

import Foundation

public struct XcodeProjectGenerator {
    public static func generateProject(developmentRegion: String, knownAssetTags: [String]?) -> Struct {
        Struct(name: SwiftIdentifier(name: "project")) {
            LetBinding(name: SwiftIdentifier(name: "developmentRegion"), valueCodeString: #""\#(developmentRegion)""#)

            if let knownAssetTags {
                Struct(name: SwiftIdentifier(name: "knownAssetTags"), protocols: [.sequence]) {
                    knownAssetTags.map { tag in
                        LetBinding(name: SwiftIdentifier(name: tag), valueCodeString: #""\#(tag)""#)
                    }

                    generateMakeIterator(names: knownAssetTags.map { SwiftIdentifier(name: $0) })
                }
            }
        }
    }

    private static func generateMakeIterator(names: [SwiftIdentifier]) -> Function {
        Function(
            comments: [],
            name: .init(name: "makeIterator"),
            params: [],
            returnType: .indexingIterator(.string),
            valueCodeString: "[\(names.map(\.value).joined(separator: ", "))].makeIterator()"
        )
    }
}
