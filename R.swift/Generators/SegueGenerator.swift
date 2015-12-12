//
//  Segue.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 10-12-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import Foundation

typealias SegueWithInfo = (segue: Storyboard.Segue, sourceType: Type, destinationType: Type)

struct SegueGenerator: Generator {
  let usingModules: Set<Module>
  let externalFunction: Function? = nil
  let externalStruct: Struct?
  let internalStruct: Struct? = nil

  init(storyboards: [Storyboard]) {
    let seguesWithInfo = storyboards.flatMap { storyboard in
      storyboard.viewControllers.flatMap { viewController in
        viewController.segues.flatMap { segue -> SegueWithInfo? in
          guard let destinationType = storyboard.viewControllers.filter({ $0.id == segue.destination }).first?.type else {
            warn("Destination view controller with id \(segue.destination) for segue \(segue.identifier) in \(viewController.type) not found in storyboard \(storyboard.name). Is this storyboard corrupt?")
            return nil
          }

          return (segue: segue, sourceType: viewController.type, destinationType: destinationType)
        }
      }
    }

    let deduplicatedSeguesWithInfo = seguesWithInfo
      .groupBy { segue, sourceType, destinationType in
        "\(segue.identifier)|\(segue.type)|\(sourceType)|\(destinationType)"
      }
      .values
      .flatMap { $0.first }

    let groupedSeguesWithInfo = deduplicatedSeguesWithInfo
      .groupUniquesAndDuplicates { "\($0.segue.identifier)|\($0.sourceType)" }

    for duplicate in groupedSeguesWithInfo.duplicates {
      let anySegueWithInfo = duplicate.first!
      let names = duplicate.map { $0.segue.identifier }.sort().joinWithSeparator(", ")
      warn("Skipping \(duplicate.count) segues for '\(anySegueWithInfo.sourceType)' because symbol '\(sanitizedSwiftName(anySegueWithInfo.segue.identifier))' would be generated for all of these segues, but with a different destination or segue type: \(names)")
    }

    usingModules = Set(Array(groupedSeguesWithInfo.uniques)
      .flatMap { [$0.segue.type.module, $0.sourceType.module, $0.destinationType.module].flatMap({$0}) })
      .union(["Rswift"])

    let structs = groupedSeguesWithInfo.uniques
      .groupBy { $0.sourceType }
      .values
      .flatMap(SegueGenerator.seguesWithInfoForSourceTypeToStruct)

    externalStruct = Struct(
      type: Type(name: "segue"),
      implements: [],
      typealiasses: [],
      vars: [],
      functions: [],
      structs: structs
    )
  }

  private static func seguesWithInfoForSourceTypeToStruct(seguesWithInfoForSourceType: [SegueWithInfo]) -> Struct? {
    let vars = seguesWithInfoForSourceType.map { segueWithInfo -> Var in
      let type = Type(
        name: "StoryboardSegueIdentifier",
        genericArgs: [segueWithInfo.segue.type.description, segueWithInfo.sourceType.description, segueWithInfo.destinationType.description],
        optional: false
      )
      return Var(
        isStatic: true,
        name: segueWithInfo.segue.identifier,
        type: type,
        getter: "return StoryboardSegueIdentifier(identifier: \"\(segueWithInfo.segue.identifier)\")"
      )
    }

    guard let sourceType = seguesWithInfoForSourceType.first?.sourceType where vars.count > 0 else { return nil }

    return Struct(
      type: Type(name: sanitizedSwiftName(sourceType.description)),
      implements: [],
      typealiasses: [],
      vars: vars,
      functions: [],
      structs: []
    )
  }
}

