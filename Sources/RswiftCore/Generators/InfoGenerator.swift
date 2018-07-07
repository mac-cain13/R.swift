//
//  InfoGenerator.swift
//  Commander
//
//  Created by Tom Lokhorst on 2018-07-07.
//

import Foundation

struct InfoStructGenerator: ExternalOnlyStructGenerator {
  private let buildConfigurations: [BuildConfiguration]

  init(buildConfigurations: [BuildConfiguration]) {
    self.buildConfigurations = buildConfigurations
  }

  func generatedStruct(at externalAccessLevel: AccessLevel, prefix: SwiftIdentifier) -> Struct {
    fatalError()
  }
}
