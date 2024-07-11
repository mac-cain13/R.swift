//
//  RswiftGeneratePublicResources.swift
//  
//
//  Created by Tom Lokhorst on 2022-10-19.
//

import Foundation
import PackagePlugin

@main
struct RswiftGeneratePublicResources: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
        guard let target = target as? SourceModuleTarget else { return [] }

        let defaultOutputDirectoryPath = context.pluginWorkDirectory.appending(subpath: target.name)
        let rswiftPath = defaultOutputDirectoryPath.appending(subpath: "R.generated.swift")

        let optionsFile = URL(fileURLWithPath: target.directory.appending(subpath: ".rswiftoptions").string)

        // Our base set of options contains only an access level of `public` given that
        // this is the "public" resources plugin, hence the access level should always be
        // `public`.
        let options = RswiftOptions(accessLevel: .publicLevel)

            // Next we load and merge any options that may be present in an options file. These
            // options don't override any of the previous options provided, but supplements
            // those options.
            .merging(with: try .init(contentsOf: optionsFile))

            // Lastly, we provide a fallback bundle source and output file to ensure that these
            // values are always set should no other values be provided
            .merging(with: .init(bundleSource: target.kind == .generic ? .module : .finder,
                                 outputPath: rswiftPath.string))

        // Get a concrete reference to the file we'll be writing out to
        let outputPath = options.outputPath.map { $0.hasPrefix("/") ? Path($0) : defaultOutputDirectoryPath.appending(subpath: $0) } ?? rswiftPath

        // Create the output directory, if needed
        try FileManager.default.createDirectory(atPath: outputPath.removingLastComponent().string,
                                                withIntermediateDirectories: true)

        // Get the input files for the current target being processed
        let sourceFiles: [String] = target.sourceFiles
            .filter { $0.type == .resource || $0.type == .unknown }
            .map(\.path.string)

        let inputFilesArguments: [String] = sourceFiles
            .flatMap { ["--input-files", $0 ] }

        // Lastly, convert the options struct into an array of arguments, subsequently
        // appending the input type and files, all of which will be provided to the
        // `rswift` utility that we'll invoke.
        let arguments: [String] =
            options.makeArguments(sourceDirectory: URL(fileURLWithPath: target.directory.string),
                                  outputDirectory: URL(fileURLWithPath: outputPath.removingLastComponent().string)) +
            ["--input-type", "input-files"] + inputFilesArguments

        // Return the build command to execute
        return [
            .buildCommand(
                displayName: "R.swift generate resources for \(target.kind) module \(target.name)",
                executable: try context.tool(named: "rswift").path,
                arguments: arguments,
                outputFiles: [outputPath]
            ),
        ]
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension RswiftGeneratePublicResources: XcodeBuildToolPlugin {
    func createBuildCommands(context: XcodePluginContext, target: XcodeTarget) throws -> [Command] {

        let defaultOutputDirectoryPath = context.pluginWorkDirectory
            .appending(subpath: target.displayName)
            .appending(subpath: "Resources")

        let rswiftPath = defaultOutputDirectoryPath.appending(subpath: "R.generated.swift")

        let projectOptionsFile = URL(fileURLWithPath: context.xcodeProject.directory.appending(subpath: ".rswiftoptions").string)
        let targetOptionsFile = URL(fileURLWithPath: context.xcodeProject.directory.appending(subpath: target.displayName).appending(subpath: ".rswiftoptions").string)

        // Our base set of options contains an access level of `public` given that this is
        // the "public" resources plugin, hence the access level should always be `public`,
        // as well as the bundle source, which is always `finder` for Xcode projects.
        let options = RswiftOptions(accessLevel: .publicLevel,
                                    bundleSource: .finder)

            // Next we load and merge any options that may be present in an options file
            // specific to the target being processed. These options don't override any of the
            // previous options provided, but supplements those options.
            .merging(with: try .init(contentsOf: targetOptionsFile))

            // Next we load and merge any options that may be present in an options file that
            // applies to the entire project. These options don't override any of the previous
            // options provided, but supplements those options.
            .merging(with: try .init(contentsOf: projectOptionsFile))

            // Lastly, we provide a fallback bundle source and output file to ensure that these
            // values are always set should no other values be provided
            .merging(with: .init(outputPath: rswiftPath.string))

        // Get a concrete reference to the file we'll be writing out to
        let outputPath = options.outputPath.map { $0.hasPrefix("/") ? Path($0) : defaultOutputDirectoryPath.appending(subpath: $0) } ?? rswiftPath

        // Create the output directory, if needed
        try FileManager.default.createDirectory(atPath: outputPath.removingLastComponent().string,
                                                withIntermediateDirectories: true)

        // Lastly, convert the options struct into an array of arguments, subsequently
        // appending the input type and files, all of which will be provided to the
        // `rswift` utility that we'll invoke.
        let arguments: [String] =
            options.makeArguments(sourceDirectory: URL(fileURLWithPath: context.xcodeProject.directory.string),
                                  outputDirectory: URL(fileURLWithPath: outputPath.removingLastComponent().string)) +
            ["--input-type", "xcodeproj"]

        let description: String
        if let product = target.product {
            description = "\(product.kind) \(target.displayName)"
        } else {
            description = target.displayName
        }

        // Return the build command to execute
        return [
            .buildCommand(
                displayName: "R.swift generate resources for \(description)",
                executable: try context.tool(named: "rswift").path,
                arguments: arguments,
                outputFiles: [outputPath]
            ),
        ]
    }
}

#endif
