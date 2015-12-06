//
//  UIStoryboardSegue+StoryboardSegueIdentifierProtocol.swift
//  R.swift Library
//
//  Created by Mathijs Kadijk on 06-12-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import Foundation
import UIKit

public extension UIStoryboardSegue {
  func typedInfoWithIdentifier<Identifier: StoryboardSegueIdentifierProtocol, Segue, Source, Destination where Segue == Identifier.SegueType, Source == Identifier.SourceType, Destination == Identifier.DestinationType>(identifier: Identifier) -> TypedStoryboardSegueInfo<Segue, Source, Destination>? {
    guard self.identifier == identifier.identifier else { return nil }
    return TypedStoryboardSegueInfo(segue: self)
  }
}
