//
//  Types.swift
//  R.swift Library
//
//  Created by Mathijs Kadijk on 04-12-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import Foundation
import UIKit

public protocol Identifier: CustomStringConvertible {
  var identifier: String { get }
}

extension Identifier {
  public var description: String {
    return identifier
  }
}

public protocol ReuseIdentifierProtocol: Identifier {
  typealias ReusableType
}

public struct ReuseIdentifier<Reusable>: ReuseIdentifierProtocol {
  public typealias ReusableType = Reusable

  public let identifier: String

  public init(identifier: String) {
    self.identifier = identifier
  }
}

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

public protocol NibResource {
  var bundle: NSBundle? { get }
  var instance: UINib { get }
  var name: String { get }
}

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

public extension UIViewController {
  public convenience init(nib: NibResource) {
    self.init(nibName: nib.name, bundle: nib.bundle)
  }
}

public extension UIViewController {
  public func performSegueWithIdentifier<Identifier: StoryboardSegueIdentifierProtocol>(identifier: Identifier, sender: AnyObject?) {
    performSegueWithIdentifier(identifier.identifier, sender: sender)
  }
}

public extension UIStoryboardSegue {
  func typedInfoWithIdentifier<Identifier: StoryboardSegueIdentifierProtocol, Segue, Source, Destination where Segue == Identifier.SegueType, Source == Identifier.SourceType, Destination == Identifier.DestinationType>(identifier: Identifier) -> TypedStoryboardSegueInfo<Segue, Source, Destination>? {
    guard self.identifier == identifier.identifier else { return nil }
    return TypedStoryboardSegueInfo(segue: self)
  }
}
