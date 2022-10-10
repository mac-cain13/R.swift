//
//  RswiftPlugin.swift
//  R.swift
//
//  Created by Mathijs Bernson on 10/10/2022.
//

import Foundation
import PackagePlugin

enum RswiftPluginError: Error {
    case xcodeprojectNotFound
}

@main
struct RswiftPlugin: BuildToolPlugin {
    func createBuildCommands(
        context: PackagePlugin.PluginContext,
        target: PackagePlugin.Target
    ) async throws -> [PackagePlugin.Command] {
        // Directory where R.generated.swift will be stored
        let generatedFileDirectory = context.pluginWorkDirectory
            .appending(subpath: "GeneratedSources")
        let generatedFilePath = generatedFileDirectory
            .appending(subpath: "R.generated.swift")

        let xcodeProjects = try FileManager.default.contentsOfDirectory(atPath: target.directory.string)
            .filter { $0.hasSuffix(".xcodeproj") }
        guard xcodeProjects.count == 1, let xcodeproj = xcodeProjects.first
        else { throw RswiftPluginError.xcodeprojectNotFound }

        return [
            .prebuildCommand(
                displayName: "R.swift",
                executable: try context.tool(named: "rswift").path,
                arguments: [
                    "generate",
                    "\(generatedFilePath)"
                ],
                environment: [
                    "PROJECT_FILE_PATH": xcodeproj,
                    "TARGET_NAME": target.name,
                    "PRODUCT_MODULE_NAME": target.name,
                    "SOURCE_ROOT": target.directory,

                    // These variables must be set or R.swift will complain and not run
                    "PRODUCT_BUNDLE_IDENTIFIER": "",
                    "BUILT_PRODUCTS_DIR": "",
                    "DEVELOPER_DIR": "",
                    "BUILT_PRODUCTS_DIR": "",
                    "DEVELOPER_DIR": "",
                    "SDKROOT": "",
                    "PLATFORM_DIR": "",
                ],
                outputFilesDirectory: generatedFileDirectory
            )
        ]
    }
}
