//
//  ReusableContainer.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 10-12-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import Foundation

typealias Reusable = (identifier: String, type: Type)

protocol ReusableContainer {
  var reusables: [Reusable] { get }
}
