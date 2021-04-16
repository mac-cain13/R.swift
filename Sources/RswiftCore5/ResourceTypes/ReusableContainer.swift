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
}

protocol ReusableContainer {
  var reusables: [Reusable] { get }
}
