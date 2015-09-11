# R.swift ![Version](https://img.shields.io/cocoapods/v/R.swift.svg?style=flat) ![License](https://img.shields.io/cocoapods/l/R.swift.svg?style=flat) ![Platform](https://img.shields.io/cocoapods/p/R.swift.svg?style=flat) ![Build status](https://www.bitrise.io/app/cef05ad300903a89.svg?token=aPVYvCoJVcdVM-Z6KekYPQ&branch=master)

_Get strong typed, autocompleted resources like images, fonts and segues in Swift projects_

## Why use this?

It makes your code that uses resources:
- **Fully typed**, less casting and guessing what a method will return
- **Compiletime checked**, no more incorrect strings that make your app crash at runtime
- **Autocompleted**, never have to guess that image name again

Currently you type:
```swift
let icon = UIImage(named: "settings-icon")
let font = UIFont(name: "San Fransisco", size: 42)
performSegueWithIdentifier("openSettings")
```

With R.swift it becomes:
```swift
let icon = R.image.settingsIcon
let font = R.font.sanFransisco(size: 42)
performSegueWithIdentifier(R.segue.openSettings)
```

Check out [more examples of R.swift based code](Documentation/Examples.md)!

## Features

After installing R.swift into your project you can use the `R`-struct to access resources. If the struct is outdated just build and R.swift will correct any missing/changed/added resources.

R.swift currently supports these types of resources:
- [Images](Documentation/Examples.md#images)
- [Storyboards](Documentation/Examples.md#storyboards)
- [Segues](Documentation/Examples.md#segues)
- [Nibs](Documentation/Examples.md#nibs)
- [Reusable cells](Documentation/Examples.md#reusable-cells)
- [Custom fonts](Documentation/Examples.md#custom-fonts)

Runtime validation with [`R.validate()`](Documentation/Examples.md#storyboards):
- If images used in storyboards are available
- If view controllers with storyboard identifiers can be loaded

## Installation

[CocoaPods](http://cocoapods.org) is the recommended way of installation, as this avoids including any binary files into your project.

### CocoaPods (recommended)

_There is also a [short video](https://vimeo.com/122888912) of this instruction._

1. Add `pod 'R.swift'` to your [Podfile](http://cocoapods.org/#get_started) and run `pod install`
2. In XCode: Click on your project in the file list, choose your target under `TARGETS`, click the `Build Phases` tab and add a `New Run Script Phase` by clicking the little plus icon in the top left
3. Drag the new `Run Script` phase **above** the `Compile Sources` phase and **below** `Check Pods Manifest.lock`, expand it and paste the following script: `"$PODS_ROOT/R.swift/rswift" "$SRCROOT"`
4. Build your project, in Finder you will now see a `R.generated.swift` in the `$SRCROOT`-folder, drag the `R.generated.swift` files into your project and **uncheck** `Copy items if needed`

_Tip:_ Add the `*.generated.swift` pattern to your `.gitignore` file to prevent unnecessary conflicts.

### Manually

1. [Download](https://github.com/mac-cain13/R.swift/releases) a R.swift release, unzip it and put it into your source root directory
2. In XCode: Click on your project in the file list, choose your target under `TARGETS`, click the `Build Phases` tab and add a `New Run Script Phase` by clicking the little plus icon in the top left
3. Drag the new `Run Script` phase **above** the `Compile Sources` phase, expand it and paste the following script: `"$SRCROOT/rswift" "$SRCROOT"`
4. Build your project, in Finder you will now see a `R.generated.swift` in the `$SRCROOT`-folder, drag the `R.generated.swift` files into your project and **uncheck** `Copy items if needed`

_Tip:_ Add the `*.generated.swift` pattern to your `.gitignore` file to prevent unnecessary conflicts.

## Contribute

Please post any issues, questions and compliments in the GitHub issue tracker and feel free to submit pull request with fixes and improvements. Keep in mind; a good pull request is small, forked from the `develop`-branch and well explained. It also should benefit most of the users.

## License

R.swift is created by [Mathijs Kadijk](https://github.com/mac-cain13) and released under a [MIT License](License).
