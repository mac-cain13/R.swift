//
//  ReusableContainer.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 10-12-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

struct Reusable: Hashable {
  let identifier: String
  let type: Type

  #if swift(<4.2)
  var hashValue: Int {
    return "\(identifier)|\(type)".hashValue
  }
  #else
  func hash(into hasher: inout Hasher) {
    hasher.combine("\(identifier)|\(type)")
  }
  #endif
}

func == (lhs: Reusable, rhs: Reusable) -> Bool {
  return lhs.hashValue == rhs.hashValue
}

protocol ReusableContainer {
  var reusables: [Reusable] { get }
}
