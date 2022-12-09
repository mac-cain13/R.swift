//
//  Xcodeproj.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 09-12-15.
//  From: https://github.com/mac-cain13/R.swift
//

import Foundation
import XcodeEdit

public struct Xcodeproj: SupportedExtensions {
    static public let supportedExtensions: Set<String> = ["xcodeproj"]

    private let projectFile: XCProjectFile

    public let developmentRegion: String
    public let knownAssetTags: [String]?

    public init(url: URL, warning: (String) -> Void) throws {
        try Xcodeproj.throwIfUnsupportedExtension(url)
        let projectFile: XCProjectFile

        // Parse project file
        do {
            do {
                projectFile = try XCProjectFile(xcodeprojURL: url, ignoreReferenceErrors: false)
            }
            catch let error as ProjectFileError {
                warning(error.localizedDescription)

                projectFile = try XCProjectFile(xcodeprojURL: url, ignoreReferenceErrors: true)
            }
        }
        catch {
            throw ResourceParsingError("Project file at '\(url)' could not be parsed, is this a valid Xcode project file ending in *.xcodeproj?\n\(error.localizedDescription)")
        }

        self.projectFile = projectFile
        self.developmentRegion = projectFile.project.developmentRegion
        self.knownAssetTags = projectFile.project.knownAssetTags
    }

    public var allTargets: [PBXTarget] {
        projectFile.project.targets.compactMap { $0.value }
    }

    private func findTarget(name: String) throws -> PBXTarget {
        // Look for target in project file
        let allTargets = projectFile.project.targets.compactMap { $0.value }
        guard let target = allTargets.filter({ $0.name == name }).first else {
            let availableTargets = allTargets.compactMap { $0.name }.joined(separator: ", ")
            throw ResourceParsingError("Target '\(name)' not found in project file, available targets are: \(availableTargets)")
        }

        return target
    }

    public func resourcePaths(forTarget targetName: String) throws -> [Path] {
        let target = try findTarget(name: targetName)

        let resourcesFileRefs = target.buildPhases
            .compactMap { $0.value as? PBXResourcesBuildPhase }
            .flatMap { $0.files }
            .compactMap { $0.value?.fileRef }

        let fileRefPaths = resourcesFileRefs
            .compactMap { $0.value as? PBXFileReference }
            .compactMap { $0.fullPath }

        let variantGroupPaths = resourcesFileRefs
            .compactMap { $0.value as? PBXVariantGroup }
            .flatMap { $0.fileRefs }
            .compactMap { $0.value?.fullPath }

        return fileRefPaths + variantGroupPaths
    }

    public func buildConfigurations(forTarget targetName: String) throws -> [XCBuildConfiguration] {
        let target = try findTarget(name: targetName)

        guard let buildConfigurationList = target.buildConfigurationList.value else { return [] }

        let buildConfigurations = buildConfigurationList.buildConfigurations
            .compactMap { $0.value }

        return buildConfigurations
    }
}
