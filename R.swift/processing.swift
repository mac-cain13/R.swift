//
//  processing.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 06-09-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

private func tryResourceParsing<T>(parse: () throws -> T) -> T? {
  do {
    return try parse()
  } catch let ResourceParsingError.ParsingFailed(humanReadableError) {
    warn(humanReadableError)
    return nil
  } catch ResourceParsingError.UnsupportedExtension {
    return nil
  } catch {
    return nil
  }
}

struct Resources {
  let assetFolders: [AssetFolder]
  let fonts: [Font]
  let nibs: [Nib]
  let storyboards: [Storyboard]

  let reusables: [Reusable]

  init(resourceURLs: [NSURL], fileManager: NSFileManager) {
    assetFolders = resourceURLs.flatMap { url in tryResourceParsing { try AssetFolder(url: url, fileManager: fileManager) } }
    fonts = resourceURLs.flatMap { url in tryResourceParsing { try Font(url: url) } }
    nibs = resourceURLs.flatMap { url in tryResourceParsing { try Nib(url: url) } }
    storyboards = resourceURLs.flatMap { url in tryResourceParsing { try Storyboard(url: url) } }

    reusables = (nibs.map { $0 as ReusableContainer } + storyboards.map { $0 as ReusableContainer })
      .flatMap { $0.reusables }
  }
}

func generateResourceStructsWithResources(resources: Resources) -> (Struct, Struct) {
  // Generate resource file contents
  let storyboardStructAndFunction = storyboardStructAndFunctionFromStoryboards(resources.storyboards)

  let nibStructs = nibStructFromNibs(resources.nibs)

  let externalResourceStruct = Struct(
    type: Type(name: "R"),
    lets: [],
    vars: [],
    functions: [
      storyboardStructAndFunction.1,
    ],
    structs: [
      imageStructFromAssetFolders(resources.assetFolders),
      fontStructFromFonts(resources.fonts),
      segueStructFromStoryboards(resources.storyboards),
      storyboardStructAndFunction.0,
      nibStructs.extern,
      reuseIdentifierStructFromReusables(resources.reusables),
    ]
  )

  let internalResourceStruct = Struct(
    type: Type(name: "_R"),
    implements: [],
    lets: [],
    vars: [],
    functions: [],
    structs: [
      nibStructs.intern
    ]
  )

  return (internalResourceStruct, externalResourceStruct)
}
