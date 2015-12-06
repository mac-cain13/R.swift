//
//  StoryboardSegueIdentifierProtocol.swift
//  R.swift Library
//
//  Created by Mathijs Kadijk on 06-12-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import Foundation

public protocol StoryboardSegueIdentifierProtocol: Identifier {
  typealias SegueType
  typealias SourceType
  typealias DestinationType
}

public struct StoryboardSegueIdentifier<Segue, Source, Destination>: StoryboardSegueIdentifierProtocol {
  public typealias SegueType = Segue
  public typealias SourceType = Source
  public typealias DestinationType = Destination

  public let identifier: String

  public init(identifier: String) {
    self.identifier = identifier
  }
}

public struct TypedStoryboardSegueInfo<Segue, Source, Destination>: StoryboardSegueIdentifierProtocol {
  public typealias SegueType = Segue
  public typealias SourceType = Source
  public typealias DestinationType = Destination

  public let destinationViewController: Destination
  public let identifier: String
  public let segue: Segue
  public let sourceViewController: Source
}
