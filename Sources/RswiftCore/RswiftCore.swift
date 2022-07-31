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

        let structName = SwiftIdentifier(rawValue: "_S")
        let qualifiedName = structName

        let segueStruct = Segue.generateStruct(
            storyboards: project.storyboards,
            prefix: qualifiedName
        )

        let imageStruct = ImageResource.generateStruct(
            catalogs: project.assetCatalogs,
            toplevel: project.images,
            prefix: qualifiedName
        )
        let colorStruct = ColorResource.generateStruct(
            catalogs: project.assetCatalogs,
            prefix: qualifiedName
        )
        let dataStruct = DataResource.generateStruct(
            catalogs: project.assetCatalogs,
            prefix: qualifiedName
        )

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

        let storyboardStruct = StoryboardResource.generateStruct(
            storyboards: project.storyboards,
            prefix: qualifiedName
        )

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

//        let stringStruct = LocalizableStrings.generateStruct(
//            resources: project.localizableStrings,
//            developmentLanguage: project.xcodeproj.developmentRegion,
//            prefix: qualifiedName
//        )

        let projectStruct = Struct(name: SwiftIdentifier(name: "project")) {
            LetBinding(name: SwiftIdentifier(name: "developmentRegion"), valueCodeString: #""\#(project.xcodeproj.developmentRegion)""#)

            if let knownAssetTags = project.xcodeproj.knownAssetTags {
                LetBinding(name: SwiftIdentifier(name: "knownAssetTags"), valueCodeString: "\(knownAssetTags)")
            }
        }

        let s = Struct(name: structName) {
            Init.bundle
            projectStruct

            dataStruct.generateBundleVarGetter(name: "data")
            dataStruct.generateBundleFunction(name: "data")
            dataStruct

            colorStruct.generateBundleVarGetter(name: "color")
            colorStruct.generateBundleFunction(name: "color")
            colorStruct

            imageStruct.generateBundleVarGetter(name: "image")
            imageStruct.generateBundleFunction(name: "image")
            imageStruct

            segueStruct.generateLetBinding()
            segueStruct

            storyboardStruct.generateBundleVarGetter(name: "storyboard")
            storyboardStruct.generateBundleFunction(name: "storyboard")
            storyboardStruct
        }

        print(s.prettyPrint())

        print()

        print("let S = _S(bundle: Bundle.main)")
        print("")
        print("extension R {")
//        print("  static let string = S.string")
        print("  static let data = S.data")
        print("  static let color = S.color")
        print("  static let image = S.image")
        print("  static let segue = S.segue")
        print("  static let storyboard = S.storyboard")
        print("}")

        print("TOTAL", Date().timeIntervalSince(start))
        print()
    }
}
