//
//  RswiftCore.swift
//  rswift
//
//  Created by Tom Lokhorst on 2021-04-16.
//

import Foundation
import XcodeEdit
import RswiftGenerators
import RswiftParsers
import RswiftResources

public struct RswiftCore {
    
    // Tempoary function for use during development
    func developGetFiles(xcodeprojURL: URL, targetName: String) throws -> [String] {
        let xcodeproj = try Xcodeproj(url: xcodeprojURL, warning: { print($0) })
        return try xcodeproj.resourcePaths(forTarget: targetName).map { "\($0)" }
    }
    
    static public func developRun(
        projectPath: String,
        targetName: String
    ) throws {
        let xcodeprojURL = URL(fileURLWithPath: projectPath)
        
        let xcodeproj = try Xcodeproj(url: xcodeprojURL, warning: { error in
            print(error.localizedDescription)
        })
        let paths = try xcodeproj.resourcePaths(forTarget: targetName)
        let urls = paths
            .map { $0.url(with: urlForSourceTreeFolder) }
        let fonts = try urls
            .filter { Font.supportedExtensions.contains($0.pathExtension) }
            .map { try Font.parse(url: $0) }
        
        for font in fonts {
            print(try font.generateResourceLet())
        }
        print()
    }
    
    static func urlForSourceTreeFolder(_ sourceTreeFolder: SourceTreeFolder) -> URL {
        switch sourceTreeFolder {
        case .buildProductsDir:
            return URL(fileURLWithPath: "/Users/tom/Projects/R.swift/Examples/ResourceApp")
        case .developerDir:
            return URL(fileURLWithPath: "/Users/tom/Projects/R.swift/Examples/ResourceApp")
        case .sdkRoot:
            return URL(fileURLWithPath: "/Users/tom/Projects/R.swift/Examples/ResourceApp")
        case .sourceRoot:
//            return projectPath.deletingLastPathComponent()
            return URL(fileURLWithPath: "/Users/tom/Projects/R.swift/Examples/ResourceApp")
        case .platformDir:
            return URL(fileURLWithPath: "/Users/tom/Projects/R.swift/Examples/ResourceApp")
        }
    }
}
