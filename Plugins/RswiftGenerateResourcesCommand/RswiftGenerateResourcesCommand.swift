//
//  RswiftGenerateResourcesCommand.swift
//
//
//  Created by Tom Lokhorst on 2022-10-19.
//

import Foundation
import PackagePlugin

@main
struct RswiftGenerateResourcesCommand: CommandPlugin {
    func performCommand(context: PluginContext, arguments externalArgs: [String]) async throws {

        let rswift = try context.tool(named: "rswift")
        let selectedTargets = targets(from: externalArgs)
        let outputSubpath = outputFile(from: externalArgs) ?? "R.generated.swift"

        for target in context.package.targets {
            guard let target = target as? SourceModuleTarget else { continue }
            guard selectedTargets.contains(target.name) || selectedTargets.isEmpty else { continue }

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
            ] + inputFilesArguments + externalArgs

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
        let selectedTargets = targets(from: externalArgs)
        let outputSubpath = outputFile(from: externalArgs) ?? "R.generated.swift"

        for target in context.xcodeProject.targets {
            guard let target = target as? SourceModuleTarget else { continue }
            guard selectedTargets.contains(target.name) || selectedTargets.isEmpty else { continue }

            let outputPath = target.directory.appending(subpath: outputSubpath)

            let arguments: [String] = [
                "generate", outputPath.string,
                "--target", target.name,
                "--input-type", "xcodeproj",
                "--bundle-source", "finder",
            ] + externalArgs

            do {
                try rswift.run(arguments: arguments, environment: nil)
            } catch let error as RunError {
                Diagnostics.error(error.description)
            }
        }

    }
}

#endif

private func targets(from arguments: [String]) -> [String] {
    zip(arguments, arguments.dropFirst())
        .compactMap { (key, value) in
            key == "--target" ? value : nil
        }
}

private func outputFile(from arguments: [String]) -> String? {
    arguments.first { $0.hasSuffix(".swift") }
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
