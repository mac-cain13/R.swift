//
//  ErrorOutput.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 11-12-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import Foundation

func warn(_ warning: String) {
  print("warning: [R.swift] \(warning)")
}

func fail(_ error: String) {
  print("error: [R.swift] \(error)")
}
