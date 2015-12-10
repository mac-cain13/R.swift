//
//  func.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 14-12-14.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

// MARK: Helper functions

let indent = indentWithString(IndentationString)

func warn(warning: String) {
  print("warning: [R.swift] \(warning)")
}

func fail(error: String) {
  print("error: [R.swift] \(error)")
}

/*
Disallowed characters: whitespace, mathematical symbols, arrows, private-use and invalid Unicode points, line- and boxdrawing characters
Special rules: Can't begin with a number
*/
func sanitizedSwiftName(name: String, lowercaseFirstCharacter: Bool = true) -> String {
  var nameComponents = name.componentsSeparatedByCharactersInSet(BlacklistedCharacters)

  let firstComponent = nameComponents.removeAtIndex(0)
  let cleanedSwiftName = nameComponents.reduce(firstComponent) { $0 + $1.uppercaseFirstCharacter }

  let regex = try! NSRegularExpression(pattern: "^[0-9]+", options: .CaseInsensitive)
  let fullRange = NSRange(location: 0, length: cleanedSwiftName.characters.count)
  let sanitizedSwiftName = regex.stringByReplacingMatchesInString(cleanedSwiftName, options: NSMatchingOptions(rawValue: 0), range: fullRange, withTemplate: "")

  let capitalizedSwiftName = lowercaseFirstCharacter ? sanitizedSwiftName.lowercaseFirstCharacter : sanitizedSwiftName
  return SwiftKeywords.contains(capitalizedSwiftName) ? "`\(capitalizedSwiftName)`" : capitalizedSwiftName
}

func writeResourceFile(code: String, toFileURL fileURL: NSURL) {
  do {
    try code.writeToURL(fileURL, atomically: true, encoding: NSUTF8StringEncoding)
  } catch let error as NSError {
    fail(error.description)
  }
}

func readResourceFile(fileURL: NSURL) -> String? {
  do {
    return try String(contentsOfURL: fileURL, encoding: NSUTF8StringEncoding)
  } catch {
    return nil
  }
}
