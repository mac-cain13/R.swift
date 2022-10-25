//
//  Plugin.swift
//  
//
//  Created by Tom Lokhorst on 2022-10-19.
//

import Foundation
import PackagePlugin

@main
struct RswiftGenerateResources: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
        guard let target = target as? SourceModuleTarget else { return [] }

        let resourcesDirectoryPath = context.pluginWorkDirectory
            .appending(subpath: target.name)
            .appending(subpath: "Resources")

        try FileManager.default.createDirectory(atPath: resourcesDirectoryPath.string, withIntermediateDirectories: true)

        let rswiftPath = resourcesDirectoryPath.appending(subpath: "R.generated.swift")

        let sourceFiles = target.sourceFiles
            .filter { $0.type == .resource || $0.type == .unknown }
            .map(\.path.string)

        let inputFilesArguments = sourceFiles
            .flatMap { ["--input-files", $0 ] }

//        let rswift = try context.tool(named: "rswift")
        return [
            .buildCommand(
                displayName: "R.swift generate resources",
                executable: Path("/Users/tom/Projects/R.swift/.build/debug/rswift"),
                arguments: [
                    "generate", rswiftPath.string,
                    "--input-type", "input-files",
                    "--bundle-source", "module",
                ] + inputFilesArguments,
                outputFiles: [rswiftPath]
            ),
        ]
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension RswiftGenerateResources: XcodeBuildToolPlugin {
    func createBuildCommands(context: XcodePluginContext, target: XcodeTarget) throws -> [Command] {

        let resourcesDirectoryPath = context.pluginWorkDirectory
            .appending(subpath: target.displayName)
            .appending(subpath: "Resources")

        try FileManager.default.createDirectory(atPath: resourcesDirectoryPath.string, withIntermediateDirectories: true)

        let rswiftPath = resourcesDirectoryPath.appending(subpath: "R.generated.swift")

        return [
            .buildCommand(
                displayName: "R.swift generate resources",
                executable: Path("/Users/tom/Projects/R.swift/.build/debug/rswift"),
                arguments: [
                    "generate", rswiftPath.string,
                    "--target", target.displayName,
                    "--input-type", "xcodeproj",
                    "--bundle-source", "finder",
                ],
                outputFiles: [rswiftPath]
            ),
        ]
    }
}

#endif
