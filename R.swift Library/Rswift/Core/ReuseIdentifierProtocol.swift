//
//  ReuseIdentifierProtocol.swift
//  R.swift Library
//
//  Created by Mathijs Kadijk on 06-12-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import Foundation

public protocol ReuseIdentifierProtocol: Identifier {
  typealias ReusableType
}

public struct ReuseIdentifier<Reusable>: ReuseIdentifierProtocol {
  public typealias ReusableType = Reusable

  public let identifier: String

  public init(identifier: String) {
    self.identifier = identifier
  }
}
