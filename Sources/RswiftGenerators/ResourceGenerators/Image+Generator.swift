//
//  ImageResource+Generator.swift
//  
//
//  Created by Tom Lokhorst on 2022-06-24.
//

import Foundation
import RswiftResources

extension LocaleReference {
    func codeString() -> String {
        switch self {
        case .none:
            return ".none"
        case .base:
            return ".base"
        case .language(let string):
            return ".language(\(string))"
        }
    }
}

extension ImageResource {
    func generateLetBinding() -> LetBinding {
        let locs = locale.map { $0.codeString() } ?? "nil"
        let odrt = onDemandResourceTags?.debugDescription ?? "nil"
        let code = "ImageResource(name: \"\(name)\", locale: \(locs), onDemandResourceTags: \(odrt))"
        return LetBinding(
            comments: ["Image `\(name)`."],
            isStatic: true,
            name: SwiftIdentifier(name: name),
            valueCodeString: code)
    }

    public static func generateStruct(resources: [ImageResource], namespaces: [AssetCatalog.Namespace], name: SwiftIdentifier, prefix: SwiftIdentifier) -> Struct {
        let structName = name
        let qualifiedName = prefix + structName

        // Multiple resources can share same name,
        // for example: Colors.jpg and Colors@2x.jpg are both named "Colors.jpg"
        // Deduplicate these
        let namedResources = Dictionary(grouping: resources, by: \.name).values.map(\.first!)

        let assetFolderImageResources = namespaces.flatMap(\.images)

        let allResources = namedResources + assetFolderImageResources
        let groupedResources = allResources.grouped(bySwiftIdentifier: { $0.name })

        groupedResources.reportWarningsForDuplicatesAndEmpties(source: "image", result: "image") { l in
            print("warning:", l)
        }

        let letbindings = groupedResources.uniques.map { $0.generateLetBinding() }

        let allNamespaces = namespaces.flatMap(\.subnamespaces)
        let assetSubfolders = AssetCatalogSubfolders(
          all: allNamespaces,
          assetIdentifiers: allResources.map { SwiftIdentifier(name: $0.name) })

        assetSubfolders.printWarningsForDuplicates { l in
            print("warning:", l)
        }

        let structs = assetSubfolders.folders.flatMap(\.subnamespaces)
            .sorted { $0.name < $1.name }
            .map { namespace in
                ImageResource.generateStruct(
                    resources: [],
                    namespaces: [namespace],
                    name: SwiftIdentifier(name: namespace.name),
                    prefix: qualifiedName
                )
            }
            .filter { !$0.isEmpty }

        let comments = ["This `\(qualifiedName.value)` struct is generated, and contains static references to \(letbindings.count) images."]
        return Struct(comments: comments, name: structName) {
            letbindings
            structs
        }
    }
}
