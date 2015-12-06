//
//  TypedStoryboardSegueInfo+UIStoryboardSegue.swift
//  R.swift Library
//
//  Created by Mathijs Kadijk on 06-12-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import Foundation
import UIKit

extension TypedStoryboardSegueInfo {
  public init?(segue: UIStoryboardSegue) {
    guard let identifier = segue.identifier,
      sourceViewController = segue.sourceViewController as? Source,
      destinationViewController = segue.destinationViewController as? Destination,
      segue = segue as? Segue
      else {
        return nil
    }

    self.segue = segue
    self.identifier = identifier
    self.sourceViewController = sourceViewController
    self.destinationViewController = destinationViewController
  }
}
