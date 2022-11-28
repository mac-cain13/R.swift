//
//  TypeReference+Extensions.swift
//  
//
//  Created by Tom Lokhorst on 2022-06-24.
//

import Foundation
import RswiftResources

extension TypeReference {
    static let uiView = TypeReference(module: .uiKit, rawName: "UIView")
    static let uiViewController = TypeReference(module: .uiKit, rawName: "UIViewController")
    static let uiStoryboardSegue = TypeReference(module: .uiKit, rawName: "UIStoryboardSegue")
}
