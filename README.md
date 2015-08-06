# R.swift ![Build status](https://www.bitrise.io/app/cef05ad300903a89.svg?token=aPVYvCoJVcdVM-Z6KekYPQ&branch=master)
_Tool to get strong typed, autocompleted resources like images, cells and segues in Swift_

## Why use this?

It makes your code that uses resources:
- **Fully typed**, less casting and guessing what a method will return
- **Compiletime checked**, no more incorrect strings that make your app crash on runtime
- **Autocompleted**, never have to guess that image name again

Currently you type:
```swift
let icon = UIImage(named: "settings-icon")
let cell = dequeueReusableCellWithReuseIdentifier("textCell", forIndexPath: indexPath) as? TextCell
performSegueWithIdentifier("openSettings")
```

With R.swift it becomes:
```swift
let icon = R.image.settingsIcon
let cell = dequeueReusableCellWithReuseIdentifier(R.reuseIdentifier.textCell, forIndexPath: indexPath)
performSegueWithIdentifier(R.segue.openSettings)
```

## Usage

After installing R.swift into your project you can use the `R`-struct to access resources. If the struct is outdated just build and R.swift will correct any missing/changed/added resources.

R.swift currently supports:
- [X] Images
- [X] Segues
- [X] Storyboards
- [X] Nibs
- [X] Reusable cells
- [ ] Files in your bundle

Below you find the different formats:

Type             | Format                                                     | Without R.swift                           | With R.swift
-----------------|------------------------------------------------------------|-------------------------------------------|-----------------------------
Image            | `R.image.[imageName]`                                      | `UIImage(named: "settings-icon")`         | `R.image.settingsIcon`
Segue            | `R.segue.[segueIdentifier]`                                | `"openSettingsSegue"`                     | `R.segue.openSettingsSegue`
Storyboard       | `R.storyboard.[storyboardName].instance`                   | `UIStoryboard(name: "Main", bundle: nil)` | `R.storyboard.main.instance`
ViewController   | `R.storyboard.[storyboardName].[viewControllerIdentifier]` | `UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LoginController") as? LoginController` | `R.storyboard.main.loginController`
Nib              | `R.nib.[nibName].instance`                                 | `UINib(nibName: "TextCell", bundle: nil)` | `R.nib.textCell.instance`
Nib all views    | `R.nib.[nibName].instantiateWithOwner(nil, options: nil)`  | `UINib(nibName: "TextCell", bundle: nil).instantiateWithOwner(nil, options: nil)`  | `R.nib.textCell.instantiateWithOwner(nil, options: nil)`
Nib first view   | `R.nib.[nibName].firstView(nil, options: nil)`             | `UINib(nibName: "TextCell", bundle: nil).instantiateWithOwner(nil, options: nil).first as? TextCell` | `R.nib.textCell.firstView(nil, nil)`
Reuse identifier | `R.reuseIdentifier.[name]`                                 | `"TextCell"`                              | `R.reuseIdentifier.textCell`

Validate usage of images in Storyboards with `R.validate()` or to validate a specific storyboard use `R.storyboard.[storyboardName].validateImages()`. Please note that this uses `assert` and will only work in unoptimized debug builds.

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

## Tips and tricks

*Running R.swift gives errors like `29593 Trace/BPT trap: 5`, how to fix them?*

Make sure you run OS X 10.10 or higher with XCode 6.1+. Lower versions are not supported and could lead to errors like these.

*R.swift also picks up asset files/storyboards from submodules and CocoaPods, can I prevent this?*

You can by changing the second argument (`"$SRCROOT"` in the example) of the build phase script, this is the folder R.swift will scan through. If you make this your project folder by changing the script to `"$SRCROOT/rswift" "$SRCROOT/MyProject"` it will only scan that folder.

*Can I make R.swift scan multiple folder trees?*

You can by passing multiple folders to scan through. Change the build phase script to something like this: `"$SRCROOT/rswift" "$SRCROOT/MyProject" "$SRCROOT/SubmoduleA" "$SRCROOT/SubmoduleB"`. Each folder will get it's own `R.generated.swift` file since R.swift assumes these folders will be different subprojects.

*When I launch `rswift` from Finder I get this "Unknown developer warning"?!*

For now I'm to lazy to sign my builds with a Developer ID and when running stuff from the commandline/XCode it's not a problem. It will just work, but maybe I'll fix this. Signed releases are nice, now I only need to find some time to fix this. :)

## Contribute

Please post any issues, ideas and compliments in the GitHub issue tracker and feel free to submit pull request with fixes and improvements. Keep in mind; a good pull request is small, well explained and should benifit most of the users.

## License

R.swift is released under [MIT License](License) and created by [Mathijs Kadijk](https://github.com/mac-cain13).
