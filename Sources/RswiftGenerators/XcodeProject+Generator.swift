//
//  XcodeProjectGenerator.swift
//  
//
//  Created by Tom Lokhorst on 2022-11-03.
//

import Foundation

public struct XcodeProjectGenerator {
    public static func generateProject(developmentRegion: String?, knownAssetTags: [String]?) -> Struct {
        Struct(name: SwiftIdentifier(name: "project")) {
            let warning: (String) -> Void = { print("warning: [R.swift]", $0) }

            if let developmentRegion {
                LetBinding(name: SwiftIdentifier(name: "developmentRegion"), valueCodeString: #""\#(developmentRegion)""#)
            }

            if let knownAssetTags {
                let grouped = knownAssetTags.grouped(bySwiftIdentifier: { $0 })
                grouped.reportWarningsForDuplicatesAndEmpties(source: "known asset tag", result: "known asset tag", warning: warning)
                if grouped.uniques.count > 0 {
                    Struct(name: SwiftIdentifier(name: "knownAssetTags"), protocols: [.sequence]) {
                        grouped.uniques.map { tag in
                            LetBinding(name: SwiftIdentifier(name: tag), valueCodeString: #""\#(tag)""#)
                        }

                        generateMakeIterator(names: grouped.uniques.map { SwiftIdentifier(name: $0) })
                    }
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
