//
//  EnvironmentValidation.swift
//  Commander
//
//  Created by Tom Lokhorst on 2018-12-12.
//

import Foundation

// TODO: "Check XXX output file" codeblocks contain a lot of duplication and are error prone to mix up variables, needs refactor
public func validateRswiftEnvironment(
  outputURL: URL,
  uiTestOutputURL: URL?,
  sourceRootPath: String,
  podsRoot: String?,
  podsTargetSrcroot: String?,
  commandLineArguments: [String]) -> [String]
{
  var errors: [String] = []

  // Check regular output file
  if outputURL.pathExtension != "swift" {

    var error = "Output path must specify a file, it should not be a directory."
    if FileManager.default.directoryExists(atPath: outputURL.path) {
      let rswiftGeneratedFile = outputURL.appendingPathComponent("R.generated.swift").path

      let commandParts = commandLineArguments
        .map { $0.replacingOccurrences(of: outputURL.path, with: rswiftGeneratedFile) }
        .map { $0.replacingOccurrences(of: podsTargetSrcroot ?? "", with: "$PODS_TARGET_SRCROOT") }
        .map { $0.replacingOccurrences(of: podsRoot ?? "", with: "$PODS_ROOT") }
        .map { $0.replacingOccurrences(of: sourceRootPath, with: "$SOURCE_ROOT") }
        .map { $0.contains(" ") ? "\"\($0)\"" : $0 }

      error += "\nExample: " + commandParts.joined(separator: " ")
    }

    errors.append(error)
  }

  // Check UITest output file
  if let uiTestOutputURL = uiTestOutputURL {
    if uiTestOutputURL.pathExtension != "swift" {

      var error = "Output path for UI test file must specify a file, it should not be a directory."
      if FileManager.default.directoryExists(atPath: uiTestOutputURL.path) {
        let rswiftGeneratedFile = uiTestOutputURL.appendingPathComponent("R.generated.swift").path

        let commandParts = commandLineArguments
          .map { $0.replacingOccurrences(of: uiTestOutputURL.path, with: rswiftGeneratedFile) }
          .map { $0.replacingOccurrences(of: podsTargetSrcroot ?? "", with: "$PODS_TARGET_SRCROOT") }
          .map { $0.replacingOccurrences(of: podsRoot ?? "", with: "$PODS_ROOT") }
          .map { $0.replacingOccurrences(of: sourceRootPath, with: "$SOURCE_ROOT") }
          .map { $0.contains(" ") ? "\"\($0)\"" : $0 }

        error += "\nExample: " + commandParts.joined(separator: " ")
      }

      errors.append(error)
    }
  }

  return errors
}

extension FileManager {
  func directoryExists(atPath path: String) -> Bool {
    var isDir: ObjCBool = false
    let exists = fileExists(atPath: path, isDirectory: &isDir)

    return exists && isDir.boolValue
  }
}
