//
//  RswiftGenerateInternalResources.swift
//  
//
//  Created by Tom Lokhorst on 2022-10-19.
//

import Foundation
import PackagePlugin

struct RSwiftConfig: Codable {
    enum Generator: String, Codable {
        case image, string, color
        case file, font, nib
        case segue, storyboard, reuseIdentifier
        case entitlements, info, id
    }
    
    let generators: [Generator]?
    let rswiftignorePath: String?
    let additionalArguments: [String]?
}

@main
struct RswiftGenerateInternalResources: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
        guard let target = target as? SourceModuleTarget else { return [] }

        let outputDirectoryPath = context.pluginWorkDirectory
            .appending(subpath: target.name)

        try FileManager.default.createDirectory(atPath: outputDirectoryPath.string, withIntermediateDirectories: true)

        let rswiftPath = outputDirectoryPath.appending(subpath: "R.generated.swift")

        let sourceFiles = target.sourceFiles
            .filter { $0.type == .resource || $0.type == .unknown }
            .map(\.path.string)

        let inputFilesArguments = sourceFiles
            .flatMap { ["--input-files", $0 ] }

        let bundleSource = target.kind == .generic ? "module" : "finder"
        let description = "\(target.kind) module \(target.name)"
        
        var additionalArguments: [String] = []
        if let config = getConfig(from: target) {
            if let generators = config.generators {
                let generators = generators.map(\.rawValue).joined(separator: ",")
                additionalArguments += ["--generators", generators]
            }
            if let rswiftignorePath = config.rswiftignorePath {
                additionalArguments += ["--rswiftignore", rswiftignorePath]
            }
            if let other = config.additionalArguments {
                additionalArguments += other
            }
        }
        
        return [
            .buildCommand(
                displayName: "R.swift generate resources for \(description)",
                executable: try context.tool(named: "rswift").path,
                arguments: [
                    "generate", rswiftPath.string,
                    "--input-type", "input-files",
                    "--bundle-source", bundleSource,
                ] + inputFilesArguments + additionalArguments,
                outputFiles: [rswiftPath]
            ),
        ]
    }
    
    func getConfig(from target: SourceModuleTarget) -> RSwiftConfig? {
        guard let path = locateConfig(in: target) else {
            return nil
        }
        return decodeConfig(at: path)
    }
    
    func locateConfig(in target: SourceModuleTarget) -> Path? {
        let rootConfig = target.directory.appending(["rswift.json"])
        if FileManager.default.fileExists(atPath: rootConfig.string) {
            return rootConfig
        }
        return target.sourceFiles.map(\.path).first(where: { $0.lastComponent == "rswift.json" })
    }
    
    func decodeConfig(at path: Path) -> RSwiftConfig? {
        guard let config = URL(string: "file://\(path.string)"),
              let data = try? Data(contentsOf: config) else {
            return nil
        }
        return try? JSONDecoder().decode(RSwiftConfig.self, from: data)
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension RswiftGenerateInternalResources: XcodeBuildToolPlugin {
    func createBuildCommands(context: XcodePluginContext, target: XcodeTarget) throws -> [Command] {
        let resourcesDirectoryPath = context.pluginWorkDirectory
            .appending(subpath: target.displayName)
            .appending(subpath: "Resources")

        try FileManager.default.createDirectory(atPath: resourcesDirectoryPath.string, withIntermediateDirectories: true)

        let rswiftPath = resourcesDirectoryPath.appending(subpath: "R.generated.swift")

        let description: String
        if let product = target.product {
            description = "\(product.kind) \(target.displayName)"
        } else {
            description = target.displayName
        }
        
        var additionalArguments: [String] = []
        if let config = getConfig(from: context.xcodeProject) {
            if let generators = config.generators {
                let generators = generators.map(\.rawValue).joined(separator: ",")
                additionalArguments += ["--generators", generators]
            }
            if let rswiftignorePath = config.rswiftignorePath {
                additionalArguments += ["--rswiftignore", rswiftignorePath]
            }
            if let other = config.additionalArguments {
                additionalArguments += other
            }
        }

        return [
            .buildCommand(
                displayName: "R.swift generate resources for \(description)",
                executable: try context.tool(named: "rswift").path,
                arguments: [
                    "generate", rswiftPath.string,
                    "--target", target.displayName,
                    "--input-type", "xcodeproj",
                    "--bundle-source", "finder"
                ] + additionalArguments,
                outputFiles: [rswiftPath]
            ),
        ]
    }
    
    func getConfig(from xcodeProject: XcodeProject) -> RSwiftConfig? {
        guard let path = locateConfig(in: xcodeProject) else {
            return nil
        }
        return decodeConfig(at: path)
    }
    
    func locateConfig(in xcodeProject: XcodeProject) -> Path? {
        let rootConfig = xcodeProject.directory.appending(["rswift.json"])
        if FileManager.default.fileExists(atPath: rootConfig.string) {
            return rootConfig
        }
        return xcodeProject.filePaths.first(where: { $0.lastComponent == "rswift.json" })
    }
}

#endif
