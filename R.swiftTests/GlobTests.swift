//
//  Created by Eric Firestone on 3/22/16.
//  Copyright © 2016 Square, Inc. All rights reserved.
//  Released under the Apache v2 License.
//
//  Adapted from https://gist.github.com/blakemerryman/76312e1cbf8aec248167
//  Adapted from https://gist.github.com/efirestone/ce01ae109e08772647eb061b3bb387c3

import XCTest

class GlobTests : XCTestCase {
  
  let tmpFiles = ["foo", "bar", "baz", "dir1/file1.ext", "dir1/dir2/dir3/file2.ext", "dir1/file1.extfoo"]
  var tmpDir = ""
  
  override func setUp() {
    super.setUp()
    
    var tmpDirTmpl = "/tmp/glob-test.XXXXX".cString(using: .utf8)!
    self.tmpDir = String(validatingUTF8: mkdtemp(&tmpDirTmpl))!
    
    let flags = S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH
    mkdir("\(tmpDir)/dir1/", flags)
    mkdir("\(tmpDir)/dir1/dir2", flags)
    mkdir("\(tmpDir)/dir1/dir2/dir3", flags)
    
    for file in tmpFiles {
      close(open("\(tmpDir)/\(file)", O_CREAT))
    }
  }
  
  override func tearDown() {
    for file in tmpFiles {
      unlink("\(tmpDir)/\(file)")
    }
    rmdir("\(tmpDir)/dir1/dir2/dir3")
    rmdir("\(tmpDir)/dir1/dir2")
    rmdir("\(tmpDir)/dir1")
    rmdir(self.tmpDir)
    
    super.tearDown()
  }
  
  func testBraces() {
    let pattern = "\(tmpDir)/ba{r,y,z}"
    let glob = Glob(pattern: pattern)
    var contents = [String]()
    for file in glob {
      contents.append(file)
    }
    XCTAssertEqual(contents, ["\(tmpDir)/bar", "\(tmpDir)/baz"], "matching with braces failed")
  }
  
  func testNothingMatches() {
    let pattern = "\(tmpDir)/nothing"
    let glob = Glob(pattern: pattern)
    var contents = [String]()
    for file in glob {
      contents.append(file)
    }
    XCTAssertEqual(contents, [], "expected empty list of files")
  }
  
  func testDirectAccess() {
    let pattern = "\(tmpDir)/ba{r,y,z}"
    let glob = Glob(pattern: pattern)
    XCTAssertEqual(glob.paths, ["\(tmpDir)/bar", "\(tmpDir)/baz"], "matching with braces failed")
  }
  
  func testIterateTwice() {
    let pattern = "\(tmpDir)/ba{r,y,z}"
    let glob = Glob(pattern: pattern)
    var contents1 = [String]()
    var contents2 = [String]()
    for file in glob {
      contents1.append(file)
    }
    let filesAfterOnce = glob.paths
    for file in glob {
      contents2.append(file)
    }
    XCTAssertEqual(contents1, contents2, "results for calling for-in twice are the same")
    XCTAssertEqual(glob.paths, filesAfterOnce, "calling for-in twice doesn't only memoizes once")
  }
  
  func testIndexing() {
    let pattern = "\(tmpDir)/ba{r,y,z}"
    let glob = Glob(pattern: pattern)
    XCTAssertEqual(glob[0], "\(tmpDir)/bar", "indexing")
  }
  
  // MARK: - Globstar - Bash v3
  
  func testGlobstarBashV3NoSlash() {
    // Should be the equivalent of "ls -d -1 /(tmpdir)/**"
    let pattern = "\(tmpDir)/**"
    let glob = Glob(pattern: pattern, behavior: GlobBehaviorBashV3)
    XCTAssertEqual(glob.paths, ["\(tmpDir)/bar", "\(tmpDir)/baz", "\(tmpDir)/dir1/", "\(tmpDir)/foo"])
  }
  
  func testGlobstarBashV3WithSlash() {
    // Should be the equivalent of "ls -d -1 /(tmpdir)/**/"
    let pattern = "\(tmpDir)/**/"
    let glob = Glob(pattern: pattern, behavior: GlobBehaviorBashV3)
    XCTAssertEqual(glob.paths, ["\(tmpDir)/dir1/"])
  }
  
  func testGlobstarBashV3WithSlashAndWildcard() {
    // Should be the equivalent of "ls -d -1 /(tmpdir)/**/*"
    let pattern = "\(tmpDir)/**/*"
    let glob = Glob(pattern: pattern, behavior: GlobBehaviorBashV3)
    XCTAssertEqual(glob.paths, ["\(tmpDir)/dir1/dir2/", "\(tmpDir)/dir1/file1.ext", "\(tmpDir)/dir1/file1.extfoo"])
  }
  
  func testDoubleGlobstarBashV3() {
    let pattern = "\(tmpDir)/**/dir2/**/*"
    let glob = Glob(pattern: pattern, behavior: GlobBehaviorBashV3)
    XCTAssertEqual(glob.paths, ["\(tmpDir)/dir1/dir2/dir3/file2.ext"])
  }
  
  // MARK: - Globstar - Bash v4
  
  func testGlobstarBashV4NoSlash() {
    // Should be the equivalent of "ls -d -1 /(tmpdir)/**"
    let pattern = "\(tmpDir)/**"
    let glob = Glob(pattern: pattern, behavior: GlobBehaviorBashV4)
    XCTAssertEqual(glob.paths, [
      "\(tmpDir)/",
      "\(tmpDir)/bar",
      "\(tmpDir)/baz",
      "\(tmpDir)/dir1/",
      "\(tmpDir)/dir1/dir2/",
      "\(tmpDir)/dir1/dir2/dir3/",
      "\(tmpDir)/dir1/dir2/dir3/file2.ext",
      "\(tmpDir)/dir1/file1.ext",
      "\(tmpDir)/dir1/file1.extfoo",
      "\(tmpDir)/foo"
      ])
  }
  
  func testGlobstarBashV4WithSlash() {
    // Should be the equivalent of "ls -d -1 /(tmpdir)/**/"
    let pattern = "\(tmpDir)/**/"
    let glob = Glob(pattern: pattern, behavior: GlobBehaviorBashV4)
    XCTAssertEqual(glob.paths, [
      "\(tmpDir)/",
      "\(tmpDir)/dir1/",
      "\(tmpDir)/dir1/dir2/",
      "\(tmpDir)/dir1/dir2/dir3/",
      ])
  }
  
  func testGlobstarBashV4WithSlashAndWildcard() {
    // Should be the equivalent of "ls -d -1 /(tmpdir)/**/*"
    let pattern = "\(tmpDir)/**/*"
    let glob = Glob(pattern: pattern, behavior: GlobBehaviorBashV4)
    XCTAssertEqual(glob.paths, [
      "\(tmpDir)/bar",
      "\(tmpDir)/baz",
      "\(tmpDir)/dir1/",
      "\(tmpDir)/dir1/dir2/",
      "\(tmpDir)/dir1/dir2/dir3/",
      "\(tmpDir)/dir1/dir2/dir3/file2.ext",
      "\(tmpDir)/dir1/file1.ext",
      "\(tmpDir)/dir1/file1.extfoo",
      "\(tmpDir)/foo",
      ])
  }
  
  func testDoubleGlobstarBashV4() {
    let pattern = "\(tmpDir)/**/dir2/**/*"
    let glob = Glob(pattern: pattern, behavior: GlobBehaviorBashV4)
    XCTAssertEqual(glob.paths, [
      "\(tmpDir)/dir1/dir2/dir3/",
      "\(tmpDir)/dir1/dir2/dir3/file2.ext",
      ])
  }
  
  func testDoubleGlobstarBashV4WithFileExtension() {
    // Should be the equivalent of "ls -d -1 /(tmpdir)/**/*.ext"
    // Should not find "\(tmpDir)/dir1/file1.extfoo" which the file extension prefix is .ext
    let pattern = "\(tmpDir)/**/*.ext"
    let glob = Glob(pattern: pattern, behavior: GlobBehaviorBashV4)
    XCTAssertEqual(glob.paths, [
      "\(tmpDir)/dir1/dir2/dir3/file2.ext",
      "\(tmpDir)/dir1/file1.ext"
      ])
  }
  
  // MARK: - Globstar - Gradle
  
  func testGlobstarGradleNoSlash() {
    // Should be the equivalent of
    // FileTree tree = project.fileTree((Object)'/tmp') {
    //   include 'glob-test.7m0Lp/**'
    // }
    //
    // Note that the sort order currently matches Bash and not Gradle
    let pattern = "\(tmpDir)/**"
    let glob = Glob(pattern: pattern, behavior: GlobBehaviorGradle)
    XCTAssertEqual(glob.paths, [
      "\(tmpDir)/bar",
      "\(tmpDir)/baz",
      "\(tmpDir)/dir1/dir2/dir3/file2.ext",
      "\(tmpDir)/dir1/file1.ext",
      "\(tmpDir)/dir1/file1.extfoo",
      "\(tmpDir)/foo",
      ])
  }
  
  func testGlobstarGradleWithSlash() {
    // Should be the equivalent of
    // FileTree tree = project.fileTree((Object)'/tmp') {
    //   include 'glob-test.7m0Lp/**/'
    // }
    //
    // Note that the sort order currently matches Bash and not Gradle
    let pattern = "\(tmpDir)/**/"
    let glob = Glob(pattern: pattern, behavior: GlobBehaviorGradle)
    XCTAssertEqual(glob.paths, [
      "\(tmpDir)/bar",
      "\(tmpDir)/baz",
      "\(tmpDir)/dir1/dir2/dir3/file2.ext",
      "\(tmpDir)/dir1/file1.ext",
      "\(tmpDir)/dir1/file1.extfoo",
      "\(tmpDir)/foo",
      ])
  }
  
  func testGlobstarGradleWithSlashAndWildcard() {
    // Should be the equivalent of
    // FileTree tree = project.fileTree((Object)'/tmp') {
    //   include 'glob-test.7m0Lp/**/*'
    // }
    //
    // Note that the sort order currently matches Bash and not Gradle
    let pattern = "\(tmpDir)/**/*"
    let glob = Glob(pattern: pattern, behavior: GlobBehaviorGradle)
    XCTAssertEqual(glob.paths, [
      "\(tmpDir)/bar",
      "\(tmpDir)/baz",
      "\(tmpDir)/dir1/dir2/dir3/file2.ext",
      "\(tmpDir)/dir1/file1.ext",
      "\(tmpDir)/dir1/file1.extfoo",
      "\(tmpDir)/foo",
      ])
  }
  
  func testDoubleGlobstarGradle() {
    // Should be the equivalent of
    // FileTree tree = project.fileTree((Object)'/tmp') {
    //   include 'glob-test.7m0Lp/**/dir2/**/*'
    // }
    //
    // Note that the sort order currently matches Bash and not Gradle
    let pattern = "\(tmpDir)/**/dir2/**/*"
    let glob = Glob(pattern: pattern, behavior: GlobBehaviorGradle)
    XCTAssertEqual(glob.paths, [
      "\(tmpDir)/dir1/dir2/dir3/file2.ext",
      ])
  }
}
