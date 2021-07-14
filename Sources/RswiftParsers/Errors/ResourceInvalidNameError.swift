//
//  File.swift
//  
//
//  Created by Mathijs on 14/07/2021.
//

import Foundation

public struct ResourceInvalidNameError: LocalizedError {
    public var errorDescription: String? = "Empty name encountered for resource"
}
