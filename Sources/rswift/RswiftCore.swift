//
//  RswiftCore.swift
//  rswift
//
//  Created by Tom Lokhorst on 2021-04-16.
//

import Foundation
import ArgumentParser
import XcodeEdit
import RswiftParsers
import RswiftResources
import RswiftGenerators

extension ResourceType: ExpressibleByArgument {}

public enum AccessLevel: String, ExpressibleByArgument {
    case publicLevel = "public"
    case internalLevel = "internal"
    case filePrivate = "fileprivate"
    case privateLevel = "private"
}

public enum BundleSource: String, ExpressibleByArgument {
    case module
    case finder
}

public struct RswiftCore {
    let outputURL: URL
    let generators: [ResourceType]
    let accessLevel: AccessLevel
    let bundleSource: BundleSource
    let importModules: [String]
    let productModuleName: String?
    let infoPlistFile: URL?
    let codeSignEntitlements: URL?
    let omitMainLet: Bool

    let sourceTreeURLs: SourceTreeURLs

    let rswiftIgnoreURL: URL

    public init(
        outputURL: URL,
        generators: [ResourceType],
        accessLevel: AccessLevel,
        bundleSource: BundleSource,
        importModules: [String],
        productModuleName: String?,
        infoPlistFile: URL?,
        codeSignEntitlements: URL?,
        omitMainLet: Bool,
        rswiftIgnoreURL: URL,
        sourceTreeURLs: SourceTreeURLs
    ) {
        self.outputURL = outputURL
        self.generators = generators
        self.accessLevel = accessLevel
        self.bundleSource = bundleSource
        self.importModules = importModules
        self.productModuleName = productModuleName
        self.infoPlistFile = infoPlistFile
        self.codeSignEntitlements = codeSignEntitlements
        self.omitMainLet = omitMainLet

        self.rswiftIgnoreURL = rswiftIgnoreURL

        self.sourceTreeURLs = sourceTreeURLs
    }

    public func generateFromXcodeproj(url xcodeprojURL: URL, targetName: String) throws {
        let warning: (String) -> Void = { print("warning: [R.swift]", $0) }

        let xcodeproj = try Xcodeproj(url: xcodeprojURL, warning: warning)
        let resources = try ProjectResources.parseXcodeproj(
            xcodeproj: xcodeproj,
            targetName: targetName,
            rswiftIgnoreURL: rswiftIgnoreURL,
            infoPlistFile: infoPlistFile,
            codeSignEntitlements: codeSignEntitlements,
            sourceTreeURLs: sourceTreeURLs,
            parseFontsAsFiles: true,
            parseImagesAsFiles: true,
            resourceTypes: generators,
            warning: warning
        )

        try generateFromProjectResources(resources: resources, developmentRegion: xcodeproj.developmentRegion, knownAssetTags: xcodeproj.knownAssetTags)
    }

    public func generateFromFiles(inputFileURLs urls: [URL]) throws {
        let warning: (String) -> Void = { print("warning: [R.swift]", $0) }

        let resources = try ProjectResources.parseURLs(
            urls: urls,
            infoPlists: [],
            codeSignEntitlements: [],
            parseFontsAsFiles: true,
            parseImagesAsFiles: true,
            resourceTypes: generators,
            warning: warning
        )

        try generateFromProjectResources(resources: resources, developmentRegion: nil, knownAssetTags: nil)
    }

    private func generateFromProjectResources(resources: ProjectResources, developmentRegion: String?, knownAssetTags: [String]?) throws {
        let structName = SwiftIdentifier(rawValue: "_R")
        let qualifiedName = structName

        let segueStruct = Segue.generateStruct(
            storyboards: resources.storyboards,
            prefix: qualifiedName
        )

        let imageStruct = ImageResource.generateStruct(
            catalogs: resources.assetCatalogs,
            toplevel: resources.images,
            prefix: qualifiedName
        )
        let colorStruct = ColorResource.generateStruct(
            catalogs: resources.assetCatalogs,
            prefix: qualifiedName
        )
        let dataStruct = DataResource.generateStruct(
            catalogs: resources.assetCatalogs,
            prefix: qualifiedName
        )

        let fileStruct = FileResource.generateStruct(
            resources: resources.files,
            prefix: qualifiedName
        )

        let idStruct = AccessibilityIdentifier.generateStruct(
            nibs: resources.nibs,
            storyboards: resources.storyboards,
            prefix: qualifiedName
        )

        let fontStruct = FontResource.generateStruct(
            resources: resources.fonts,
            prefix: qualifiedName
        )

        let storyboardStruct = StoryboardResource.generateStruct(
            storyboards: resources.storyboards,
            prefix: qualifiedName
        )

        let infoStruct = PropertyListResource.generateInfoStruct(
            resourceName: "info",
            plists: resources.infoPlists,
            prefix: qualifiedName
        )

        let entitlementsStruct = PropertyListResource.generateStruct(
            resourceName: "entitlements",
            plists: resources.codeSignEntitlements,
            prefix: qualifiedName
        )

        let nibStruct = NibResource.generateStruct(
            nibs: resources.nibs,
            prefix: qualifiedName
        )

        let reuseIdentifierStruct = Reusable.generateStruct(
            nibs: resources.nibs,
            storyboards: resources.storyboards,
            prefix: qualifiedName
        )

        let stringStruct = StringsTable.generateStruct(
            tables: resources.strings,
            developmentLanguage: developmentRegion,
            prefix: qualifiedName
        )

        let projectStruct = XcodeProjectGenerator.generateProject(developmentRegion: developmentRegion, knownAssetTags: knownAssetTags)

        let generateFont = generators.contains(.font) && !fontStruct.isEmpty
        let generateNib = generators.contains(.nib) && !nibStruct.isEmpty
        let generateStoryboard = generators.contains(.storyboard) && !storyboardStruct.isEmpty

        let validateLines = [
            generateFont ? "try self.font.validate()" : "",
            generateNib ? "try self.nib.validate()" : "",
            generateStoryboard ? "try self.storyboard.validate()" : "",
        ]
            .filter { $0 != "" }
            .joined(separator: "\n")

        let validate = Function(
            comments: [],
            name: SwiftIdentifier(name: "validate"),
            params: [],
            returnThrows: true,
            returnType: .init(module: .stdLib, rawName: "Void"),
            valueCodeString: validateLines
        )

        var s = Struct(name: structName, additionalModuleReferences: [.rswiftResources]) {
            Init.bundle

            if generators.contains(.project), !projectStruct.isEmpty {
                projectStruct
            }

            if generators.contains(.string), !stringStruct.isEmpty {
                stringStruct.generateBundleVarGetterForString()
                stringStruct.generateBundleFunctionForString(name: "string")
                stringStruct.generateLocaleFunctionForString(name: "string")
                stringStruct.generatePreferredLanguagesFunctionForString(name: "string")
                stringStruct
            }

            if generators.contains(.data), !dataStruct.isEmpty {
                dataStruct.generateBundleVarGetter(name: "data")
                dataStruct.generateBundleFunction(name: "data")
                dataStruct
            }

            if generators.contains(.color), !colorStruct.isEmpty {
                colorStruct.generateBundleVarGetter(name: "color")
                colorStruct.generateBundleFunction(name: "color")
                colorStruct
            }

            if generators.contains(.image), !imageStruct.isEmpty {
                imageStruct.generateBundleVarGetter(name: "image")
                imageStruct.generateBundleFunction(name: "image")
                imageStruct
            }

            if generators.contains(.info), !infoStruct.isEmpty {
                infoStruct.generateBundleVarGetter(name: "info")
                infoStruct.generateBundleFunction(name: "info")
                infoStruct
            }

            if generators.contains(.entitlements), !entitlementsStruct.isEmpty {
                entitlementsStruct.generateVarGetter()
                entitlementsStruct
            }

            if generateFont {
                fontStruct.generateBundleVarGetter(name: "font")
                fontStruct.generateBundleFunction(name: "font")
                fontStruct
            }

            if generators.contains(.file), !fileStruct.isEmpty {
                fileStruct.generateBundleVarGetter(name: "file")
                fileStruct.generateBundleFunction(name: "file")
                fileStruct
            }

            if generators.contains(.segue), !segueStruct.isEmpty {
                segueStruct.generateVarGetter()
                segueStruct
            }

            if generators.contains(.id), !idStruct.isEmpty {
                idStruct.generateVarGetter()
                idStruct
            }

            if generateNib {
                nibStruct.generateBundleVarGetter(name: "nib")
                nibStruct.generateBundleFunction(name: "nib")
                nibStruct
            }

            if generators.contains(.reuseIdentifier), !reuseIdentifierStruct.isEmpty {
                reuseIdentifierStruct.generateVarGetter()
                reuseIdentifierStruct
            }

            if generateStoryboard {
                storyboardStruct.generateBundleVarGetter(name: "storyboard")
                storyboardStruct.generateBundleFunction(name: "storyboard")
                storyboardStruct
            }

            validate
        }

        if accessLevel == .publicLevel {
            s.setAccessControl(.public)
        }

        let imports = Set(s.allModuleReferences.compactMap(\.name))
            .union(importModules)
            .subtracting([productModuleName].compactMap { $0 })
            .sorted()
            .map { "import \($0)" }
            .joined(separator: "\n")

        let mainLet: String
        switch bundleSource {
        case .module:
            mainLet = "\(accessLevel == .publicLevel ? "public " : "")let R = _R(bundle: Bundle.module)"
        case .finder:
            mainLet = """
            private class BundleFinder {}
            \(accessLevel == .publicLevel ? "public " : "")let R = _R(bundle: Bundle(for: BundleFinder.self))
            """
        }

        let body = s.prettyPrint()

        let header = """
        //
        // This is a generated file, do not edit!
        // Generated by R.swift, see https://github.com/mac-cain13/R.swift
        //
        """

        let parts = [header, imports, omitMainLet ? nil : mainLet, body].compactMap { $0 }
        let code = parts.joined(separator: "\n\n")

        try writeIfChanged(contents: code, toURL: outputURL)
    }
}

private func writeIfChanged(contents: String, toURL outputURL: URL) throws {
    let currentFileContents = try? String(contentsOf: outputURL, encoding: .utf8)
    guard currentFileContents != contents else { return }
    try contents.write(to: outputURL, atomically: false, encoding: .utf8)
}
