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
            .map(\.path.string)

        let inputFilesArguments = sourceFiles
            .flatMap { ["--input-files", $0 ] }

        Diagnostics.warning("FILES " + sourceFiles.joined(separator: "}, {"))

//        let rswift = try context.tool(named: "rswift")
        return [
//            .prebuildCommand(
//                displayName: "My display name 1",
//                executable: Path("/Users/tom/Projects/R.swift/.build/debug/rswift"),
//                arguments: ["generate", rswiftPath.string, "--target", target.name] + inputFilesArguments,
////                environment: [:],
//                outputFilesDirectory: resourcesDirectoryPath
//            ),
            .buildCommand(
                displayName: "My display name 1",
                executable: Path("/Users/tom/Projects/R.swift/.build/debug/rswift"),
                arguments: ["generate", rswiftPath.string, "--target", target.name] + inputFilesArguments,
                outputFiles: [rswiftPath]
            ),
        ]
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension RswiftGenerateResources: XcodeBuildToolPlugin {
    func createBuildCommands(context: XcodePluginContext, target: XcodeTarget) throws -> [Command] {
        Diagnostics.error("\(context)")
        let resourcesDirectoryPath = context.pluginWorkDirectory
            .appending(subpath: target.displayName)
            .appending(subpath: "Resources")

        let rswiftPath = resourcesDirectoryPath.appending(subpath: "R.generated.swift")

        Diagnostics.warning("HELLO WORLD " + target.inputFiles.filter { $0.type == .resource }.map(\.path.string).joined(separator: ", "))

        return [
            .prebuildCommand(
                displayName: "My display name 2",
                executable: Path("/Users/tom/Projects/R.swift/.build/debug/rswift"),
                arguments: ["generate", rswiftPath.string, "--target", target.displayName],
                outputFilesDirectory: resourcesDirectoryPath
            )
        ]
    }
}

#endif
