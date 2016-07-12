//
//  Unifiable.swift
//  R.swift
//
//  Created by Tom Lokhorst on 2016-04-30.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

protocol Unifiable {
  func unify(with: Self) -> Self?
}

extension Array where Element : Unifiable {
  func unify(with other: [Element]) -> [Element]? {
    var result = self

    for (ix, right) in other.enumerated() {
      if let left = result[safe: ix] {
        if let unified = left.unify(with: right) {
          result[ix] = unified
        }
        else {
          return nil
        }
      }
      else {
        result.append(right)
      }
    }

    return result
  }
}
