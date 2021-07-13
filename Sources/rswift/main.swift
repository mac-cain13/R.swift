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

    @Option(help: "The target")
    var target: String

    func run() throws {
        try RswiftCore.developRun(
            projectPath: project,
            targetName: target
        )
    }
}

Generate.main()
