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
  case base
  case language(String)

  var isBase: Bool {
    if case .base = self {
      return true
    }

    return false
  }

  var isNone: Bool {
    if case .none = self {
      return true
    }

    return false
  }
}

extension Locale {
  init(url: URL) {
    if let localeComponent = url.pathComponents.dropLast().last , localeComponent.hasSuffix(".lproj") {
      let lang = localeComponent.replacingOccurrences(of: ".lproj", with: "")

      if lang == "Base" {
        self = .base
      }
      else {
        self = .language(lang)
      }
    }
    else {
      self = .none
    }
  }

  var localeDescription: String? {
    switch self {
    case .none:
      return nil

    case .base:
      return "Base"

    case .language(let language):
      return language
    }
  }
}

extension Locale: Hashable {
  #if swift(<4.2)
  var hashValue: Int {
    switch self {
    case .none:
      return 0

    case .base:
      return 1

    case .language(let language):
      return 2 &+ language.hashValue
    }
  }
  #else
  func hash(into hasher: inout Hasher) {
    switch self {
    case .none:
      hasher.combine(0)
    case .base:
      hasher.combine(1)
    case .language(let languageCode):
      hasher.combine(2)
      hasher.combine(languageCode)
    }
  }
  #endif
}

func == (lhs: Locale, rhs: Locale) -> Bool {
  switch (lhs, rhs) {
  case (.none, .none):
    return true

  case (.base, .base):
    return true

  case let (.language(lLang), .language(rLang)):
    return lLang == rLang

  default:
    return false
  }
}
