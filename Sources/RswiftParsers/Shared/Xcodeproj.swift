//
//  Xcodeproj.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 09-12-15.
//  From: https://github.com/mac-cain13/R.swift
//

import Foundation
import XcodeEdit
import RswiftResources

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

    // Returns extra resource URLs by extracting fileSystemSynchronizedGroups and scanning file system recursively.
    // Handles exceptions configured in fileSystemSynchronizedGroups
    func extraResourceURLs(forTarget targetName: String, sourceTreeURLs: SourceTreeURLs) throws -> [URL] {
        var resultURLs: [URL] = []

        let (dirs, extraFiles, extraLocalizedFiles, exceptionPaths) = try fileSystemSynchronizedGroups(forTarget: targetName)

        for dir in dirs {
            let url = dir.url(with: sourceTreeURLs.url(for:))
            resultURLs.append(contentsOf: recursiveContentsOf(url: url))
        }

        let extraURLs = extraFiles.map { $0.url(with: sourceTreeURLs.url(for:)) }
        resultURLs.append(contentsOf: extraURLs)

        let extraLocalizedURLs = try extraLocalizedFiles
            .map { $0.url(with: sourceTreeURLs.url(for:)) }
            .flatMap { try expandLocalizedFileURL($0) }
        resultURLs.append(contentsOf: extraLocalizedURLs)

        let exceptionURLs = exceptionPaths.map { $0.url(with: sourceTreeURLs.url(for:)) }
        resultURLs.removeAll(where: { exceptionURLs.contains($0) })

        let xcodeFilenames = ["Info.plist"]
        resultURLs.removeAll(where: { xcodeFilenames.contains($0.lastPathComponent) })

        return resultURLs
    }

    // For target, extract file system groups.
    // Returns:
    //   - directories to scan
    //   - known files (based on exceptions of other targets)
    //   - known files that are localized (inside .lproj directory) (based on exceptions of other targets)
    //   - known exception files (based on exceptions of this target)
    func fileSystemSynchronizedGroups(forTarget targetName: String) throws -> (dirs: [Path], extraFiles: [Path], extraLocalizedFiles: [Path], exceptionPaths: [Path]) {
        var dirs: [Path] = []
        var extraFiles: [Path] = []
        var extraLocalizedFiles: [Path] = []
        var exceptionPaths: [Path] = []

        let target = try findTarget(name: targetName)

        guard let mainGroup = projectFile.project.mainGroup.value else {
            throw ResourceParsingError("Project file is missing mainGroup")
        }

        let targetFileSystemSynchronizedGroups = target.fileSystemSynchronizedGroups?.compactMap(\.value?.id) ?? []

        let allFileSystemSynchronizedGroups = mainGroup.fileSystemSynchronizedGroups()

        for synchronizedGroup in allFileSystemSynchronizedGroups {
            guard let path = synchronizedGroup.fullPath else { continue }

            let exceptions = (synchronizedGroup.exceptions ?? []).compactMap(\.value)

            if targetFileSystemSynchronizedGroups.contains(synchronizedGroup.id) {
                dirs.append(path)

                for exception in exceptions {
                    guard exception.target.id == target.id else { continue }

                    let files = exception.membershipExceptions ?? []
                    let exPaths = files.map { file in path.map { dir in "\(dir)/\(file)" } }

                    exceptionPaths.append(contentsOf: exPaths)
                }
            } else {
                for exception in exceptions {
                    guard exception.target.id == target.id else { continue }

                    let files = exception.membershipExceptions ?? []

                    // Xcode 16 project format uses "/Localized: ", earlier Xcode versions use "/Localized/"
                    let localizeds = ["/Localized: ", "/Localized"]
                    for file in files {
                        if let localized = localizeds.first(where: { file.hasPrefix($0) }) {
                            let cleanFile = String(file.dropFirst(localized.count))
                            let exPath = path.map { dir in "\(dir)/\(cleanFile)" }
                            extraLocalizedFiles.append(exPath)
                        } else {
                            let exPath = path.map { dir in "\(dir)/\(file)" }
                            extraFiles.append(exPath)
                        }
                    }
                }
            }
        }

        return (dirs: dirs, extraFiles: extraFiles, extraLocalizedFiles: extraLocalizedFiles, exceptionPaths: exceptionPaths)
    }

    public func buildConfigurations(forTarget targetName: String) throws -> [XCBuildConfiguration] {
        let target = try findTarget(name: targetName)

        guard let buildConfigurationList = target.buildConfigurationList.value else { return [] }

        let buildConfigurations = buildConfigurationList.buildConfigurations
            .compactMap { $0.value }

        return buildConfigurations
    }
}

extension PBXReference {
    func fileSystemSynchronizedGroups() -> [PBXFileSystemSynchronizedRootGroup] {
        if let root = self as? PBXFileSystemSynchronizedRootGroup {
            return [root]
        } else if let group = self as? PBXGroup {
            let children = group.children.compactMap(\.value)

            return children.flatMap { $0.fileSystemSynchronizedGroups() }
        } else {
            return []
        }
    }
}

extension Path {
    func map(_ transform: (String) -> String) -> Path {
        switch self {
        case let .absolute(str):
            return .absolute(transform(str))
        case let .relativeTo(folder, str):
            return .relativeTo(folder, transform(str))
        }
    }
}

// Returns all(*) recursive files/directories that that are found on file system in specified directory.
// (*): xcassets are returned once, no deeper contents.
private func recursiveContentsOf(url: URL) -> [URL] {
    var resultURLs: [URL] = []

    var excludedExtensions = AssetCatalog.supportedExtensions
    excludedExtensions.insert("bundle")

    if excludedExtensions.contains(url.pathExtension) {
        return []
    }

    let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles])

    // Enumerator gives directories in hierarchical order (I assume/hope).
    // If we hit a directory that is an .xcassets, we don't want to scan deeper, so we add it to the skipDirectories.
    // Subsequent files/directories that have a skipDirectory as prefix are ignored.
    var skipDirectories: [URL] = []

    guard let enumerator else { return [] }

    for case let contentURL as URL in enumerator {
        let shouldSkip = skipDirectories.contains { skip in contentURL.path.hasPrefix(skip.path) }
        if shouldSkip {
            continue
        }

        if excludedExtensions.contains(contentURL.pathExtension) {
            resultURLs.append(contentURL)
            skipDirectories.append(contentURL)
            continue
        }

        if contentURL.hasDirectoryPath {
            if excludedExtensions.contains(contentURL.pathExtension) {
                resultURLs.append(contentURL)
                skipDirectories.append(contentURL)
            }
        } else {
            resultURLs.append(contentURL)
        }
    }

    return resultURLs
}

// Returns the localized versions of an input URL
// Example: some-dir/Home.strings
// Becomes: some-dir/Base.lproj/Home.strings, some-dir/nl.lproj/Home.strings
private func expandLocalizedFileURL(_ url: URL) throws -> [URL] {
    let fileManager = FileManager.default
    var localizedURLs: [URL] = []

    // Get the directory path and filename from the input URL
    let directory = url.deletingLastPathComponent()
    let filename = url.lastPathComponent

    // Scan the directory for contents
    let contents = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)

    // Filter the contents to find directories with the ".lproj" suffix
    for item in contents {
        if item.pathExtension == "lproj" {
            // Construct the localized file path by appending the filename to the `.lproj` folder path
            let localizedFileURL = item.appendingPathComponent(filename)

            // Check if the localized file exists
            if fileManager.fileExists(atPath: localizedFileURL.path) {
                localizedURLs.append(localizedFileURL)
            }
        }
    }

    return localizedURLs
}
