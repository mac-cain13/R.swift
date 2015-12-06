//
//  UIViewController+NibResource.swift
//  R.swift Library
//
//  Created by Mathijs Kadijk on 06-12-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import Foundation
import UIKit

public extension UIViewController {
  public convenience init(nib: NibResource) {
    self.init(nibName: nib.name, bundle: nib.bundle)
  }
}
