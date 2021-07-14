//
//  File.swift
//  
//
//  Created by Mathijs on 14/07/2021.
//

import Foundation

extension URL {
  var filename: String? {
    let filename = deletingPathExtension().lastPathComponent
    return filename.count == 0 ? nil : filename
  }
}
