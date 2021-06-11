//
//  Resources.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 08-12-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

enum ResourceParsingError: Error {
  case unsupportedExtension(givenExtension: String?, supportedExtensions: Set<String>)
  case parsingFailed(String)
}

struct Resources {
  let assetFolders: [AssetFolder]
  let images: [Image]
  let fonts: [Font]
  let nibs: [Nib]
  let storyboards: [Storyboard]
  let resourceFiles: [ResourceFile]
  let localizableStrings: [LocalizableStrings]
  let bundles: [Bundle]

  let reusables: [Reusable]
  
  init(resourceURLs: [URL], fileManager: FileManager) {
    
    var assetFolders = [AssetFolder]()
    var images = [Image]()
    var fonts = [Font]()
    var nibs = [Nib]()
    var storyboards = [Storyboard]()
    var resourceFiles = [ResourceFile]()
    var localizableStrings = [LocalizableStrings]()
    var bundles = [Bundle]()

    resourceURLs.forEach { url in
      if let nib = tryResourceParsing({ try Nib(url: url) }) {
        nibs.append(nib)
      } else if let image = tryResourceParsing({ try Image(url: url) }) {
        images.append(image)
      } else if let asset = tryResourceParsing({ try AssetFolder(url: url, fileManager: fileManager) }) {
        assetFolders.append(asset)
      } else if let font = tryResourceParsing({ try Font(url: url) }) {
        fonts.append(font)
      } else if let storyboard = tryResourceParsing({ try Storyboard(url: url) }) {
        storyboards.append(storyboard)
      } else if let localizableString = tryResourceParsing({ try LocalizableStrings(url: url) }) {
        localizableStrings.append(localizableString)
      }

      // All previous assets can also possibly be used as files
      if let resourceFile = tryResourceParsing({ try ResourceFile(url: url) }) {
        if resourceFile.pathExtension == "bundle" {
          let bundle = Bundle(bundleUrl: url, fileManager: fileManager)
          if bundle.resources.resourceFiles.count != 0 {
            bundles.append(bundle)
          }
        } else {
          resourceFiles.append(resourceFile)
        }
      }
    }
    
    self.assetFolders = assetFolders
    self.images = images
    self.fonts = fonts
    self.nibs = nibs
    self.storyboards = storyboards
    self.resourceFiles = resourceFiles
    self.localizableStrings = localizableStrings
    self.bundles = bundles
    
    reusables = (nibs.map { $0 as ReusableContainer } + storyboards.map { $0 as ReusableContainer })
      .flatMap { $0.reusables }
  }
}

private func tryResourceParsing<T>(_ parse: () throws -> T) -> T? {
  do {
    return try parse()
  } catch let ResourceParsingError.parsingFailed(humanReadableError) {
    warn(humanReadableError)
    return nil
  } catch ResourceParsingError.unsupportedExtension {
    return nil
  } catch {
    return nil
  }
}
