//
//  Struct+InternalProperties.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 06-10-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

extension Struct {
    func addingInternalProperties(forBundleIdentifier bundleIdentifier: String, withEmbeddedResourceBundle resourceBundleName: String? = nil) -> Struct {

    var hostingBundleValue = "Bundle(for: R.Class.self)"
    if let resourceBundleName = resourceBundleName {
        hostingBundleValue = "Bundle(url: \(hostingBundleValue).url(forResource: \"\(resourceBundleName)\", withExtension: \"bundle\")!) ?? \(hostingBundleValue)"
    }

    let internalProperties = [
      Let(
        comments: [],
        accessModifier: .filePrivate,
        isStatic: true,
        name: "hostingBundle",
        typeDefinition: .inferred(Type._Bundle),
        value: hostingBundleValue),
      Let(
        comments: [],
        accessModifier: .filePrivate,
        isStatic: true,
        name: "applicationLocale",
        typeDefinition: .inferred(Type._Locale),
        value: "hostingBundle.preferredLocalizations.first.flatMap(Locale.init) ?? Locale.current")
    ]

    let internalClasses = [
      Class(accessModifier: .filePrivate, type: Type(module: .host, name: "Class"))
    ]

    var externalStruct = self
    externalStruct.properties.append(contentsOf: internalProperties)
    externalStruct.classes.append(contentsOf: internalClasses)

    return externalStruct
  }
}
