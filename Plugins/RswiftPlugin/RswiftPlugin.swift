//
//  RswiftPlugin.swift
//  R.swift
//
//  Created by Mathijs Bernson on 10/10/2022.
//

import Foundation
import PackagePlugin

@main
struct RswiftPlugin: BuildToolPlugin {
    func createBuildCommands(
        context: PackagePlugin.PluginContext,
        target: PackagePlugin.Target
    ) async throws -> [PackagePlugin.Command] {
        // Directory where R.generated.swift will be stored
        let generatedFileDirectory = context.pluginWorkDirectory
            .appending(subpath: target.name)
        let generatedFilePath = generatedFileDirectory
            .appending(subpath: "R.generated.swift")

        return [
            .prebuildCommand(
                displayName: "R.swift",
                executable: try context.tool(named: "rswift").path,
                arguments: [
                    "generate",
                    "\(generatedFilePath)"
                ],
                outputFilesDirectory: generatedFileDirectory
            )
        ]
    }
}
