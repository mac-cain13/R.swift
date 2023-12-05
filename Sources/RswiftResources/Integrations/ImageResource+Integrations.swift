//
//  UIImage+ImageResource.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 11-01-16.
//

import Foundation

#if canImport(SwiftUI)
import SwiftUI

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, visionOS 1, *)
extension Image {

    /**
     Creates a labelled image from this resource (`R.image.*`).

     - parameter resource: The resource you want the image of (`R.image.*`)
     */
    public init(_ resource: ImageResource) {
        self.init(resource.name, bundle: resource.bundle)
    }


    /**
     Creates a labelled image from this resource (`R.image.*`), with the specified label

     - parameter resource: The resource you want the image of (`R.image.*`)
     - parameter label: The label associated with the image, for accessibility
     */
    public init(_ resource: ImageResource, label: Text) {
        self.init(resource.name, bundle: resource.bundle, label: label)
    }


    /**
     Creates an unlabelled, decorative image from this resource (`R.image.*`).

     - parameter resource: The resource you want the image of (`R.image.*`)
     */
    public init(decorative resource: ImageResource) {
        self.init(decorative: resource.name, bundle: resource.bundle)
    }
}

// Xcode 14 doesn't recognize `variableValue` init, Xcode 14.1 does know `variableValue`
// Xcode 14.1 is first to ship with swift 5.7.1
#if swift(>=5.7.1)
@available(macOS 13, iOS 16, tvOS 16, watchOS 9, visionOS 1, *)
extension Image {

    /**
     Creates a labelled image from this resource (`R.image.*`), with the variable value.

     - parameter resource: The resource you want the image of (`R.image.*`)
     - parameter variableValue: Optional value between 1 and 0
     */
    public init(_ resource: ImageResource, variableValue: Double?) {
        self.init(resource.name, variableValue: variableValue, bundle: resource.bundle)
    }


    /**
     Creates a labelled image from this resource (`R.image.*`), with the specified label and variable value.

     - parameter resource: The resource you want the image of (`R.image.*`)
     - parameter variableValue: Optional value between 1 and 0
     - parameter label: The label associated with the image, for accessibility
     */
    public init(_ resource: ImageResource, variableValue: Double?, label: Text) {
        self.init(resource.name, variableValue: variableValue, bundle: resource.bundle, label: label)
    }


    /**
     Creates an unlabelled, decorative image from this resource (`R.image.*`), with variable value.

     - parameter resource: The resource you want the image of (`R.image.*`)
     - parameter variableValue: Optional value between 1 and 0
     */
    public init(decorative resource: ImageResource, variableValue: Double?) {
        self.init(decorative: resource.name, variableValue: variableValue, bundle: resource.bundle)
    }
}
#endif
#endif

#if os(iOS) || os(tvOS) || os(visionOS)
import UIKit

extension ImageResource {

    /**
     Returns the image from this resource (`R.image.*`) that is compatible with the trait collection.

     - parameter resource: The resource you want the image of (`R.image.*`)
     - parameter traitCollection: Traits that describe the desired image to retrieve, pass nil to use traits that describe the main screen.

     - returns: An image that exactly or best matches the desired traits with the given resource (`R.image.*`), or nil if no suitable image was found.
     */
    //    @available(*, deprecated, message: "Use UIImage(resource:) initializer instead")
    public func callAsFunction(compatibleWith traitCollection: UITraitCollection? = nil) -> UIImage? {
        UIImage(named: name, in: bundle, compatibleWith: traitCollection)
    }
}

extension UIImage {

    /**
     Returns the image from this resource (`R.image.*`) that is compatible with the trait collection.

     - parameter resource: The resource you want the image of (`R.image.*`)
     - parameter traitCollection: Traits that describe the desired image to retrieve, pass nil to use traits that describe the main screen.

     - returns: An image that exactly or best matches the desired traits with the given resource (`R.image.*`), or nil if no suitable image was found.
     */
    public convenience init?(resource: ImageResource, compatibleWith traitCollection: UITraitCollection? = nil) {
        self.init(named: resource.name, in: resource.bundle, compatibleWith: traitCollection)
    }

    /**
     Returns the image from this resource (`R.image.*`) using the configuration specified.

     - parameter resource: The resource you want the image of (`R.image.*`)
     - parameter configuration: The image configuration the system appllies to the image

     - returns: An image that exactly or best matches the configuration of the given resource (`R.image.*`), or nil if no suitable image was found.
     */
    @available(iOS 13, tvOS 13, visionOS 1, *)
    public convenience init?(resource: ImageResource, with configuration: UIImage.Configuration?) {
        self.init(named: resource.name, in: resource.bundle, with: configuration)
    }
}
#endif


// Xcode 14 doesn't recognize `variableValue` init, Xcode 14.1 does know `variableValue`
// Xcode 14.1 is first to ship with swift 5.7.1
#if swift(>=5.7.1) && (os(iOS) || os(tvOS)) || os(visionOS)
extension UIImage {
    /**
     Returns the image from this resource (`R.image.*`) using the configuration, and variable value specified.

     - parameter resource: The resource you want the image of (`R.image.*`)
     - parameter variableValue: The value the system uses to customize the image content, between 0 and 1
     - parameter configuration: The image configuration the system appllies to the image

     - returns: An image that exactly or best matches the configuration of the given resource (`R.image.*`), or nil if no suitable image was found.
     */
    @available(iOS 16, tvOS 16, visionOS 1, *)
    public convenience init?(resource: ImageResource, variableValue: Double, with configuration: UIImage.Configuration? = nil) {
        self.init(named: resource.name, in: resource.bundle, variableValue: variableValue, configuration: configuration)
    }
}
#endif
