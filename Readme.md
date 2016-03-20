# R.swift [![Version](https://img.shields.io/cocoapods/v/R.swift.svg?style=flat)](http://cocoapods.org/?q=R.swift) [![License](https://img.shields.io/cocoapods/l/R.swift.svg?style=flat)](blob/master/License) ![Platform](https://img.shields.io/cocoapods/p/R.swift.svg?style=flat) ![Build status](https://www.bitrise.io/app/cef05ad300903a89.svg?token=aPVYvCoJVcdVM-Z6KekYPQ&branch=master)

_Get strong typed, autocompleted resources like images, fonts and segues in Swift projects_

## Why use this?

It makes your code that uses resources:
- **Fully typed**, less casting and guessing what a method will return
- **Compile time checked**, no more incorrect strings that make your app crash at runtime
- **Autocompleted**, never have to guess that image name again

Currently you type:
```swift
let icon = UIImage(named: "settings-icon")
let font = UIFont(name: "San Francisco", size: 42)
let viewController = CustomViewController(nibName: "CustomView", bundle: nil)
```

With R.swift it becomes:
```swift
let icon = R.image.settingsIcon()
let font = R.font.sanFrancisco(size: 42)
let viewController = CustomViewController(nib: R.nib.customView)
```

Check out [more examples of R.swift based code](Documentation/Examples.md)!

## Demo

**Autocompleted images:**

![Autocompleted images](Documentation/Images/DemoUseImage.gif)

**Compiletime checked images:**

![Compiletime checked images](Documentation/Images/DemoRenameImage.gif)

This is only the beginning, check out [more examples](Documentation/Examples.md)!

## Features

After installing R.swift into your project you can use the `R`-struct to access resources. If the struct is outdated just build and R.swift will correct any missing/changed/added resources.

R.swift currently supports these types of resources:
- [Images](Documentation/Examples.md#images)
- [Custom fonts](Documentation/Examples.md#custom-fonts)
- [Resource files](Documentation/Examples.md#resource-files)
- [Colors](Documentation/Examples.md#colors)
- [Storyboards](Documentation/Examples.md#storyboards)
- [Segues](Documentation/Examples.md#segues)
- [Nibs](Documentation/Examples.md#nibs)
- [Reusable cells](Documentation/Examples.md#reusable-cells)

Runtime validation with [`R.assertValid()`](Documentation/Examples.md#runtime-validation):
- If all images used in storyboards are available
- If all view controllers with storyboard identifiers can be loaded

## Q&A

- [Why was R.swift created?](Documentation/QandA.md#why-was-rswift-created)
- [Why should I choose R.swift over alternative X or Y?](Documentation/QandA.md#why-should-i-choose-rswift-over-alternative-x-or-y)
- [What are the requirements to run R.swift?](Documentation/QandA.md#what-are-the-requirements-to-run-rswift)
- [How to use methods with a `Void` argument?](Documentation/QandA.md#how-to-use-methods-with-a-void-argument)
- [How to fix missing imports in the generated file?](Documentation/QandA.md#how-to-fix-missing-imports-in-the-generated-file)
- [How does R.swift work?](Documentation/QandA.md#how-does-rswift-work)
- [How to upgrade to 1.0?](Documentation/Migration.md)

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

0. Add the [R.swift.Library](https://github.com/mac-cain13/R.swift.Library#Installation) to your project
1. [Download](https://github.com/mac-cain13/R.swift/releases) a R.swift release, unzip it and put it into your source root directory
2. In XCode: Click on your project in the file list, choose your target under `TARGETS`, click the `Build Phases` tab and add a `New Run Script Phase` by clicking the little plus icon in the top left
3. Drag the new `Run Script` phase **above** the `Compile Sources` phase, expand it and paste the following script: `"$SRCROOT/rswift" "$SRCROOT"`
4. Build your project, in Finder you will now see a `R.generated.swift` in the `$SRCROOT`-folder, drag the `R.generated.swift` files into your project and **uncheck** `Copy items if needed`

_Tip:_ Add the `*.generated.swift` pattern to your `.gitignore` file to prevent unnecessary conflicts.

### Homebrew (Unofficial)

R.swift is also available through [Homebrew](http://brew.sh). This makes it possible to install R.swift globally on your system. Install R.swift by running: `brew install rswift`. The Homebrew formula is maintained by [@tomasharkema](https://github.com/tomasharkema).

## Contribute

We'll love contributions, read the [contribute docs](Documentation/Contribute.md) for info on how to report issues, submit ideas and submit pull requests!

## License

[R.swift](https://github.com/mac-cain13/R.swift) and [R.swift.Library](https://github.com/mac-cain13/R.swift.Library) are created by [Mathijs Kadijk](https://github.com/mac-cain13) and released under a [MIT License](License).
