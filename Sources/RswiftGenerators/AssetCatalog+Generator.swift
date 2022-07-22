//
//  AssetCatalog+Generator.swift
//  
//
//  Created by Tom Lokhorst on 2022-07-15.
//

import Foundation
import RswiftResources

extension AssetCatalog {
    public func generateColorResourceLetCodeString() -> String {
        root.generateColorResourceLetsCodeString().joined(separator: "\n")
    }
}

extension AssetCatalog.Namespace {
    fileprivate func generateColorResourceLetsCodeString() -> [String] {
        var cs = colors.map { color in
            "static let \(SwiftIdentifier(name: color.name).value) = AssetCatalog.\(color)"
        }

        for namespace in subnamespaces {
            cs.append("struct \(SwiftIdentifier(name: namespace.name).value) {")
            cs.append(contentsOf: namespace.generateColorResourceLetsCodeString().map { "  \($0)" })
            cs.append("}")
        }

        return cs
    }

}
