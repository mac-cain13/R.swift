//
//  AssetCatalog+Generator.swift
//  
//
//  Created by Tom Lokhorst on 2022-07-23.
//

import Foundation
import RswiftResources

public protocol AssetCatalogContent {
    var name: String { get }
    func generateLetBinding() -> LetBinding
}

extension ColorResource {
    public static func generateStruct(catalogs: [AssetCatalog], prefix: SwiftIdentifier) -> Struct {
        let merged: AssetCatalog.Namespace = catalogs.map(\.root).reduce(.init(), { $0.merging($1) })

        return merged.generateStruct(resourceName: "color", resourcesSelector: { $0.colors }, prefix: prefix)
    }
}

extension DataResource {
    public static func generateStruct(catalogs: [AssetCatalog], prefix: SwiftIdentifier) -> Struct {
        let merged: AssetCatalog.Namespace = catalogs.map(\.root).reduce(.init(), { $0.merging($1) })

        return merged.generateStruct(resourceName: "data", resourcesSelector: { $0.dataAssets }, prefix: prefix)
    }
}

extension ImageResource {
    public static func generateStruct(catalogs: [AssetCatalog], toplevel resources: [ImageResource], prefix: SwiftIdentifier) -> Struct {
        // Multiple resources can share same name,
        // for example: Colors.jpg and Colors@2x.jpg are both named "Colors.jpg"
        // Deduplicate these
        let namedResources = Dictionary(grouping: resources, by: \.name).values.map(\.first!)

        var merged: AssetCatalog.Namespace = catalogs.map(\.root).reduce(.init(), { $0.merging($1) })
        merged.images += namedResources

        return merged.generateStruct(resourceName: "image", resourcesSelector: { $0.images }, prefix: prefix)
    }
}

extension AssetCatalog.Namespace {
    public func generateStruct(resourceName: String, resourcesSelector: (Self) -> [AssetCatalogContent], prefix: SwiftIdentifier) -> Struct {
        let structName = SwiftIdentifier(name: resourceName)
        let qualifiedName = prefix + structName
        let warning: (String) -> Void = { print("warning:", $0) }

        let allResources = resourcesSelector(self)
        let groupedResources = allResources.grouped(bySwiftIdentifier: { $0.name })
        groupedResources.reportWarningsForDuplicatesAndEmpties(source: resourceName, result: resourceName, warning: warning)

        let letbindings = groupedResources.uniques.map { $0.generateLetBinding() }
        let otherIdentifiers = groupedResources.uniques.map { SwiftIdentifier(name: $0.name) }

        let mergedNamespaces = AssetCatalogMergedNamespaces(all: subnamespaces, otherIdentifiers: otherIdentifiers)
        mergedNamespaces.printWarningsForDuplicates(result: resourceName, warning: warning)

        let structs = mergedNamespaces.namespaces
            .sorted { $0.key < $1.key }
            .map { (name, namespace) in
                namespace.generateStruct(
                    resourceName: resourceName,
                    resourcesSelector: resourcesSelector,
                    prefix: qualifiedName
                )
            }
            .filter { !$0.isEmpty }

        let comment = [
            "This `\(qualifiedName.value)` struct is generated, and contains static references to \(letbindings.count) \(resourceName)s",
            structs.isEmpty ? "" : ", and \(structs.count) namespaces",
            "."
        ].joined()

        let comments = [comment]
        return Struct(comments: comments, name: structName) {
            letbindings
            structs
        }
    }
}

extension ColorResource: AssetCatalogContent {
    public func generateLetBinding() -> LetBinding {
        let fullname = (path + [name]).joined(separator: "/")
        let code = "ColorResource(name: \"\(fullname)\")"
        return LetBinding(
            comments: ["Color `\(fullname)`."],
            isStatic: true,
            name: SwiftIdentifier(name: name),
            valueCodeString: code
        )
    }
}

extension DataResource: AssetCatalogContent {
    public func generateLetBinding() -> LetBinding {
        let fullname = (path + [name]).joined(separator: "/")
        let code = "DataResource(name: \"\(fullname)\")"
        return LetBinding(
            comments: ["Data asset `\(fullname)`."],
            isStatic: true,
            name: SwiftIdentifier(name: name),
            valueCodeString: code
        )
    }
}

extension ImageResource: AssetCatalogContent {
    public func generateLetBinding() -> LetBinding {
        let locs = locale.map { $0.codeString() } ?? "nil"
        let odrt = onDemandResourceTags?.debugDescription ?? "nil"
        let fullname = (path + [name]).joined(separator: "/")
        let code = "ImageResource(name: \"\(fullname)\", locale: \(locs), onDemandResourceTags: \(odrt))"
        return LetBinding(
            comments: ["Image `\(fullname)`."],
            isStatic: true,
            name: SwiftIdentifier(name: name),
            valueCodeString: code
        )
    }
}
