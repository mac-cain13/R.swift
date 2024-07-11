//
//  RswiftOptions.swift
//  R.swift
//
//  Created by Joe Newton on 2024-07-11.
//

import Foundation

struct RswiftOptions: Decodable {
    let generators: [ResourceType]?
    let omitMainLet: Bool?
    let imports: [String]?
    let accessLevel: AccessLevel?
    let rswiftignore: String?
    let bundleSource: BundleSource?
    let outputPath: String?
    let additionalArguments: [String]?

    init?(contentsOf url: URL) throws {
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        self = try JSONDecoder().decode(RswiftOptions.self, from: Data(contentsOf: url))
    }

    init(from arguments: [String]) throws {
        var structuredArguments: [String: Any] = [:]

        // We first iterate over all of the provided arguments to put them into a
        // dictionary structure.
        var i = arguments.startIndex
        while i < arguments.endIndex {
            let argument = arguments[i]
            if argument == "--omit-main-let" {
                structuredArguments["omit-main-let"] = true
            } else if argument.hasPrefix("--") {
                if arguments.index(after: i) == arguments.endIndex {
                    // This is the very last argument provided
                    structuredArguments["additional-arguments"] = (structuredArguments["additional-arguments"] as? [String] ?? []) + [argument]
                } else {
                    // We have at least one argument that comes after this one
                    let key = argument == "--import" ? "imports" : String(argument.dropFirst(2))
                    i = arguments.index(after: i) // Move the index to the argument's value

                    if key == "imports" || key == "generators" {
                        // These keys represent arrays, so we'll append to that array
                        structuredArguments[key] = (structuredArguments[key] as? [String] ?? []) + [arguments[i]]
                    } else {
                        structuredArguments[key] = arguments[i]
                    }
                }
            } else {
                structuredArguments["additional-arguments"] = (structuredArguments["additional-arguments"] as? [String] ?? []) + [argument]
            }

            i = arguments.index(after: i)
        }

        if structuredArguments.isEmpty {
            // No options parsed out, simply delegate to the default initializer
            self.init()
        } else {
            // Now that we have a dictionary structure, we can attempt to serialize the
            // dictionary into data that we can then attempt to decode.
            let encodedArguments = try JSONSerialization.data(withJSONObject: structuredArguments)
            self = try JSONDecoder().decode(RswiftOptions.self, from: encodedArguments)
        }
    }

    init(generators: [ResourceType]? = nil,
         omitMainLet: Bool? = nil,
         imports: [String]? = nil,
         accessLevel: AccessLevel? = nil,
         rswiftignore: String? = nil,
         bundleSource: BundleSource? = nil,
         outputPath: String? = nil,
         additionalArguments: [String]? = nil) {
        self.generators = generators
        self.omitMainLet = omitMainLet
        self.imports = imports
        self.accessLevel = accessLevel
        self.rswiftignore = rswiftignore
        self.bundleSource = bundleSource
        self.outputPath = outputPath
        self.additionalArguments = additionalArguments
    }

    func merging(with options: RswiftOptions?) -> RswiftOptions {
        guard let options else { return self }
        return RswiftOptions(
            generators: generators.flatMap { $0.isEmpty ? nil : $0 } ?? options.generators,
            omitMainLet: omitMainLet ?? options.omitMainLet,
            imports: imports.flatMap { $0.isEmpty ? nil : $0 } ?? options.imports,
            accessLevel: accessLevel ?? options.accessLevel,
            rswiftignore: rswiftignore ?? options.rswiftignore,
            bundleSource: bundleSource ?? options.bundleSource,
            outputPath: outputPath ?? options.outputPath,
            additionalArguments: additionalArguments.map { $0 + (options.additionalArguments ?? []) } ?? options.additionalArguments
        )
    }

    func makeArguments(command: String = "generate",
                       sourceDirectory: URL,
                       outputDirectory: URL? = nil,
                       fallbackOutputPath: String = "R.generated.swift") -> [String] {
        let outputDirectory = outputDirectory ?? sourceDirectory
        let outputPath = outputPath ?? fallbackOutputPath
        var arguments: [String] = [
            command, outputPath.hasPrefix("/") ? outputPath : outputDirectory.appendingPathComponent(outputPath).path
        ]

        arguments += (generators ?? []).flatMap { ["--generators", $0.rawValue] }
        arguments += omitMainLet == true ? ["--omit-main-let"] : []
        arguments += (imports ?? []).flatMap { ["--import", $0] }
        arguments += accessLevel.map { ["--access-level", $0.rawValue] } ?? []
        arguments += rswiftignore.map { ["--rswiftignore", $0.starts(with: "/") ? $0 : sourceDirectory.appendingPathComponent($0).path] } ?? []
        arguments += bundleSource.map { ["--bundle-source", $0.rawValue] } ?? []
        arguments += additionalArguments ?? []

        return arguments
    }

    enum CodingKeys: String, CodingKey {
        case generators
        case omitMainLet = "omit-main-let"
        case imports
        case accessLevel = "access-level"
        case rswiftignore
        case bundleSource = "bundle-source"
        case outputPath = "output-path"
        case additionalArguments = "additional-arguments"
    }
}
