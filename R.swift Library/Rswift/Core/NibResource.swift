//
//  NibResource.swift
//  R.swift Library
//
//  Created by Mathijs Kadijk on 06-12-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import Foundation

public protocol NibResource {
  var bundle: NSBundle? { get }
  var instance: UINib { get }
  var name: String { get }
}
