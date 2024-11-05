//
//  TheAppClipApp.swift
//  TheAppClip
//
//  Created by Tom Lokhorst on 2020-09-15.
//

import SwiftUI

@main
struct TheAppClipApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // From ClipAssets (in this target)
                    print(R.color.myColor()!)

                    // From Group1 (in this target)
                    print(R.image.handTwo()!)
                    print(R.image.handThree()!)
                    print(R.image.hand3Two()!)
                    print(R.image.hand3Three()!)
                    print(R.image.hand3Three()!)

                    // From Subdir (in this target)
                    print(R.image.colorsJpg()!)
                    print(R.image.user()!)

                    // From root folder (in this target)
                    print(R.string.localizable.helloWorld())

                    // From Assets (in MainUI)
                    print(R.image.handIgnoreme()!)

                    // From root folder (in MainUI)
                    print(R.storyboard.myStoryboard.instantiateInitialViewController()!)
                }
        }
    }
}
