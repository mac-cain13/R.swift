//
//  Unifiable.swift
//  R.swift
//
//  Created by Tom Lokhorst on 2016-04-30.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

protocol Unifiable {
  func unify(_ other: Self) -> Self?
}

extension Array where Element : Unifiable {
  func unify(_ other: [Element]) -> [Element]? {
    var result = self

    for (ix, right) in other.enumerated() {
      if let left = result[safe: ix] {
        if let unified = left.unify(right) {
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
