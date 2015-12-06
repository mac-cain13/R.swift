//
//  UICollectionView+ReuseIdentifierProtocol.swift
//  R.swift Library
//
//  Created by Mathijs Kadijk on 06-12-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import Foundation
import UIKit

public extension UICollectionView {
  public func dequeueReusableCellWithReuseIdentifier<Identifier: ReuseIdentifierProtocol where Identifier.ReusableType: UICollectionReusableView>(identifier: Identifier, forIndexPath indexPath: NSIndexPath) -> Identifier.ReusableType? {
    return dequeueReusableCellWithReuseIdentifier(identifier.identifier, forIndexPath: indexPath) as? Identifier.ReusableType
  }

  public func dequeueReusableSupplementaryViewOfKind<Identifier: ReuseIdentifierProtocol where Identifier.ReusableType: UICollectionReusableView>(elementKind: String, withReuseIdentifier identifier: Identifier, forIndexPath indexPath: NSIndexPath) -> Identifier.ReusableType? {
    return dequeueReusableSupplementaryViewOfKind(elementKind, withReuseIdentifier: identifier.identifier, forIndexPath: indexPath) as? Identifier.ReusableType
  }

  public func registerNib<Resource: NibResource where Resource: ReuseIdentifierProtocol, Resource.ReusableType: UICollectionViewCell>(nibResource: Resource) {
    registerNib(nibResource.instance, forCellWithReuseIdentifier: nibResource.identifier)
  }

  public func registerNib<Resource: NibResource where Resource: ReuseIdentifierProtocol, Resource.ReusableType: UICollectionReusableView>(nibResource: Resource, forSupplementaryViewOfKind kind: String) {
    registerNib(nibResource.instance, forSupplementaryViewOfKind: kind, withReuseIdentifier: nibResource.identifier)
  }

  public func registerNibs<Resource: NibResource where Resource: ReuseIdentifierProtocol, Resource.ReusableType: UICollectionViewCell>(nibResources: [Resource]) {
    nibResources.forEach(registerNib)
  }

  public func registerNibs<Resource: NibResource where Resource: ReuseIdentifierProtocol, Resource.ReusableType: UICollectionReusableView>(nibResources: [Resource], forSupplementaryViewOfKind kind: String) {
    nibResources.forEach { self.registerNib($0, forSupplementaryViewOfKind: kind) }
  }
}
