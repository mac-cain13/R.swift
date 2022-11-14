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

  init(modules: [Module], extractFrom structs: [Struct?], exclude excludedModules: Set<Module>) {
    let extractedModules = structs
      .compactMap { $0 }
      .flatMap(getUsedTypes)
      .map { $0.type.module }

    let extractedModulesArray = Set(extractedModules)
      .subtracting(excludedModules)
      .subtracting(modules)
      .filter { $0.isCustom }
      .sorted { $0.description < $1.description }

    // Note that the modules specified to the --import flag are always specified first
    // See: https://github.com/mac-cain13/R.swift/issues/534
    var modulesToImport = modules
    modulesToImport.append(contentsOf: extractedModulesArray)

    swiftCode = modulesToImport
      .filter { !($0 == "Foundation" && modulesToImport.contains("UIKit")) }
      .map { "import \($0)" }
      .joined(separator: "\n")
  }
}
