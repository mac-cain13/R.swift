//
//  StoryboardSegueIdentifierProtocol.swift
//  R.swift Library
//
//  Created by Mathijs Kadijk on 06-12-15.
//  From: https://github.com/mac-cain13/R.swift.Library
//  License: MIT License
//

import Foundation

/// Storyboard identifier
public protocol StoryboardIdentifier {
    /// Storyboard identifier of this view controller
    static var identifier: String { get }
}

/// Nib reference
public struct NibReference<FirstView> {

    /// String name of this nib
    public let name: String

    /**
     Create a new NibRefence based on the string name
     - parameter name: The string name for this nib
     - returns: A new NibReference
    */
    public init(name: String) {
        self.name = name
    }
}

/// Reuse identifier
public struct ReuseIdentifier<Reusable> {

    /// String identifier of this reusable
    public let identifier: String

    /**
     Create a new ReuseIdentifier based on the string identifier
     - parameter identifier: The string identifier for this reusable
     - returns: A new ReuseIdentifier
    */
    public init(identifier: String) {
        self.identifier = identifier
    }
}

/// Segue identifier
public struct SegueIdentifier<Segue, Source, Destination> {

    /// Identifier string of this segue
    public let identifier: String

    /**
     Create a new SegueIdentifier based on the identifier string
     - parameter identifier: The string identifier for this segue
     - returns: A new SegueIdentifier
    */
    public init(identifier: String) {
        self.identifier = identifier
    }
}

/// View controller identifier
public struct ViewControllerIdentifier<ViewController> {

    /// Identifier string of this view controller
    public let identifier: String

    /**
     Create a new ViewControllerIdentifier based on the identifier string
     - parameter identifier: The string identifier for this view controller
     - returns: A new ViewControllerIdentifier
    */
    public init(identifier: String) {
        self.identifier = identifier
    }
}

/// Typed segue information
public struct TypedSegue<Segue, Source, Destination> {

    /// The original segue
    public let segue: Segue

    /// Segue source view controller
    public let source: Source

    /// Segue destination view controller
    public let destination: Destination

    /// Segue identifier
    public let identifier: String

    /**
     Create a new TypedSegue based on the original segue
     - parameter segue: The original segue
     - parameter source: Segue source view controller
     - parameter destination: Segue destination view controller
     - parameter identifier: The string identifier for this segue
     - returns: A new TypedSegue
    */
    public init(segue: Segue, source: Source, destination: Destination, identifier: String) {
        self.segue = segue
        self.source = source
        self.destination = destination
        self.identifier = identifier
    }
}
