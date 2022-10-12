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
    func generateVarGetter() -> VarGetter
}

extension ColorResource {
    public static func generateStruct(catalogs: [AssetCatalog], prefix: SwiftIdentifier) -> Struct {
        let merged: AssetCatalog.Namespace = catalogs.map(\.root).reduce(.init(), { $0.merging($1) })

        return merged.generateStruct(name: "color", resourcesSelector: { $0.colors }, prefix: prefix)
    }
}

extension DataResource {
    public static func generateStruct(catalogs: [AssetCatalog], prefix: SwiftIdentifier) -> Struct {
        let merged: AssetCatalog.Namespace = catalogs.map(\.root).reduce(.init(), { $0.merging($1) })

        return merged.generateStruct(name: "data", resourcesSelector: { $0.dataAssets }, prefix: prefix)
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

        return merged.generateStruct(name: "image", resourcesSelector: { $0.images }, prefix: prefix)
    }
}

extension AssetCatalog.Namespace {
    public func generateStruct(name: String, resourcesSelector: (Self) -> [AssetCatalogContent], prefix: SwiftIdentifier) -> Struct {
        generateStruct(resourceName: name, source: name, path: [], resourcesSelector: resourcesSelector, prefix: prefix)
    }

    private func generateStruct(resourceName: String, source: String, path: [String], resourcesSelector: (Self) -> [AssetCatalogContent], prefix: SwiftIdentifier) -> Struct {
        let structName = SwiftIdentifier(name: resourceName)
        let qualifiedName = prefix + structName
        let warning: (String) -> Void = { print("warning: [R.swift]", $0) }

        let container = path.isEmpty ? nil : path.joined(separator: "/")
        let allResources = resourcesSelector(self)
        let groupedResources = allResources.grouped(bySwiftIdentifier: { $0.name })
        groupedResources.reportWarningsForDuplicatesAndEmpties(source: source, container: container, result: source, warning: warning)

        let vargetters = groupedResources.uniques.map { $0.generateVarGetter() }
        let otherIdentifiers = groupedResources.uniques.map { SwiftIdentifier(name: $0.name) }

        let mergedNamespaces = AssetCatalogMergedNamespaces(all: subnamespaces, otherIdentifiers: otherIdentifiers)
        mergedNamespaces.printWarningsForDuplicates(result: resourceName, warning: warning)

        let structs = mergedNamespaces.namespaces
            .sorted { $0.key < $1.key }
            .map { (name, namespace) in
                namespace.generateStruct(
                    resourceName: name.value,
                    source: source,
                    path: path + [name.value],
                    resourcesSelector: resourcesSelector,
                    prefix: qualifiedName
                )
            }
            .filter { !$0.isEmpty }

        let comment = [
            "This `\(qualifiedName.value)` struct is generated, and contains static references to \(vargetters.count) \(resourceName)s",
            structs.isEmpty ? "" : ", and \(structs.count) namespaces",
            "."
        ].joined()

        let comments = [comment]
        return Struct(comments: comments, name: structName) {
            Init.bundle
            vargetters
            structs

            for s in structs {
                s.generateBundleVarGetter(name: s.name.value)
                s.generateBundleFunction(name: s.name.value)
            }
        }
    }
}

extension ColorResource: AssetCatalogContent {
    public func generateVarGetter() -> VarGetter {
        let fullname = (path + [name]).joined(separator: "/")
        let code = ".init(name: \"\(fullname.escapedStringLiteral)\", path: \(path), bundle: _bundle)"
        return VarGetter(
            comments: ["Color `\(fullname)`."],
            name: SwiftIdentifier(name: name),
            typeReference: TypeReference(module: .host, rawName: "ColorResource"),
            valueCodeString: code
        )
    }
}

extension DataResource: AssetCatalogContent {
    public func generateVarGetter() -> VarGetter {
        let fullname = (path + [name]).joined(separator: "/")
        let odrt = onDemandResourceTags?.debugDescription ?? "nil"
        let code = ".init(name: \"\(fullname.escapedStringLiteral)\", path: \(path), bundle: _bundle, onDemandResourceTags: \(odrt))"
        return VarGetter(
            comments: ["Data asset `\(fullname)`."],
            name: SwiftIdentifier(name: name),
            typeReference: TypeReference(module: .host, rawName: "DataResource"),
            valueCodeString: code
        )
    }
}

extension ImageResource: AssetCatalogContent {
    public func generateVarGetter() -> VarGetter {
        let locs = locale.map { $0.codeString() } ?? "nil"
        let odrt = onDemandResourceTags?.debugDescription ?? "nil"
        let fullname = (path + [name]).joined(separator: "/")
        let code = ".init(name: \"\(fullname.escapedStringLiteral)\", path: \(path), bundle: _bundle, locale: \(locs), onDemandResourceTags: \(odrt))"
        return VarGetter(
            comments: ["Image `\(fullname)`."],
            name: SwiftIdentifier(name: name),
            typeReference: TypeReference(module: .host, rawName: "ImageResource"),
            valueCodeString: code
        )
    }
}
