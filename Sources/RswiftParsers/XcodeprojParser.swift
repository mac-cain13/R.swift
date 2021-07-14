//
//  Xcodeproj.swift
//  RswiftCore
//
//  Created by Mathijs Kadijk on 09-12-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation
import RswiftResources
import XcodeEdit

public struct XcodeprojParser: ResourceParser {
    public let supportedExtensions: Set<String> = ["xcodeproj"]

    public init() {}
    
    public func parse(url: URL) throws -> Xcodeproj {
        try throwIfUnsupportedExtension(url)
        let projectFile: XCProjectFile

        // Parse project file
        do {
            do {
                projectFile = try XCProjectFile(xcodeprojURL: url, ignoreReferenceErrors: false)
            }
            catch let error as ProjectFileError {
                print("WARNING: Non-fatal xcodeproj parsing error:")
                print(error)

                projectFile = try XCProjectFile(xcodeprojURL: url, ignoreReferenceErrors: true)
            }
        }
        catch {
            throw ResourceParsingError("Project file at '\(url)' could not be parsed, is this a valid Xcode project file ending in *.xcodeproj?\n\(error.localizedDescription)")
        }

        return Xcodeproj(projectFile: projectFile)
    }

}
