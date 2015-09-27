//
//  input.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 03-09-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

enum InputParsingError: ErrorType {
  case IllegalOption(String)
  case MissingOption(String)
  case UserAskedForHelp(String)
}

private let xcodeprojOption = Option(
  trigger: .Mixed("p", "xcodeproj"),
  numberOfParameters: 1,
  helpDescription: "Path to the xcodeproj file, if non given R.swift will use the environment variable PROJECT_FILE_PATH."
)
private let targetOption = Option(
  trigger: .Mixed("t", "target"),
  numberOfParameters: 1,
  helpDescription: "Target the R-file should be generated for, if non given R.swift will use the environment variable TARGET_NAME."
)
private let buildProductsDirOption = Option(
  trigger: .Long("buildProductsDir"), 
  numberOfParameters: 1, 
  helpDescription: "Build products folder that Xcode uses during build, if none given R.swift will use the environment variable BUILT_PRODUCTS_DIR."
)
private let developerDirOption = Option(
  trigger: .Long("developerDir"), 
  numberOfParameters: 1, 
  helpDescription: "Developer folder that Xcode uses during build, if none given R.swift will use the environment variable DEVELOPER_DIR."
)
private let sourceRootOption = Option(
  trigger: .Long("sourceRoot"), 
  numberOfParameters: 1, 
  helpDescription: "Source root folder that Xcode uses during build, if none given R.swift will use the environment variable SOURCE_ROOT."
)
private let sdkRootOption = Option(
  trigger: .Long("sdkRoot"), 
  numberOfParameters: 1, 
  helpDescription: "SDK root folder that Xcode uses during build, if none given R.swift will use the environment variable SDKROOT."
)

private let AllOptions = [
  xcodeprojOption,
  targetOption,
  buildProductsDirOption,
  developerDirOption,
  sourceRootOption,
  sdkRootOption
]

struct CallInformation {
  let outputURL: NSURL

  let xcodeprojURL: NSURL
  let targetName: String

  private let buildProductsDir: String
  private let developerDir: String
  private let sourceRoot: String
  private let sdkRoot: String

  init(processInfo: NSProcessInfo) throws {
    let optionParser = OptionParser(definitions: AllOptions)
    let commandName = processInfo.arguments.first.flatMap { NSURL(fileURLWithPath: $0).lastPathComponent } ?? "rswift"
    let argumentsWithoutCall = Array(processInfo.arguments.dropFirst())
    let environment = processInfo.environment

    do {
      let (options, extraArguments) = try optionParser.parse(argumentsWithoutCall)

      if options[optionParser.helpOption] != nil {
        throw InputParsingError.UserAskedForHelp(optionParser.helpStringForCommandName(commandName))
      }

      guard let outputPath = extraArguments.first where extraArguments.count == 1 else {
        throw InputParsingError.IllegalOption(optionParser.helpStringForCommandName(commandName))
      }

      let outputURL = NSURL(fileURLWithPath: outputPath)

      var resourceValue: AnyObject?
      try! outputURL.getResourceValue(&resourceValue, forKey: NSURLIsDirectoryKey)
      if let isDirectory = (resourceValue as? NSNumber)?.boolValue where isDirectory {
        self.outputURL = outputURL.URLByAppendingPathComponent(ResourceFilename, isDirectory: false)
      } else {
        self.outputURL = outputURL
      }

      let getFirstArgumentForOption = getFirstArgumentFromOptionData(options, helpString: optionParser.helpStringForCommandName(commandName))

      let xcodeprojPath = try getFirstArgumentForOption(xcodeprojOption, defaultValue: environment["PROJECT_FILE_PATH"])
      xcodeprojURL = NSURL(fileURLWithPath: xcodeprojPath)
      targetName = try getFirstArgumentForOption(targetOption, defaultValue: environment["TARGET_NAME"])

      buildProductsDir = try getFirstArgumentForOption(buildProductsDirOption, defaultValue: environment["BUILT_PRODUCTS_DIR"])
      developerDir = try getFirstArgumentForOption(developerDirOption, defaultValue: environment["DEVELOPER_DIR"])
      sourceRoot = try getFirstArgumentForOption(sourceRootOption, defaultValue: environment["SOURCE_ROOT"])
      sdkRoot = try getFirstArgumentForOption(sdkRootOption, defaultValue: environment["SDKROOT"])
    } catch OptionKitError.InvalidOption {
      throw InputParsingError.IllegalOption(optionParser.helpStringForCommandName(commandName))
    }
  }

  func pathFromSourceTreeFolder(sourceTreeFolder: SourceTreeFolder) -> String {
    switch sourceTreeFolder {
    case .BuildProductsDir:
      return buildProductsDir
    case .DeveloperDir:
      return developerDir
    case .SDKRoot:
      return sdkRoot
    case .SourceRoot:
      return sourceRoot
    }
  }
}

private func getFirstArgumentFromOptionData(options: [Option:[String]], helpString: String)(_ option: Option, defaultValue: String?) throws -> String {
  guard let result = options[option]?.first ?? defaultValue else {
    throw InputParsingError.MissingOption(helpString)
  }

  return result
}

func pathResolverWithSourceTreeToPathConverter(pathFromSourceTreeFolder: SourceTreeFolder -> String)(path: Path) -> NSURL {
  switch path {
  case let .Absolute(absolutePath):
    return NSURL(fileURLWithPath: absolutePath)
  case let .RelativeTo(sourceTreeFolder, relativePath):
    let sourceTreePath = pathFromSourceTreeFolder(sourceTreeFolder)
    return NSURL(fileURLWithPath: sourceTreePath).URLByAppendingPathComponent(relativePath)
  }
}
