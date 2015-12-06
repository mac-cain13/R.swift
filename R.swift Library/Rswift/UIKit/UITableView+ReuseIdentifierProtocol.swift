//
//  UITableView+ReuseIdentifierProtocol.swift
//  R.swift Library
//
//  Created by Mathijs Kadijk on 06-12-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import Foundation
import UIKit

public extension UITableView {
  public func dequeueReusableCellWithIdentifier<Identifier: ReuseIdentifierProtocol where Identifier.ReusableType: UITableViewCell>(identifier: Identifier, forIndexPath indexPath: NSIndexPath?) -> Identifier.ReusableType? {
    if let indexPath = indexPath {
      return dequeueReusableCellWithIdentifier(identifier.identifier, forIndexPath: indexPath) as? Identifier.ReusableType
    }
    return dequeueReusableCellWithIdentifier(identifier.identifier) as? Identifier.ReusableType
  }

  public func dequeueReusableCellWithIdentifier<Identifier: ReuseIdentifierProtocol where Identifier.ReusableType: UITableViewCell>(identifier: Identifier) -> Identifier.ReusableType? {
    return dequeueReusableCellWithIdentifier(identifier.identifier) as? Identifier.ReusableType
  }

  public func dequeueReusableHeaderFooterViewWithIdentifier<Identifier: ReuseIdentifierProtocol where Identifier.ReusableType: UITableViewCell>(identifier: Identifier) -> Identifier.ReusableType? {
    return dequeueReusableHeaderFooterViewWithIdentifier(identifier.identifier) as? Identifier.ReusableType
  }

  public func registerNib<Resource: NibResource where Resource: ReuseIdentifierProtocol, Resource.ReusableType: UITableViewCell>(nibResource: Resource) {
    registerNib(nibResource.instance, forCellReuseIdentifier: nibResource.identifier)
  }

  public func registerNibForHeaderFooterView<Resource: NibResource where Resource: ReuseIdentifierProtocol, Resource.ReusableType: UIView>(nibResource: Resource) {
    registerNib(nibResource.instance, forHeaderFooterViewReuseIdentifier: nibResource.identifier)
  }

  public func registerNibs<Resource: NibResource where Resource: ReuseIdentifierProtocol, Resource.ReusableType: UITableViewCell>(nibResources: [Resource]) {
    nibResources.forEach(registerNib)
  }
}
