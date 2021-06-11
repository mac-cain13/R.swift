//
//  Resources.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 11-06-21.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

struct Bundle {
  let bundleName: String
  let resources: Resources

  init(bundleUrl: URL, fileManager: FileManager) {
    let bundleNameWithExtension = bundleUrl.lastPathComponent
    bundleName = bundleNameWithExtension.replacingOccurrences(of: ".bundle", with: "")

    let resourceURLs = Bundle.resourceURLs(for: bundleUrl, fileManager: fileManager)
    resources = Resources(resourceURLs: resourceURLs, fileManager: fileManager)
  }
}

private extension Bundle {
  static func resourceURLs(for bundleUrl: URL, fileManager: FileManager) -> [URL] {
    var resourceURLs = [URL]()
    
    let resourceDirectoryTypes: [WhiteListedExtensionsResourceType.Type] = [AssetFolder.self]
    var resourceDirectorySuffixes = Set<String>()
    resourceDirectoryTypes.forEach { resourceType in
      resourceType.supportedExtensions.forEach { ext in
        resourceDirectorySuffixes.insert(ext)
      }
    }

    var prefixesToSkip = Set<String>()
    prefixesToSkip.insert(".") // Ignore files like .DS_Store, etc.
    
    let isResourceDirectory: ((URL) -> Bool) = { url in
      for suffix in resourceDirectorySuffixes {
        if url.absoluteString.hasSuffix(suffix + "/") {
          return true
        }
      }
      return false
    }
    
    let shouldSkip: ((URL) -> Bool) = { url in
      let name = url.lastPathComponent
      for prefix in prefixesToSkip {
        if name.hasPrefix(prefix) {
          return true
        }
      }
      return false
    }
    
    guard let enumerator = fileManager.enumerator(at: bundleUrl, includingPropertiesForKeys: nil) else {
      return []
    }

    for case let itemURL as URL in enumerator {
      if itemURL.isDirectory() {
        if isResourceDirectory(itemURL) {
          resourceURLs.append(itemURL)
          enumerator.skipDescendents()
        }
      } else if !shouldSkip(itemURL) {
        resourceURLs.append(itemURL)
      }
    }
    
    return resourceURLs
  }
}

fileprivate extension URL {
  func isDirectory() -> Bool {
    do {
      let value = try resourceValues(forKeys:[.isDirectoryKey])
      return value.isDirectory ?? false
    }
    catch {
      return false
    }
  }
}
