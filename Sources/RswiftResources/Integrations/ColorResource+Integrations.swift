//
//  UIColor+ColorResource.swift
//  R.swift.Library
//
//  Created by Tom Lokhorst on 2017-06-06.
//  From: https://github.com/mac-cain13/R.swift.Library
//  License: MIT License
//

import Foundation
import SwiftUI

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension Color {

    /**
     Creates a color from this resource (`R.color.*`).

     - parameter resource: The resource you want the color of (`R.color.*`)
     */
    public init(_ resource: ColorResource) {
        self.init(resource.name, bundle: resource.bundle)
    }
}


#if os(iOS) || os(tvOS)
import UIKit

extension ColorResource {

    /**
     Returns the color from this resource (`R.color.*`) that is compatible with the trait collection.

     - parameter resource: The resource you want the color of (`R.color.*`)
     - parameter traitCollection: Traits that describe the desired color to retrieve, pass nil to use traits that describe the main screen.

     - returns: A color that exactly or best matches the desired traits with the given resource (`R.color.*`), or nil if no suitable color was found.
     */
    @available(*, deprecated, message: "Use UIColor(resource:) initializer instead")
    public func callAsFunction(compatibleWith traitCollection: UITraitCollection? = nil) -> UIColor? {
        UIColor(named: name, in: bundle, compatibleWith: traitCollection)
    }
}

extension UIColor {

    /**
     Returns the color from this resource (`R.color.*`) that is compatible with the trait collection.

     - parameter resource: The resource you want the color of (`R.color.*`)
     - parameter traitCollection: Traits that describe the desired color to retrieve, pass nil to use traits that describe the main screen.

     - returns: A color that exactly or best matches the desired traits with the given resource (`R.color.*`), or nil if no suitable color was found.
     */
    public convenience init?(resource: ColorResource, compatibleWith traitCollection: UITraitCollection? = nil) {
        self.init(named: resource.name, in: resource.bundle, compatibleWith: traitCollection)
    }

}
#endif
