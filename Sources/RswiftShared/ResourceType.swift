//
//  ResourceType.swift
//  R.swift
//
//  Created by Joe Newton on 2024-07-11.
//

public enum ResourceType: String, CaseIterable, Decodable {
    case image
    case string
    case color
    case data
    case file
    case font
    case nib
    case segue
    case storyboard
    case reuseIdentifier
    case entitlements
    case info
    case id
    case project
}
