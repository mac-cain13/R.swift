//
//  MainUIApp.swift
//  MainUI
//
//  Created by Tom Lokhorst on 2020-09-15.
//

import SwiftUI

@main
struct MainUIApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // From Assets (in this target)
                    print(R.image.handIgnoreme()!)

                    // From root folder (in this target)
                    print(R.image.user1()!)
                    print(R.storyboard.myStoryboard.instantiateInitialViewController()!)

                    // From Folders3 copy (in this target)
                    print(R.image.hand3Two()!)
                    print(R.image.hand3Three()!)
                    print(R.image.hand2Two()!)
                    print(R.image.hand2Three()!)

                    // From Subdir (in TheAppClip target)
                    print(R.image.person()!)

                    // From root folder (in TheAppClip target)
                    print(R.string.localizable.helloWorld())
                }
        }
    }
}
