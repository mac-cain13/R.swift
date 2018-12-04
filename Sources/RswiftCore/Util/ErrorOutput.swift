//
//  ErrorOutput.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 11-12-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

public func warn(_ warning: String) {
  print("warning: [R.swift] \(warning)")
}

func fail(_ error: String) {
  print("error: [R.swift] \(error)")
}
