//
//  ImportPrinter.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 06-10-16.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

/// Prints all import statements for the modules used in the given structs
struct ImportPrinter: SwiftCodeConverible {
  let swiftCode: String

  init(structs: [Struct?], excludedModules: Set<Module>) {
    let usedModules = structs
      .flatMap { $0 }
      .flatMap(getUsedTypes)
      .map { $0.type.module }

    swiftCode = Set(usedModules)
      .subtracting(excludedModules)
      .filter { $0.isCustom }
      .sortBy { $0.description }
      .map { "import \($0)" }
      .joined(separator: "\n")
  }
}
