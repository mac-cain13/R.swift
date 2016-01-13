//
//  ReusableContainer.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 10-12-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import Foundation

struct Reusable: Hashable {
  let identifier: String
  let type: Type

  var hashValue: Int {
    return "\(identifier)|\(type)".hashValue
  }
}

func ==(lhs: Reusable, rhs: Reusable) -> Bool {
  return lhs.hashValue == rhs.hashValue
}

protocol ReusableContainer {
  var reusables: [Reusable] { get }
}
