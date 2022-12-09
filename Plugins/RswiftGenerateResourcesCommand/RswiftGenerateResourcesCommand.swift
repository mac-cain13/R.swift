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
        let outputSubpath = parsedArguments.outputFile ?? "R.generated.swift"

        for target in context.package.targets {
            guard let target = target as? SourceModuleTarget else { continue }
            guard parsedArguments.targets.contains(target.name) || parsedArguments.targets.isEmpty else { continue }

            let outputPath = target.directory.appending(subpath: outputSubpath)

            let sourceFiles = target.sourceFiles
                .filter { $0.type == .resource || $0.type == .unknown }
                .map(\.path.string)

            let inputFilesArguments = sourceFiles
                .flatMap { ["--input-files", $0 ] }

            let bundleSource = target.kind == .generic ? "module" : "finder"

            let arguments: [String] = [
                "generate", outputPath.string,
                "--input-type", "input-files",
                "--bundle-source", bundleSource,
            ] + inputFilesArguments + parsedArguments.remaining

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
        let outputSubpath = parsedArguments.outputFile ?? "R.generated.swift"

        for target in context.xcodeProject.targets {
            guard parsedArguments.targets.contains(target.displayName) || parsedArguments.targets.isEmpty else { continue }

            let outputPath = context.xcodeProject.directory.appending(subpath: outputSubpath)

            let sourceFiles = target.inputFiles
                .filter { $0.type == .resource || $0.type == .unknown }
                .map(\.path.string)

            let inputFilesArguments = sourceFiles
                .flatMap { ["--input-files", $0 ] }

            let arguments: [String] = [
                "generate", outputPath.string,
                "--input-type", "input-files",
                "--bundle-source", "finder",
            ] + inputFilesArguments + parsedArguments.remaining

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
