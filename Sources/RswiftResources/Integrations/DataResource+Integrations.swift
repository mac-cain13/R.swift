//
//  DataResource+Integrations.swift
//  
//
//  Created by Tom Lokhorst on 2022-07-31.
//

import Foundation

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

extension NSDataAsset {

    /**
     Returns the data asset from this resource (R.data.\*)

     - parameter resource: The resource you want the data asset of (R.data.\*)
     */
    public convenience init?(resource: DataResource) {
        self.init(name: resource.name, bundle: resource.bundle ?? .main)
    }

}
