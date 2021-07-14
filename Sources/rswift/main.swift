//
//  main.swift
//  rswift
//
//  Created by Tom Lokhorst on 2021-04-18.
//

import Foundation
import RswiftCore
import ArgumentParser

struct Generate: ParsableCommand {
    @Option(help: "The Xcode project path")
    var project: String

    @Option(help: "The target to generate R.swift code for")
    var target: String

    @Option(help: "The project source root")
    var sourceRoot: String

    func run() throws {
        try RswiftCore().run(
            projectPath: project,
            targetName: target,
            sourceRoot: sourceRoot
        )
    }
}

Generate.main()
