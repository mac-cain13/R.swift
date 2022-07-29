//
//  RswiftCore.swift
//  rswift
//
//  Created by Tom Lokhorst on 2021-04-16.
//

import Foundation
import XcodeEdit
import RswiftParsers
import RswiftResources
import RswiftGenerators

public struct RswiftCore {
    let xcodeprojURL: URL
    let targetName: String
    let productModuleName: String?
    let infoPlistFile: URL?
    let codeSignEntitlements: URL?

    let sourceTreeURLs: SourceTreeURLs

    let rswiftIgnoreURL: URL

    public init(
        xcodeprojURL: URL,
        targetName: String,
        productModuleName: String?,
        infoPlistFile: URL?,
        codeSignEntitlements: URL?,
        rswiftIgnoreURL: URL,
        sourceTreeURLs: SourceTreeURLs
    ) {
        self.xcodeprojURL = xcodeprojURL
        self.targetName = targetName
        self.productModuleName = productModuleName
        self.infoPlistFile = infoPlistFile
        self.codeSignEntitlements = codeSignEntitlements

        self.rswiftIgnoreURL = rswiftIgnoreURL

        self.sourceTreeURLs = sourceTreeURLs
    }

    // Temporary function for use during development
    public func developRun() throws {
        let start = Date()

        let project = try Project.parseTarget(
            name: targetName,
            xcodeprojURL: xcodeprojURL,
            rswiftIgnoreURL: rswiftIgnoreURL,
            infoPlistFile: infoPlistFile,
            codeSignEntitlements: codeSignEntitlements,
            sourceTreeURLs: sourceTreeURLs,
            warning: { print("[warning]", $0) }
        )

        let structName = SwiftIdentifier(rawValue: "R")
        let qualifiedName = structName

//        let segueStruct = Segue.generateStruct(storyboards: storyboards, prefix: qualifiedName)

//        let imageStruct = ImageResource.generateStruct(
//            catalogs: assetCatalogs,
//            toplevel: images,
//            prefix: qualifiedName
//        )
//        let colorStruct = ColorResource.generateStruct(
//            catalogs: assetCatalogs,
//            prefix: qualifiedName
//        )
//        let dataStruct = DataResource.generateStruct(
//            catalogs: assetCatalogs,
//            prefix: qualifiedName
//        )

//        let fileStruct = FileResource.generateStruct(
//            resources: files,
//            prefix: qualifiedName
//        )

//        let idStruct = AccessibilityIdentifier.generateStruct(
//            nibs: nibs,
//            storyboards: storyboards,
//            prefix: qualifiedName
//        )

//        let fontStruct = FontResource.generateStruct(
//            resources: fonts,
//            prefix: qualifiedName
//        )

//        let storyboardStruct = StoryboardResource.generateStruct(
//            storyboards: storyboards,
//            prefix: qualifiedName
//        )

//        let infoStruct = PropertyListResource.generateStruct(
//            resourceName: "info",
//            plists: [plist],
//            toplevelKeysWhitelist: infoPlistWhitelist,
//            prefix: qualifiedName
//        )

//        let entitlementsStruct = PropertyListResource.generateStruct(
//            resourceName: "entitlements",
//            plists: [entitlements],
//            toplevelKeysWhitelist: nil,
//            prefix: qualifiedName
//        )

//        let reuseIdentifierStruct = Reusable.generateStruct(
//            nibs: nibs,
//            storyboards: storyboards,
//            prefix: qualifiedName
//        )

//        let nibStruct = NibResource.generateStruct(
//            nibs: nibs,
//            prefix: qualifiedName
//        )

        let stringStruct = LocalizableStrings.generateStruct(
            resources: project.localizableStrings,
            developmentLanguage: project.xcodeproj.developmentRegion,
            prefix: qualifiedName
        )

        let projectStruct = Struct(name: SwiftIdentifier(name: "project")) {
            LetBinding(name: SwiftIdentifier(name: "developmentRegion"), valueCodeString: #""\#(project.xcodeproj.developmentRegion)""#)

            if let knownAssetTags = project.xcodeproj.knownAssetTags {
                LetBinding(name: SwiftIdentifier(name: "knownAssetTags"), valueCodeString: "\(knownAssetTags)")
            }
        }

        let s = Struct(name: structName) {
            projectStruct
            stringStruct
        }

        print(s.prettyPrint())

        print("TOTAL", Date().timeIntervalSince(start))
        print()
    }
}
