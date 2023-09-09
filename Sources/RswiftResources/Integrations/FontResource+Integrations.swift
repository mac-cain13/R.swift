//
//  UIFont+FontResource.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 06-01-16.
//

import Foundation
import SwiftUI


@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, visionOS 1, *)
extension Font {

    /**
     Create a custom font from this resource (`R.font.*`) and and size that scales with the body text style.
     */
    public static func custom(_ resource: FontResource, size: CGFloat) -> Font {
        .custom(resource.name, size: size)
    }

    /**
     Create a custom font from this resource (`R.font.*`) and a fixed size that does not scale with Dynamic Type.
     */
    @available(macOS 11, iOS 14, tvOS 14, watchOS 7, visionOS 1, *)
    public static func custom(_ resource: FontResource, fixedSize: CGFloat) -> Font {
        .custom(resource.name, fixedSize: fixedSize)
    }

    /**
     Create a custom font from this resource (`R.font.*`) and and size that is relative to the given `textStyle`.
     */
    @available(macOS 11, iOS 14, tvOS 14, watchOS 7, visionOS 1, *)
    public static func custom(_ resource: FontResource, size: CGFloat, relativeTo textStyle: Font.TextStyle) -> Font {
        .custom(resource.name, size: size, relativeTo: textStyle)
    }
}

#if canImport(UIKit)
import UIKit

extension FontResource {

    /**
     Returns the font from this resource (`R.font.*`) at the specified zie.

     - parameter resource: The font resource (`R.font.*`) for the specific font to load
     - parameter size: The size (in points) to which the font is scaled. This value must be greater than 0.0.

     - returns: A color that exactly or best matches the desired traits with the given resource (R.color.\*), or nil if no suitable color was found.
     */
    //    @available(*, deprecated, message: "Use UIFont(resource:size:) initializer instead")
    public func callAsFunction(size: CGFloat) -> UIFont? {
        UIFont(name: name, size: size)
    }
}

public extension UIFont {
    /**
     Creates and returns a font object for the specified font resource (`R.font.*`) and size.

     - parameter resource: The font resource (`R.font.*`) for the specific font to load
     - parameter size: The size (in points) to which the font is scaled. This value must be greater than 0.0.

     - returns: A font object of the specified font resource and size.
     */
    convenience init?(resource: FontResource, size: CGFloat) {
        self.init(name: resource.name, size: size)
    }
}
#endif


#if canImport(UIKit)
import UIKit

extension FontResource {
    /**
     Returns true if the font can be loaded.
     Custom fonts may not be loaded if not properly configured in Info.plist
     */
    public func canBeLoaded() -> Bool {
        UIFont(name: name, size: 42) != nil
    }
}
#elseif canImport(AppKit)
import AppKit

extension FontResource {
    /**
     Returns true if the font can be loaded.
     Custom fonts may not be loaded if not properly configured in Info.plist
     */
    public func canBeLoaded() -> Bool {
        NSFont(name: name, size: 42) != nil
    }
}
#endif
