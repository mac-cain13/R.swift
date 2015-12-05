//
//  Types.swift
//  R.swift Library
//
//  Created by Mathijs Kadijk on 04-12-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
  public convenience init?(named name: String, inBundle bundle: NSBundle?) {
    if #available(iOS 8.0, *) {
      self.init(named: name, inBundle: bundle, compatibleWithTraitCollection: nil)
    } else {
      self.init(named: name)
    }
  }
}

public struct ReuseIdentifier<T>: CustomStringConvertible {
  public let identifier: String

  public var description: String { return identifier }

  public init(identifier: String) {
    self.identifier = identifier
  }
}

public struct StoryboardSegueIdentifier<Segue, Source, Destination>: CustomStringConvertible {
  public let identifier: String

  public var description: String { return identifier }

  public init(identifier: String) {
    self.identifier = identifier
  }
}

public struct TypedStoryboardSegueInfo<Segue, Source, Destination>: CustomStringConvertible {
  public let destinationViewController: Destination
  public let identifier: String
  public let segue: Segue
  public let sourceViewController: Source

  public var description: String { return identifier }

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

public protocol Reusable {
  typealias T

  var reuseIdentifier: ReuseIdentifier<T> { get }
}

public extension UITableView {
  public func dequeueReusableCellWithIdentifier<T : UITableViewCell>(identifier: ReuseIdentifier<T>, forIndexPath indexPath: NSIndexPath?) -> T? {
    if let indexPath = indexPath {
      return dequeueReusableCellWithIdentifier(identifier.identifier, forIndexPath: indexPath) as? T
    }
    return dequeueReusableCellWithIdentifier(identifier.identifier) as? T
  }

  public func dequeueReusableCellWithIdentifier<T : UITableViewCell>(identifier: ReuseIdentifier<T>) -> T? {
    return dequeueReusableCellWithIdentifier(identifier.identifier) as? T
  }

  public func dequeueReusableHeaderFooterViewWithIdentifier<T : UITableViewHeaderFooterView>(identifier: ReuseIdentifier<T>) -> T? {
    return dequeueReusableHeaderFooterViewWithIdentifier(identifier.identifier) as? T
  }

  public func registerNib<T: NibResource where T: Reusable, T.T: UITableViewCell>(nibResource: T) {
    registerNib(nibResource.instance, forCellReuseIdentifier: nibResource.reuseIdentifier.identifier)
  }

  public func registerNibForHeaderFooterView<T: NibResource where T: Reusable, T.T: UIView>(nibResource: T) {
    registerNib(nibResource.instance, forHeaderFooterViewReuseIdentifier: nibResource.reuseIdentifier.identifier)
  }

  public func registerNibs<T: NibResource where T: Reusable, T.T: UITableViewCell>(nibResources: [T]) {
    nibResources.forEach(registerNib)
  }
}

public extension UICollectionView {
  public func dequeueReusableCellWithReuseIdentifier<T: UICollectionViewCell>(identifier: ReuseIdentifier<T>, forIndexPath indexPath: NSIndexPath) -> T? {
    return dequeueReusableCellWithReuseIdentifier(identifier.identifier, forIndexPath: indexPath) as? T
  }

  public func dequeueReusableSupplementaryViewOfKind<T: UICollectionReusableView>(elementKind: String, withReuseIdentifier identifier: ReuseIdentifier<T>, forIndexPath indexPath: NSIndexPath) -> T? {
    return dequeueReusableSupplementaryViewOfKind(elementKind, withReuseIdentifier: identifier.identifier, forIndexPath: indexPath) as? T
  }

  public func registerNib<T: NibResource where T: Reusable, T.T: UICollectionViewCell>(nibResource: T) {
    registerNib(nibResource.instance, forCellWithReuseIdentifier: nibResource.reuseIdentifier.identifier)
  }

  public func registerNib<T: NibResource where T: Reusable, T.T: UICollectionReusableView>(nibResource: T, forSupplementaryViewOfKind kind: String) {
    registerNib(nibResource.instance, forSupplementaryViewOfKind: kind, withReuseIdentifier: nibResource.reuseIdentifier.identifier)
  }

  public func registerNibs<T: NibResource where T: Reusable, T.T: UICollectionViewCell>(nibResources: [T]) {
    nibResources.forEach(registerNib)
  }

  public func registerNibs<T: NibResource where T: Reusable, T.T: UICollectionReusableView>(nibResources: [T], forSupplementaryViewOfKind kind: String) {
    nibResources.forEach { self.registerNib($0, forSupplementaryViewOfKind: kind) }
  }
}

public extension UIViewController {
  public convenience init(nib: NibResource) {
    self.init(nibName: nib.name, bundle: nib.bundle)
  }
}

public extension UIViewController {
  public func performSegueWithIdentifier<Segue: UIStoryboardSegue,Source: UIViewController,Destination: UIViewController>(identifier: StoryboardSegueIdentifier<Segue, Source, Destination>, sender: AnyObject?) {
    performSegueWithIdentifier(identifier.identifier, sender: sender)
  }
}

public extension UIStoryboardSegue {
  func typedInfoWithIdentifier<Segue: UIStoryboardSegue,Source: UIViewController,Destination: UIViewController>(identifier: StoryboardSegueIdentifier<Segue, Source, Destination>) -> TypedStoryboardSegueInfo<Segue, Source, Destination>? {
    guard self.identifier == identifier.identifier else { return nil }
    return TypedStoryboardSegueInfo(segue: self)
  }
}
