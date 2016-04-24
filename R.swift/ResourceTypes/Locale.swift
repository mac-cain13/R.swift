//
//  Locale.swift
//  R.swift
//
//  Created by Tom Lokhorst on 2016-04-24.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

enum Locale {
  case None
  case Base
  case Language(String)

  var isBase: Bool {
    if case .Base = self {
      return true
    }

    return false
  }

  var isNone: Bool {
    if case .None = self {
      return true
    }

    return false
  }
}

extension Locale: CustomStringConvertible {
  init(url: NSURL) {
    if let localeComponent = url.pathComponents?.dropLast().last where localeComponent.hasSuffix(".lproj") {
      let lang = localeComponent.stringByReplacingOccurrencesOfString(".lproj", withString: "")

      if lang == "Base" {
        self = .Base
      }
      else {
        self = .Language(lang)
      }
    }
    else {
      self = .None
    }
  }

  var description: String {
    switch self {
    case .None:
      return ""

    case .Base:
      return "Base"

    case .Language(let language):
      return language
    }
  }
}

extension Locale: Hashable {
  var hashValue: Int {
    switch self {
    case .None:
      return 0

    case .Base:
      return 1

    case .Language(let language):
      return 2 &+  language.hashValue
    }
  }
}

func ==(lhs: Locale, rhs: Locale) -> Bool {
  switch (lhs, rhs) {
  case (.None, .None):
    return true

  case (.Base, .Base):
    return true

  case let (.Language(lLang), .Language(rLang)):
    return lLang == rLang

  default:
    return false
  }
}
