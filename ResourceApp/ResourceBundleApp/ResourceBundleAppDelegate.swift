//
//  ResourceBundleAppDelegate.swift
//  ResourceBundleApp
//
//  Created by Sven Driemecker on 27.03.18.
//  Copyright © 2018 Mathijs Kadijk. All rights reserved.
//

import UIKit
import Rswift

@UIApplicationMain
class ResourceBundleAppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

//        do {
//          try R.validate()
//        } catch {
//          fatalError("R-Validation failed: \(error)")
//        }

        // custom UIWindow-Main.storyboard hookup cause storyboard resides inside ResourceBundle
        window = UIWindow.init(frame: UIScreen.main.bounds)
        window?.rootViewController = R.storyboard.main.instantiateInitialViewController()
        window?.makeKeyAndVisible()

        return true
    }
}

