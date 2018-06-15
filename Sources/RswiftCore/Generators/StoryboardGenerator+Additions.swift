//
//  StoryboardGenerator+Additions.swift
//  R.swift
//
//  Created by Łukasz Grzywacz on 05-04-18.
//  From: https://github.com/lgrzywac/R.swift
//  License: MIT License
//

import Foundation

public enum StoryboardInstantiationAdditions {
  case swinject
  case noregular
  case replaceRegularWithSwinject
  
  public static func load(name: String) -> StoryboardInstantiationAdditions? {
    switch name {
    case "swinject":
      return .swinject
    case "noregular":
      return .noregular
    case "replaceRegularWithSwinject":
      return .replaceRegularWithSwinject
    default:
      fputs("Not recognized StoryboardAddition: \(name), skipping\n", stderr)
      return nil
    }
  }
  
  public func requiredImportModules() -> [Module] {
    switch self {
    case .swinject, .replaceRegularWithSwinject:
      return [Module.custom(name: "Swinject"), Module.custom(name: "SwinjectStoryboard")]
    case .noregular:
      return []
    }
  }
}
