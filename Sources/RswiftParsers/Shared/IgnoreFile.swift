//
//  IgnoreFile.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 01-10-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

public class IgnoreFile {
    public let ignoredURLs: [URL]
    public let explicitlyIncludedURLs: [URL]

    public init() {
        ignoredURLs = []
        explicitlyIncludedURLs = []
    }

    public init(ignoreFileURL: URL) throws {
        let workingDirectory = ignoreFileURL.deletingLastPathComponent()
        let potentialPatterns = try String(contentsOf: ignoreFileURL).components(separatedBy: .newlines)

        ignoredURLs = potentialPatterns
            .filter { IgnoreFile.isPattern(potentialPattern: $0) && !IgnoreFile.isExplicitlyIncludedPattern(potentialPattern: $0) }
            .flatMap { IgnoreFile.expandPattern($0, workingDirectory: workingDirectory) }
        explicitlyIncludedURLs = potentialPatterns
            .filter { IgnoreFile.isPattern(potentialPattern: $0) && IgnoreFile.isExplicitlyIncludedPattern(potentialPattern: $0) }
            .map { String($0.dropFirst()) }
            .flatMap { IgnoreFile.expandPattern($0, workingDirectory: workingDirectory) }
    }

    public func matches(url: URL) -> Bool {
        return ignoredURLs.contains(url) && !explicitlyIncludedURLs.contains(url)
    }

    static private func isPattern(potentialPattern: String) -> Bool {
        // Check for empty line
        if potentialPattern.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return false }

        // Check for commented line
        if potentialPattern.trimmingCharacters(in: .whitespacesAndNewlines).first == "#" { return false }

        return true
    }

    static private func isExplicitlyIncludedPattern(potentialPattern: String) -> Bool {
        // Check for explicitly included line
        guard potentialPattern.trimmingCharacters(in: .whitespacesAndNewlines).first == "!" else { return false }

        return true
    }

    static private func expandPattern(_ pattern: String, workingDirectory: URL) -> [URL] {
        let globPattern = workingDirectory.path + "/" + pattern // This is a glob pattern, so we don't use URL here
        let filePaths = IgnoreFile.listFilePaths(pattern: globPattern)
        let urls = filePaths.map { URL(fileURLWithPath: $0).standardizedFileURL }

        return urls
    }

    static private func listFilePaths(pattern: String) -> [String] {
        guard !pattern.isEmpty else {
            return []
        }

        return Glob(pattern: pattern).paths
    }
}
