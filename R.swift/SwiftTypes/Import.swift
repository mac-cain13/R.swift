//
//  Import.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 11-12-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import Foundation

struct Import: Hashable {
  let moduleName: String

  var hashValue: Int {
    return moduleName.hashValue
  }
}

func ==(lhs: Import, rhs: Import) -> Bool {
  return lhs.hashValue == rhs.hashValue
}
