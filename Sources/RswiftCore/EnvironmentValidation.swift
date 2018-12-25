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
  // All comparisons are performed over path strings so we should use standardized paths to address cases like
  // /foo/../bar <=> /bar
  let standardizedOutputURL = outputURL.standardized
  let standardizedSourceRootPath = URL(fileURLWithPath: sourceRootPath).standardized.path
  
  var errors: [String] = []
  var outputFileForError = standardizedOutputURL.path

  if outputURL.pathExtension != "swift" {

    var error = "Output path must specify a file, it should not be a directory."
    if FileManager.default.directoryExists(atPath: outputURL.path) {
      let rswiftGeneratedFile = standardizedOutputURL.appendingPathComponent("R.generated.swift").path
      let standardizedPodsRoot = podsRoot.map { URL(fileURLWithPath: $0).standardized.path }
      let commandParts = commandLineArguments
        .map { $0.replacingOccurrences(of: standardizedPodsRoot ?? "", with: "$PODS_ROOT") }
        .map { $0.replacingOccurrences(of: standardizedOutputURL.path, with: rswiftGeneratedFile) }
        .map { $0.replacingOccurrences(of: standardizedSourceRootPath, with: "$SRCROOT") }
        .map { $0.contains(" ") ? "\"\($0)\"" : $0 }

      error += "\nExample: " + commandParts.joined(separator: " ")

      outputFileForError = rswiftGeneratedFile
    }

    errors.append(error)
  }

  let standardizedScriptInputFiles = scriptInputFiles.map { URL(fileURLWithPath: $0).standardized.path }
  let standardizedLastRun = lastRunURL.standardized.path
  if !standardizedScriptInputFiles.contains(standardizedLastRun) {
    errors.append("Build phase Intput Files does not contain '$TEMP_DIR/\(lastRunURL.lastPathComponent)'.")
  }

  let standardizedScriptOutputFiles = scriptOutputFiles.map { URL(fileURLWithPath: $0).standardized.path }
  if !standardizedScriptOutputFiles.contains(standardizedOutputURL.path) {
    let path = outputFileForError.replacingOccurrences(of: standardizedSourceRootPath, with: "$SRCROOT")
    errors.append("Build phase Output Files do not contain '\(path)'.")
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
