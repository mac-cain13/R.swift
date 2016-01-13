//
//  ErrorOutput.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 11-12-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import Foundation

func warn(warning: String) {
  print("warning: [R.swift] \(warning)")
}

func fail(error: String) {
  print("error: [R.swift] \(error)")
}
