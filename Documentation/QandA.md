# Questions and Answers

## Why was R.swift created?

Swift is a beautiful language and one of it's main advantages is its increasing popularity. However, it can be frustrating to deal with errors that compile but fail during runtime due to missing resources. This makes refactoring difficult while making it easy to create bugs (e.g. missing images etc).

Android tackles this problem by generating sosmething called the R class. It inspired me to create this very project, R.swift, which, thankfully, was well received by colleagues, friends and Github stargazers, so here we are now.``

## Why should I choose R.swift over alternative X or Y?

There are many nice R.swift alternatives like [SwiftGen](https://github.com/AliSoftware/SwiftGen), [Shark](https://github.com/kaandedeoglu/Shark) and [Natalie](https://github.com/krzyzanowskim/Natalie). However, I believe R.swift has these important advantages:
- R.swift inspects your Xcodeproj file for resources instead of scanning folders or asking you for files
- R.swift supports a lot of different assets
- R.swift stays very close to the vanilla Apple API's, having minimal code change with maximum impact

## What are the requirements to run R.swift?

R.swift works with Xcode 10 for apps targetting iOS 8 and tvOS 9 and higher.

## How do I use methods with a `Void` argument?

Xcode might autocomplete a function with a `Void` argument (`R.image.settingsIcon(Void)`); to solve this, simply remove the `Void` argument and you're good to go: `R.image.settingsIcon()`.

The reason this happens is because of the availability of the var `R.image.settingsIcon.*` for information about the image and also having a function with named the same name.

## How do I fix missing imports in the generated file?

If you get errors like `Use of undeclared type 'SomeType'` in the `R.generated.swift` file, this can usually be fixed by [explicitly stating the module in your xib or storyboard](Images/ExplicitCustomModule.png). This will make R.swift recognize that an import is necessary.

## How do I use classes with the same name as their module?

If you get errors like `'SomeType' is not a member type of 'SomeType'`, that means you are using a module that contains a class/struct/enum with the same name as the module itself. This is a known [Swift issue](https://bugs.swift.org/browse/SR-898).

You can work around this problem by [*emptying* the module field in the xib or storyboard](Images/ExplicitCustomModule.png) and then [adding `--import SomeType` as a flag](Images/CustomImport.png) to the R.swift build phase to ensure R.swift imports the module in the generated file.

## Can I use R.swift in a library?

Yes, just add R.swift as a buildstep in your library project and it will work just like normal. This works best if you have a dedicated Xcode project you can use to add the build script to. For Cocoapod users: this is [not the case](https://github.com/mac-cain13/R.swift/issues/430#issue-344112657) if you've used `pod lib create MyNewLib` to scaffold your library.

If you want to expose the resources to users of your library, you have to make the generated code public, you can do this by adding `--accessLevel public` to the call to R.swift. For example, if you included R.swift as a cocoapod dependency to your library project, you would change your build step to: `"$PODS_ROOT/R.swift/rswift" generate --accessLevel public "$SRCROOT"`

## How does R.swift work?

During installation you add R.swift as a Build phase to your target, basically this means that:
- Every time you build R.swift will run
- It takes a look at your Xcode project file and inspects all resources linked with the target currently build
- It generates a `R.generated.swift` file that contains a struct with types references to all of your resources 

