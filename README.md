# TypedImages
_Tool to help you use strong typed images in Swift_

## Why use this?

Normally you access your images from the `Images.xcassets` folder with `UIImage(names: "Something")` this sucks because the compiler won't warn you about unexisting images, which means you will get errors at runtime!

With TypedImages we make sure you can do `Images.Something` to get your image, the `Images` class will be automatically update on build. So it's never outdated and you will get compiler errors if you rename or delete an image.

## Usage

After installing TypedImages into your project you can use the name of the `xcassets` folder followed by the name of the image as you named it in the assets folder. If the file is outdated just press build and TypedImages will correct the missing/changed images for you.

## Installation

1. [Download](https://github.com/mac-cain13/TypedImages/releases) a TypedImage release, unzip it and put it into your source root directory
2. In XCode: Click on your project in the file list, choose your target under `TARGETS`, click the `Build Phases` tab and add a `New Run Script Phase` by clicking the little plus icon in the top left
3. Drag the new `Run Script` phase *above* the `Compile Sources` phase, expand it and paste the following script: `"$SRCROOT/TypedImages" "$SRCROOT"`
4. Build your project, in Finder you will now see `*.generated.swift` files along side the `*.xcassets` folders, drag the `*.generated.swift` file into your project

_Optional:_ Add the `*.generated.swift` to your `.gitignore` file to prevent unnecessary conflicts.

## Contribute

Please post any issues, ideas and compliments in the GitHub issue tracker and feel free to submit pull request with fixes and improvements. Keep in mind; a good pull request is small, well explained and should benifit most of the users.

## License

TypedImage is released under MIT License and created by Mathijs Kadijk.
