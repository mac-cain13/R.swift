//
//  RswiftGenerateResourcesCommand.swift
//  R.swift
//
//  Created by Tom Lokhorst on 2022-10-19.
//

import Foundation
import PackagePlugin

@main
struct RswiftGenerateResourcesCommand: CommandPlugin {
    func performCommand(context: PluginContext, arguments externalArgs: [String]) async throws {

        let rswift = try context.tool(named: "rswift")
        let parsedArguments = ParsedArguments.parse(arguments: externalArgs)

        for target in context.package.targets {
            guard let target = target as? SourceModuleTarget else { continue }
            guard parsedArguments.targets.contains(target.name) || parsedArguments.targets.isEmpty else { continue }

            let optionsFile = URL(fileURLWithPath: target.directory.appending(subpath: ".rswiftoptions").string)

            // Our base set of options contains just the output file. We do this since if when
            // running the plugin an explicit output file was provided, this should take
            // precedence any other argument that might have been provided by other means.
            let options = RswiftOptions(outputPath: parsedArguments.outputFile)

                // Next we merge in the "remaining" arguments that were provided when invoking the
                // plugin. Like with the output file, these should take precedence over any other
                // arguments provided by other means.
                .merging(with: try .init(from: parsedArguments.remaining))

                // Next we load and merge any options that may be present in an options file. These
                // options don't override any of the previous options provided, but supplements
                // those options.
                .merging(with: try .init(contentsOf: optionsFile))

                // Lastly, we provide a fallback bundle source and output file to ensure that these
                // values are always set should no other values be provided
                .merging(with: .init(bundleSource: target.kind == .generic ? .module : .finder,
                                     outputPath: "R.generated.swift"))

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
                options.makeArguments(sourceDirectory: URL(fileURLWithPath: target.directory.string)) +
                ["--input-type", "input-files"] + inputFilesArguments

            // Finally, run the `rswift` utility
            do {
                try rswift.run(arguments: arguments, environment: nil)
            } catch let error as RunError {
                Diagnostics.error(error.description)
            }
        }

    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension RswiftGenerateResourcesCommand: XcodeCommandPlugin {
    func performCommand(context: XcodePluginContext, arguments externalArgs: [String]) throws {

        let rswift = try context.tool(named: "rswift")
        let parsedArguments = ParsedArguments.parse(arguments: externalArgs)

        for target in context.xcodeProject.targets {
            guard parsedArguments.targets.contains(target.displayName) || parsedArguments.targets.isEmpty else { continue }

            let projectOptionsFile = URL(fileURLWithPath: context.xcodeProject.directory.appending(subpath: ".rswiftoptions").string)
            let targetOptionsFile = URL(fileURLWithPath: context.xcodeProject.directory.appending(subpath: target.displayName).appending(subpath: ".rswiftoptions").string)

            // Our base set of options contains just the output file. We do this since if when
            // running the plugin an explicit output file was provided, this should take
            // precedence any other argument that might have been provided by other means.
            let options = RswiftOptions(outputPath: parsedArguments.outputFile)

                // Next we merge in the "remaining" arguments that were provided when invoking the
                // plugin. Like with the output file, these should take precedence over any other
                // arguments provided by other means.
                .merging(with: try .init(from: parsedArguments.remaining))

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
                .merging(with: .init(bundleSource: .finder,
                                     outputPath: "R.generated.swift"))

            // Get the input files for the current target being processed
            let sourceFiles: [String] = target.inputFiles
                .filter { $0.type == .resource || $0.type == .unknown }
                .map(\.path.string)

            let inputFilesArguments: [String] = sourceFiles
                .flatMap { ["--input-files", $0 ] }

            // Lastly, convert the options struct into an array of arguments, subsequently
            // appending the input type and files, all of which will be provided to the
            // `rswift` utility that we'll invoke.
            let arguments: [String] =
                options.makeArguments(sourceDirectory: URL(fileURLWithPath: context.xcodeProject.directory.string)) +
                ["--input-type", "input-files"] + inputFilesArguments

            var environment: [String: String] = [
                "SOURCE_ROOT": context.xcodeProject.directory.string,
            ]
            if let product = target.product {
                environment["PRODUCT_MODULE_NAME"] = product.name
            }

            do {
                try rswift.run(arguments: arguments, environment: environment)
            } catch let error as RunError {
                Diagnostics.error(error.description)
            }
        }

    }
}

#endif

struct ParsedArguments {
    var targets: [String] = []
    var remaining: [String] = []
    var outputFile: String?

    static func parse(arguments: [String]) -> ParsedArguments {
        var result = ParsedArguments()

        for (key, value) in zip(arguments, arguments.dropFirst()) {
            if result.outputFile == nil && key.hasSuffix(".swift") {
                result.outputFile = key
                continue
            }
            if result.outputFile == nil && value.hasSuffix(".swift") {
                result.outputFile = value
                continue
            }

            if key == "--target" {
                result.targets.append(value)
            } else if value != "--target" {
                result.remaining.append(value)
            }
        }

        return result
    }
}

struct RunError: Error {
    let description: String
}

private extension PluginContext.Tool {
    func run(arguments: [String], environment: [String: String]?) throws {
        let pipe = Pipe()
        let process = Process()
        process.executableURL = URL(fileURLWithPath: path.string)
        process.arguments = arguments
        process.environment = environment
        process.standardError = pipe

        try process.run()
        process.waitUntilExit()

        if process.terminationReason == .exit && process.terminationStatus == 0 {
            return
        }

        let data = try pipe.fileHandleForReading.readToEnd()
        let stderr = data.flatMap { String(data: $0, encoding: .utf8) }

        if let stderr {
            throw RunError(description: stderr)
        } else {
            let problem = "\(process.terminationReason.rawValue):\(process.terminationStatus)"
            throw RunError(description: "\(name) invocation failed: \(problem)")
        }
    }
}
