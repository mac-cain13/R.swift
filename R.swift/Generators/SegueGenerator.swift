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
  let externalStruct: Struct?
  let internalStruct: Struct? = nil

  init(storyboards: [Storyboard]) {
    let seguesWithInfo = storyboards.flatMap { storyboard in
      storyboard.viewControllers.flatMap { viewController in
        viewController.segues.flatMap { segue -> SegueWithInfo? in
          guard let destinationType = SegueGenerator.resolveDestinationTypeForSegue(
            segue,
            inViewController: viewController,
            inStoryboard: storyboard,
            allStoryboards: storyboards)
            else
          {
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

    var structs: [Struct] = []

    for (sourceType, seguesBySourceType) in deduplicatedSeguesWithInfo.groupBy({ $0.sourceType }) {
      let gropuedSeguesWithInfo = seguesBySourceType.groupBySwiftNames { $0.segue.identifier }

      for (name, duplicates) in gropuedSeguesWithInfo.duplicates {
        let names = duplicates.map { $0.segue.identifier }.sort().joinWithSeparator(", ")
        warn("Skipping \(duplicates.count) segues for '\(sourceType)' because symbol '\(name)' would be generated for all of these segues, but with a different destination or segue type: \(names)")
      }

      let sts = gropuedSeguesWithInfo
        .uniques
        .groupBy { $0.sourceType }
        .values
        .flatMap(SegueGenerator.seguesWithInfoForSourceTypeToStruct)

      structs = structs + sts
    }

    externalStruct = Struct(
      type: Type(module: .Host, name: "segue"),
      implements: [],
      typealiasses: [],
      properties: [],
      functions: [],
      structs: structs
    )
  }

  private static func resolveDestinationTypeForSegue(segue: Storyboard.Segue, inViewController: Storyboard.ViewController, inStoryboard storyboard: Storyboard, allStoryboards storyboards: [Storyboard]) -> Type? {
    if segue.kind == "unwind" {
      return Type._UIViewController
    }

    let destinationViewControllerType = storyboard.viewControllers
      .filter { $0.id == segue.destination }
      .first?
      .type

    let destinationViewControllerPlaceholderType = storyboard.viewControllerPlaceholders
      .filter { $0.id == segue.destination }
      .first
      .flatMap { storyboard -> Type? in
        switch storyboard.resolveWithStoryboards(storyboards) {
        case .CustomBundle:
          return Type._UIViewController // Not supported, fallback to UIViewController
        case let .Resolved(vc):
          return vc?.type
        }
      }

    return destinationViewControllerType ?? destinationViewControllerPlaceholderType
  }

  private static func seguesWithInfoForSourceTypeToStruct(seguesWithInfoForSourceType: [SegueWithInfo]) -> Struct? {
    guard let sourceType = seguesWithInfoForSourceType.first?.sourceType else { return nil }

    let properties = seguesWithInfoForSourceType.map { segueWithInfo -> Let in
      let type = Type(
        module: "Rswift",
        name: "StoryboardSegueIdentifier",
        genericArgs: [segueWithInfo.segue.type, segueWithInfo.sourceType, segueWithInfo.destinationType],
        optional: false
      )
      return Let(
        isStatic: true,
        name: segueWithInfo.segue.identifier,
        typeDefinition: .Specified(type),
        value: "StoryboardSegueIdentifier(identifier: \"\(segueWithInfo.segue.identifier)\")"
      )
    }

    let functions = seguesWithInfoForSourceType.map { segueWithInfo -> Function in
      Function(
        isStatic: true,
        name: segueWithInfo.segue.identifier,
        generics: nil,
        parameters: [
          Function.Parameter.init(name: "segue", localName: "segue", type: Type._UIStoryboardSegue)
        ],
        doesThrow: false,
        returnType: Type.TypedStoryboardSegueInfo
          .asOptional()
          .withGenericArgs([segueWithInfo.segue.type, segueWithInfo.sourceType, segueWithInfo.destinationType]),
        body: "return TypedStoryboardSegueInfo(segueIdentifier: R.segue.\(sanitizedSwiftName(sourceType.description)).\(sanitizedSwiftName(segueWithInfo.segue.identifier)), segue: segue)"
      )
    }

    return Struct(
      type: Type(module: .Host, name: sanitizedSwiftName(sourceType.description)),
      implements: [],
      typealiasses: [],
      properties: properties.map(anyProperty),
      functions: functions,
      structs: []
    )
  }
}

