//
//  ParsingInformation.swift
//  R.swift
//
//  Created by Andrey Tchernov on 04.12.2018.
//  From: https://github.com/icerockdevelop/R.swift
//  License: MIT License
//

import Foundation

public struct ParsingInformation {
  let useStringsHierarchy: Bool
  public init (useStringsHierarchy: Bool) {
    self.useStringsHierarchy = useStringsHierarchy
  }
  //TODO: Prepare for Json/Plist initialization
}
