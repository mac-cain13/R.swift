//
//  File.swift
//  
//
//  Created by Mathijs on 14/07/2021.
//

import Foundation
import XcodeEdit

public struct Xcodeproj {
    private let projectFile: XCProjectFile

    let developmentLanguage: String

    public init(projectFile: XCProjectFile) {
        self.projectFile = projectFile
        self.developmentLanguage = projectFile.project.developmentRegion
    }

    private func findTarget(name: String) throws -> PBXTarget {
        // Look for target in project file
        let allTargets = self.targets()
        guard let target = allTargets.filter({ $0.name == name }).first else {
            let availableTargets = allTargets.compactMap { $0.name }.joined(separator: ", ")
            throw XcodeprojError(errorDescription: "Target '\(name)' not found in project file, available targets are: \(availableTargets)")
        }

        return target
    }

    public func targets() -> [PBXTarget] {
        projectFile.project.targets.compactMap { $0.value }
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

public struct XcodeprojError: LocalizedError {
    public var errorDescription: String?
}
