//
//  Identifier.swift
//  R.swift Library
//
//  Created by Mathijs Kadijk on 06-12-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import Foundation

public protocol Identifier: CustomStringConvertible {
  var identifier: String { get }
}

extension Identifier {
  public var description: String {
    return identifier
  }
}
