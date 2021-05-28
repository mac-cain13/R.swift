//
//  StructGenerator.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 06-09-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

enum BundleExpression: CustomStringConvertible {
  case hostingBundle
  case customBundle(String)
  
  var description: String {
    switch self {
    case .hostingBundle:
      return "R.hostingBundle"
    case .customBundle(let value):
      return value
    }
  }
}

protocol StructGenerator {
  typealias Result = (externalStruct: Struct, internalStruct: Struct?)

  func generatedStructs(at externalAccessLevel: AccessLevel, prefix: SwiftIdentifier, bundle: BundleExpression) -> Result
}

protocol ExternalOnlyStructGenerator: StructGenerator {
  func generatedStruct(at externalAccessLevel: AccessLevel, prefix: SwiftIdentifier, bundle: BundleExpression) -> Struct
}

extension ExternalOnlyStructGenerator {
  func generatedStructs(at externalAccessLevel: AccessLevel, prefix: SwiftIdentifier, bundle: BundleExpression) -> StructGenerator.Result {
    return (
      generatedStruct(at: externalAccessLevel, prefix: prefix, bundle: bundle),
      nil
    )
  }
}
