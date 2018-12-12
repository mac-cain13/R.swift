//
//  EnvironmentValidation.swift
//  Commander
//
//  Created by Tom Lokhorst on 2018-12-12.
//

import Foundation

public func validateRswiftEnvironment(
  outputURL: URL,
  sourceRootPath: String,
  scriptInputFiles: [String],
  scriptOutputFiles: [String],
  lastRunURL: URL,
  podsRoot: String?,
  commandLineArguments: [String]) -> [String]
{
  var errors: [String] = []
  var outputIsDirectory = false

  if outputURL.pathExtension != "swift" {
    outputIsDirectory = true

    var error = "Output path must specify a file, it should not be a directory."
    if FileManager.default.directoryExists(atPath: outputURL.path) {
      let rswiftGeneratedFile = outputURL.appendingPathComponent("R.generated.swift").path
      let commandParts = commandLineArguments
        .map { $0.replacingOccurrences(of: podsRoot ?? "", with: "$PODS_ROOT") }
        .map { $0.replacingOccurrences(of: outputURL.path, with: rswiftGeneratedFile) }
        .map { $0.replacingOccurrences(of: sourceRootPath, with: "$SRCROOT") }
        .map { $0.contains(" ") ? "\"\($0)\"" : $0 }
      error += "\nExample: " + commandParts.joined(separator: " ")
    }

    errors.append(error)
  }

  if !scriptInputFiles.contains(lastRunURL.path) {
    errors.append("Build phase Intput Files does not contain '$TEMP_DIR/\(lastRunURL.lastPathComponent)'.")
  }

  if !scriptOutputFiles.contains(outputURL.path) {
    var prettyPath = outputURL.path.replacingOccurrences(of: sourceRootPath, with: "$SRCROOT")
    if outputIsDirectory {
      prettyPath += "/R.generated.swift"
    }
    errors.append("Build phase Output Files do not contain '\(prettyPath)'.")
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
