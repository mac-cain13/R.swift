//
//  Created by Eric Firestone on 3/22/16.
//  Copyright © 2016 Square, Inc. All rights reserved.
//  Released under the Apache v2 License.
//
//  Adapted from https://gist.github.com/blakemerryman/76312e1cbf8aec248167

import Foundation


let GlobBehaviorBashV3 = Glob.Behavior(
  supportsGlobstar: false,
  includesFilesFromRootOfGlobstar: false,
  includesDirectoriesInResults: true,
  includesFilesInResultsIfTrailingSlash: false
)
let GlobBehaviorBashV4 = Glob.Behavior(
  supportsGlobstar: true, // Matches Bash v4 with "shopt -s globstar" option
  includesFilesFromRootOfGlobstar: true,
  includesDirectoriesInResults: true,
  includesFilesInResultsIfTrailingSlash: false
)
let GlobBehaviorGradle = Glob.Behavior(
  supportsGlobstar: true,
  includesFilesFromRootOfGlobstar: true,
  includesDirectoriesInResults: false,
  includesFilesInResultsIfTrailingSlash: true
)


/**
 Finds files on the file system using pattern matching.
 */
class Glob: CollectionType {
  
  /**
   * Different glob implementations have different behaviors, so the behavior of this
   * implementation is customizable.
   */
  struct Behavior {
    // If true then a globstar ("**") causes matching to be done recursively in subdirectories.
    // If false then "**" is treated the same as "*"
    let supportsGlobstar: Bool
    
    // If true the results from the directory where the globstar is declared will be included as well.
    // For example, with the pattern "dir/**/*.ext" the fie "dir/file.ext" would be included if this
    // property is true, and would be omitted if it's false.
    let includesFilesFromRootOfGlobstar: Bool
    
    // If false then the results will not include directory entries. This does not affect recursion depth.
    let includesDirectoriesInResults: Bool
    
    // If false and the last characters of the pattern are "**/" then only directories are returned in the results.
    let includesFilesInResultsIfTrailingSlash: Bool
  }
  
  static var defaultBehavior = GlobBehaviorBashV4
  
  private var isDirectoryCache = [String: Bool]()
  
  let behavior: Behavior
  var paths = [String]()
  var startIndex: Int { return paths.startIndex }
  var endIndex: Int   { return paths.endIndex   }
  
  init(pattern: String, behavior: Behavior = Glob.defaultBehavior) {
    
    self.behavior = behavior
    
    var adjustedPattern = pattern
    let hasTrailingGlobstarSlash = pattern.hasSuffix("**/")
    var includeFiles = !hasTrailingGlobstarSlash
    
    if behavior.includesFilesInResultsIfTrailingSlash {
      includeFiles = true
      if hasTrailingGlobstarSlash {
        // Grab the files too.
        adjustedPattern += "*"
      }
    }
    
    let patterns = behavior.supportsGlobstar ? expandGlobstar(adjustedPattern) : [adjustedPattern]
    
    for pattern in patterns {
      var gt = glob_t()
      if executeGlob(pattern, gt: &gt) {
        populateFiles(gt, includeFiles: includeFiles)
      }
      
      globfree(&gt)
    }
    
    paths = Array(Set(paths)).sort { lhs, rhs in
      lhs.compare(rhs) != NSComparisonResult.OrderedDescending
    }
    
    clearCaches()
  }
  
  // MARK: Private
  
  private var globalFlags = GLOB_TILDE | GLOB_BRACE | GLOB_MARK
  
  private func executeGlob(pattern: UnsafePointer<CChar>, gt: UnsafeMutablePointer<glob_t>) -> Bool {
    return 0 == glob(pattern, globalFlags, nil, gt)
  }
  
  private func expandGlobstar(pattern: String) -> [String] {
    guard pattern.containsString("**") else {
      return [pattern]
    }
    
    var results = [String]()
    var parts = pattern.componentsSeparatedByString("**")
    let firstPart = parts.removeFirst()
    var lastPart = parts.joinWithSeparator("**")
    
    let fileManager = NSFileManager.defaultManager()
    
    var directories: [String]
    
    do {
      directories = try fileManager.subpathsOfDirectoryAtPath(firstPart).flatMap { subpath in
        let fullPath = NSString(string: firstPart).stringByAppendingPathComponent(subpath)
        var isDirectory = ObjCBool(false)
        if fileManager.fileExistsAtPath(fullPath, isDirectory: &isDirectory) && isDirectory {
          return fullPath
        } else {
          return nil
        }
      }
    } catch {
      directories = []
      print("Error parsing file system item: \(error)")
    }
    
    if behavior.includesFilesFromRootOfGlobstar {
      // Check the base directory for the glob star as well.
      directories.insert(firstPart, atIndex: 0)
      
      // Include the globstar root directory ("dir/") in a pattern like "dir/**" or "dir/**/"
      if lastPart.isEmpty {
        results.append(firstPart)
      }
    }
    
    if lastPart.isEmpty {
      lastPart = "*"
    }
    for directory in directories {
      let partiallyResolvedPattern = NSString(string: directory).stringByAppendingPathComponent(lastPart)
      results.appendContentsOf(expandGlobstar(partiallyResolvedPattern))
    }
    
    return results
  }
  
  private func isDirectory(path: String) -> Bool {
    var isDirectory = isDirectoryCache[path]
    if let isDirectory = isDirectory {
      return isDirectory
    }
    
    var isDirectoryBool = ObjCBool(false)
    isDirectory = NSFileManager.defaultManager().fileExistsAtPath(path, isDirectory: &isDirectoryBool) && isDirectoryBool
    isDirectoryCache[path] = isDirectory!
    
    return isDirectory!
  }
  
  private func clearCaches() {
    isDirectoryCache.removeAll()
  }
  
  private func populateFiles(gt: glob_t, includeFiles: Bool) {
    let includeDirectories = behavior.includesDirectoriesInResults
    
    for i in 0..<Int(gt.gl_matchc) {
      if let path = String.fromCString(gt.gl_pathv[i]) {
        if !includeFiles || !includeDirectories {
          let isDirectory = self.isDirectory(path)
          if (!includeFiles && !isDirectory) || (!includeDirectories && isDirectory) {
            continue
          }
        }
        
        paths.append(path)
      }
    }
  }
  
  // MARK: Subscript Support
  
  subscript(i: Int) -> String {
    return paths[i]
  }
}
