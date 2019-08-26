//
//  Locale.swift
//  R.swift
//
//  Created by Tom Lokhorst on 2016-04-24.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

enum Locale {
  case none
  case language(String)

  var isNone: Bool {
    if case .none = self {
      return true
    }

    return false
  }

    var language: String? {
    if case .language(let language) = self {
      return language
    }

    return nil
  }
}

extension Locale: Hashable {
  init(url: URL) {
    if let localeComponent = url.pathComponents.dropLast().last , localeComponent.hasSuffix(".lproj") {
      let lang = localeComponent.replacingOccurrences(of: ".lproj", with: "")

      self = .language(lang)
    }
    else {
      self = .none
    }
  }

  var localeDescription: String? {
    switch self {
    case .none:
      return nil

    case .language(let language):
      return language
    }
  }
}
