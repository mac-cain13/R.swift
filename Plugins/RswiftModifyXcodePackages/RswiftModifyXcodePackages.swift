//
//  RswiftModifyXcodePackages.swift
//
//
//  Created by Tom Lokhorst on 2022-11-07.
//

import Foundation
import PackagePlugin

@main
struct RswiftModifyXcodePackages: CommandPlugin {
    func performCommand(context: PluginContext, arguments externalArgs: [String]) async throws {
        Diagnostics.warning("Command only supported as Xcode command plugin")
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension RswiftModifyXcodePackages: XcodeCommandPlugin {
    func performCommand(context: XcodePluginContext, arguments externalArgs: [String]) throws {
        let rswift = try context.tool(named: "rswift")

        let projectArgument = externalArgs.first { $0.hasSuffix(".xcodeproj") }
        if let projectArgument {
            let arguments = ["modify-xcode-packages", "--xcodeproj", projectArgument]
                + externalArgs.filter { $0 != projectArgument }
            try rswift.run(arguments: arguments, environment: nil)
            return
        }

        let xcodeProjects = try FileManager.default.contentsOfDirectory(atPath: context.xcodeProject.directory.string)
            .filter { $0.hasSuffix(".xcodeproj") }

        guard let xcodeproj = xcodeProjects.first else {
            Diagnostics.error("Can't find .xcodeproj in \(context.xcodeProject.directory.string). Manually specify .xcodeproj file to this command.")
            return
        }

        if xcodeProjects.count > 1 {
            Diagnostics.error("Found multiple .xcodeproj files in \(context.xcodeProject.directory.string). Manually specify .xcodeproj file to this command.")
            return
        }

        let arguments = ["modify-xcode-packages", "--xcodeproj", xcodeproj] + externalArgs
        try rswift.run(arguments: arguments, environment: nil)
    }
}

#endif

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
            Diagnostics.error(stderr)
        } else {
            let problem = "\(process.terminationReason.rawValue):\(process.terminationStatus)"
            Diagnostics.error(problem)
        }
    }
}
