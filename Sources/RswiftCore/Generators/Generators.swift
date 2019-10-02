//
//  Generators.swift
//  Commander
//
//  Created by Tom Lokhorst on 2019-09-21.
//

import Foundation

public enum Generator: String, CaseIterable {
  case image
  case color
  case font
  case segue
  case storyboard
  case nib
  case reuseIdentifier
  case file
  case string
  case id

  static func parseGenerators(_ string: String) -> ([Generator], [String]) {
    var generators: [Generator] = []
    var unknowns: [String] = []

    let parts = string.components(separatedBy: ",")
      .map { $0.trimmingCharacters(in: CharacterSet.whitespaces) }

    for part in parts {
      if let generator = Generator(rawValue: part) {
        generators.append(generator)
      } else {
        unknowns.append(part)
      }
    }

    return (generators, unknowns)
  }
}
