//
//  Array+Extensions.swift
//  RswiftGenerators
//
//  Created by Tom Lokhorst on 2022-10-11.
//

import Foundation

extension Array where Element: Comparable, Element: Hashable {
    func uniqueAndSorted() -> [Element] {
        Set(self).sorted()
    }
}
