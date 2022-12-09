//
//  GeneratedId.swift
//  R.swift
//
//  Created by Tom Lokhorst on 2022-07-15.
//

import Foundation

private let generatedIdRegex = try! NSRegularExpression(pattern: #"^\w\w\w-\w\w-\w\w\w$"#)
func isGenerated(id input: String) -> Bool {
    generatedIdRegex.firstMatch(in: input, range: NSRange(location: 0, length: input.utf16.count)) != nil
}
