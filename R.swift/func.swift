//
//  func.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 14-12-14.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

// MARK: Types

let ResourceFilename = "R.generated.swift"

struct AssetFolder {
  let name: String
  let imageAssets: [String]

  init(url: NSURL, fileManager: NSFileManager) {
    name = url.filename!

    let contents = fileManager.contentsOfDirectoryAtURL(url, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsHiddenFiles, error: nil) as [NSURL]
    imageAssets = contents.map { $0.filename! }
  }
}

// MARK: Functions

func inputDirectories(processInfo: NSProcessInfo) -> [NSURL] {
  return processInfo.arguments.skip(1).map { NSURL(fileURLWithPath: $0 as String)! }
}

func filterDirectoryContentsRecursively(fileManager: NSFileManager, filter: (NSURL) -> Bool)(url: NSURL) -> [NSURL] {
  var assetFolders = [NSURL]()

  if let enumerator = fileManager.enumeratorAtURL(url, includingPropertiesForKeys: [NSURLIsDirectoryKey], options: NSDirectoryEnumerationOptions.SkipsHiddenFiles|NSDirectoryEnumerationOptions.SkipsPackageDescendants, errorHandler: nil) {

    while let enumeratorItem: AnyObject = enumerator.nextObject() {
      if let url = enumeratorItem as? NSURL {
        if filter(url) {
          assetFolders.append(url)
          enumerator.skipDescendants()
        }
      }
    }

  }

  return assetFolders
}

func swiftStructForAssetFolder(assetFolder: AssetFolder) -> String {
  return assetFolder.imageAssets.reduce("  struct \(sanitizedSwiftName(assetFolder.name)) {\n") {
    $0 + "    class var \(sanitizedSwiftName($1)): UIImage { return UIImage(named: \"\($1)\") }\n"
  } + "  } \n"
}

func sanitizedSwiftName(name: String) -> String {
  var components = name.componentsSeparatedByString("-")
  let firstComponent = components.removeAtIndex(0)
  return components.reduce(firstComponent) { $0 + $1.capitalizedString }.lowercaseFirstCharacter
}

func writeResourceFile(code: String, toFolderURL folderURL: NSURL) {
  let outputURL = folderURL.URLByAppendingPathComponent(ResourceFilename)
  code.writeToURL(outputURL, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
}
