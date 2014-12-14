# Strongly
_Tool to help you use strong typed images in Swift_

## Why use this?

Normally you access your images from the `Images.xcassets` folder with `UIImage(names: "Something")` this sucks because the compiler won't warn you about unexisting images, which means you will get errors at runtime!

With Strongly we make sure you can do `UIImage.imageSomething` to get your image, the `UIImage` extension will be automatically update on build. So it's never outdated and you will get compiler errors if you rename or delete an image.

## Usage

After installing Strongly into your project you can use the name of the `xcassets` folder followed by the name of the image as you named it in the assets folder. If the file is outdated just build and Strongly will correct the missing/changed images for you.

## Installation

1. [Download](https://github.com/mac-cain13/Strongly/releases) a Strongly release, unzip it and put it into your source root directory
2. In XCode: Click on your project in the file list, choose your target under `TARGETS`, click the `Build Phases` tab and add a `New Run Script Phase` by clicking the little plus icon in the top left
3. Drag the new `Run Script` phase *above* the `Compile Sources` phase, expand it and paste the following script: `"$SRCROOT/strongly" "$SRCROOT"`
4. Build your project, in Finder you will now see `*.generated.swift` files next to the Strongly binary, drag the `*.generated.swift` files into your project

_Optional:_ Add the `*.generated.swift` pattern to your `.gitignore` file to prevent unnecessary conflicts.

## Tips and tricks

*Strongly also picks up asset files from submodules and CocoaPods, can I prevent this?*

You can by changing the second argument (`"$SRCROOT"` in the example) of the build phase script, this is the folder Strongly will scan through. If you make this your project folder by changing the script to `"$SRCROOT/strongly" "$SRCROOT/MyProject"` it will only scan that folder.

*Can I make strongly scan multiple folder trees?*

You can by passing multiple folders to scan through. Change the build phase script to something like this: `"$SRCROOT/strongly" "$SRCROOT/MyProject" "$SRCROOT/SubmoduleA" "$SRCROOT/SubmoduleB"`

## Contribute

Please post any issues, ideas and compliments in the GitHub issue tracker and feel free to submit pull request with fixes and improvements. Keep in mind; a good pull request is small, well explained and should benifit most of the users.

## License

Strongly is released under [MIT License](License) and created by [Mathijs Kadijk](https://github.com/mac-cain13).
