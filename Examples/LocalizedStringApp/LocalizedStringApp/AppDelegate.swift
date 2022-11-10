//
//  AppDelegate.swift
//  LocalizedStringApp
//
//  Created by Tom Lokhorst on 2019-08-30.
//  Copyright © 2019 R.swift. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {



  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    let myprefs: [String] = ["fr-CA"]

    print("Locale.preferredLanguages:")
    print(Locale.preferredLanguages)
    print()
    print("Bundle.main.preferredLocalizations:")
    print(Bundle.main.preferredLocalizations)
    print()
    print("Test:")
    print(NSLocalizedString("one1", tableName: "one", comment: ""))
    print(R.string.one.one1())
    print(R.string.one.one1(preferredLanguages: myprefs))
    print()
    print(NSLocalizedString("one2", tableName: "one", comment: ""))
    print(R.string.one.one2())
    print(R.string.one.one2(preferredLanguages: myprefs))
    print()

    print(NSLocalizedString("two1", tableName: "two", comment: ""))
    print(R.string.two.two1())
    print(R.string.two.two1(preferredLanguages: myprefs))
    print()
    print(String(format: NSLocalizedString("two2", tableName: "two", comment: ""), locale: Locale(identifier: myprefs.first!), "Hello"))
    print(R.string.two.two2("Hello"))
    print(R.string.two.two2("Hello", preferredLanguages: myprefs))
    print()

    print(NSLocalizedString("three1", tableName: "three", comment: ""))
    print(R.string.three.three1())
    print(R.string.three.three1(preferredLanguages: myprefs))
    print()
    print(NSLocalizedString("three2", tableName: "three", comment: ""))
    print(R.string.three.three2())
    print(R.string.three.three2(preferredLanguages: myprefs))
    print()
    print(NSLocalizedString("three3", tableName: "three", comment: ""))
    print(R.string.three.three3())
    print(R.string.three.three3(preferredLanguages: myprefs))
    print()

    print(NSLocalizedString("four1", tableName: "four", comment: ""))
    print(R.string.four.four1())
    print(R.string.four.four1(preferredLanguages: myprefs))
    print()

    print(NSLocalizedString("five1", tableName: "five", comment: ""))
    print(R.string.five.five1())
    print(R.string.five.five1(preferredLanguages: myprefs))
    print()
    print(NSLocalizedString("five2", tableName: "five", comment: ""))
    print(R.string.five.five2())
    print(R.string.five.five2(preferredLanguages: myprefs))
    print()
    print(NSLocalizedString("five4", tableName: "five", comment: ""))
    print(R.string.five.five4())
    print(R.string.five.five4(preferredLanguages: myprefs))
    print()

    print(NSLocalizedString("six1", tableName: "six", comment: ""))
    print(R.string.six.six1())
    print(R.string.six.six1(preferredLanguages: myprefs))
    print()
    print(NSLocalizedString("six2", tableName: "six", comment: ""))
    print(R.string.six.six2())
    print(R.string.six.six2(preferredLanguages: myprefs))
    print()

    print(NSLocalizedString("seven1", tableName: "seven", comment: ""))
    print(R.string.seven.seven1())
    print(R.string.seven.seven1(preferredLanguages: myprefs))
    print()
    print(NSLocalizedString("seven2", tableName: "seven", comment: ""))
    print(R.string.seven.seven2())
    print(R.string.seven.seven2(preferredLanguages: myprefs))
    print()
    print(NSLocalizedString("seven3", tableName: "seven", comment: ""))
    print(R.string.seven.seven3())
    print(R.string.seven.seven3(preferredLanguages: myprefs))
    print()
    print(NSLocalizedString("seven4", tableName: "seven", comment: ""))
    print(R.string.seven.seven4())
    print(R.string.seven.seven4(preferredLanguages: myprefs))
    print()

    print(NSLocalizedString("eight1", tableName: "eight", comment: ""))
    print(R.string.eight.eight1())
    print(R.string.eight.eight1(preferredLanguages: myprefs))
    print()
    print(NSLocalizedString("eight2", tableName: "eight", comment: ""))
    print(R.string.eight.eight2())
    print(R.string.eight.eight2(preferredLanguages: myprefs))
    print()
    print(NSLocalizedString("eight3", tableName: "eight", comment: ""))
    print(R.string.eight.eight3())
    print(R.string.eight.eight3(preferredLanguages: myprefs))
    print()

    print(NSLocalizedString("nine1", tableName: "nine", comment: ""))
    print(R.string.nine.nine1())
    print(R.string.nine.nine1(preferredLanguages: myprefs))
    print()
    print(NSLocalizedString("nine2", tableName: "nine", comment: ""))
    print(R.string.nine.nine2())
    print(R.string.nine.nine2(preferredLanguages: myprefs))
    print()
    print(NSLocalizedString("nine", tableName: "nine", comment: ""))
    print(R.string.nine.nine3())
    print(R.string.nine.nine3(preferredLanguages: myprefs))
    print()



    return true
  }


}

