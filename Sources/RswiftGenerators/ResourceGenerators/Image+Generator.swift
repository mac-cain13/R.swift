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
        let code = "ImageResource(name: \"\(name)\", locale: \(locs), onDemandResourceTags: \(String(describing: onDemandResourceTags)))"
        return LetBinding(
            comments: ["Image `\(name)`."],
            isStatic: true,
            name: SwiftIdentifier(name: name),
            valueCodeString: code)
    }

    public static func generateStruct(resources: [ImageResource], assetCatalogs: [AssetCatalog], prefix: SwiftIdentifier) -> Struct {
        let structName = SwiftIdentifier(name: "image")
        let qualifiedName = prefix + structName

        // Multiple resources can share same name,
        // for example: Colors.jpg and Colors@2x.jpg are both named "Colors.jpg"
        // Deduplicate these
        let namedResources = Dictionary(grouping: resources, by: \.name).values.map(\.first!)
        let assetFolderImageResources = assetCatalogs.flatMap(\.root.images)

        let allResources = namedResources + assetFolderImageResources
        let groupedResources = allResources.grouped(bySwiftIdentifier: { $0.name })

        groupedResources.reportWarningsForDuplicatesAndEmpties(source: "image", result: "image") { l in
            print("warning:", l)
        }

        let imageLets = groupedResources.uniques.map { $0.generateLetBinding() }

        let comments = ["This `\(qualifiedName.value)` struct is generated, and contains static references to \(imageLets.count) images."]
        return Struct(comments: comments, name: structName) {
            imageLets
        }
    }
}
