//
//  ImageResource+Integrations.swift
//  
//
//  Created by Tom Lokhorst on 2022-07-30.
//

import Foundation
import SwiftUI

#if canImport(UIKit)
extension ImageResource {

    @available(*, deprecated, message: "Use UIImage(resource:) initializer instead")
    public func callAsFunction(compatibleWith traitCollection: UITraitCollection? = nil) -> UIImage? {
        UIImage(named: name, in: bundle, compatibleWith: traitCollection)
    }
}
#endif


@available(iOS 13, tvOS 13, watchOS 6, *)
extension Image {

    public init(_ resource: ImageResource) {
        self.init(resource.name, bundle: resource.bundle)
    }

    @available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
    public init(_ resource: ImageResource, variableValue: Double?) {
        self.init(resource.name, variableValue: variableValue, bundle: resource.bundle)
    }

    public init(_ resource: ImageResource, label: Text) {
        self.init(resource.name, bundle: resource.bundle, label: label)
    }

    @available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
    public init(_ resource: ImageResource, variableValue: Double?, label: Text) {
        self.init(resource.name, variableValue: variableValue, bundle: resource.bundle, label: label)
    }

    public init(decorative resource: ImageResource) {
        self.init(decorative: resource.name, bundle: resource.bundle)
    }

    @available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
    public init(decorative resource: ImageResource, variableValue: Double?) {
        self.init(decorative: resource.name, variableValue: variableValue, bundle: resource.bundle)
    }
}


#if canImport(UIKit)
import UIKit

extension UIImage {

    public convenience init?(resource: ImageResource, compatibleWith traitCollection: UITraitCollection? = nil) {
        self.init(named: resource.name, in: resource.bundle, compatibleWith: traitCollection)
    }

    @available(iOS 13, tvOS 13, watchOS 6, *)
    public convenience init?(resource: ImageResource, with configuration: UIImage.Configuration?) {
        self.init(named: resource.name, in: resource.bundle, with: configuration)
    }

    @available(iOS 16, tvOS 16, watchOS 9, *)
    public convenience init?(resource: ImageResource, variableValue: Double, with configuration: UIImage.Configuration? = nil) {
        self.init(named: resource.name, in: resource.bundle, variableValue: variableValue, configuration: configuration)
    }
}
#endif
