//
//  NameCatalog.swift
//  RswiftCore
//
//  Created by Tom Lokhorst on 2020-05-08.
//

import Foundation

struct NameCatalog: Hashable, Comparable {
  let name: String
  let catalog: String?

  var isSystemCatalog: Bool {
    return
         catalog == "System" // for colors
      || catalog == "system" // for images
  }

  static func < (lhs: NameCatalog, rhs: NameCatalog) -> Bool {
    lhs.name < rhs.name
  }
}
