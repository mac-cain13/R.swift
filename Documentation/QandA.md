# Questions and Answers

## Why was R.swift created?

Swift is a beautiful language and one of it's main advantages is that more and more is typed. This catches a lot of errors at compile time. It feels very strange to refer to resources with strings that will always compile and then fail at runtime. It makes refactoring hard and it's to easy to create bugs like missing images etc.

In Android there is a generated R class that kind of solves this problem. That was why I decided to make something like it for us Swift developers and called the project R.swift. It was well received by colleagues, friends and Github stargazers, so here we are now.

## Why should I choose R.swift over alternative X or Y?

There are many nice R.swift alternatives like [SwiftGen](https://github.com/AliSoftware/SwiftGen), [Shark](https://github.com/kaandedeoglu/Shark) and [Natalie](https://github.com/krzyzanowskim/Natalie). I believe R.swift has important advantages over all of them:
- R.swift inspects your Xcodeproj file for resources instead of scanning folders or asking you for files
- R.swift supports a lot of different assets
- R.swift stays very close to the vanilla Apple API's, it's a minimal code change with maximum impact

## What are the requirements to run R.swift?

R.swift works with Xcode 10 for apps targetting iOS 8 and tvOS 9 and higher.

## How to use methods with a `Void` argument?

Xcode might autocomplete a function with a `Void` argument (`R.image.settingsIcon(Void)`), just remove the `Void` argument and you're good to go: `R.image.settingsIcon()`.

The reason this happens is because of the availability of the var `R.image.settingsIcon.*` for information about the image and also having a function with named the same name.

## How to fix missing imports in the generated file?

If you get errors like `Use of undeclared type 'SomeType'` in the `R.generated.swift` file most of the time this can be fixed by [explicitly stating the module in your xib or storyboard](Images/ExplicitCustomModule.png). This will make R.swift recognize that an import is necessary.

## How to use classes with the same name as their module?

If you get errors like `'SomeType' is not a member type of 'SomeType'` you're using a module that contains a class/struct/enum with the same name as the module itself. This is a known [Swift issue](https://bugs.swift.org/browse/SR-898).

Work around this problem by [*emptying* the module field in the xib or storyboard](Images/ExplicitCustomModule.png). Then [add `--import SomeType` as a flag](Images/CustomImport.png) to the R.swift build phase to make sure R.swift imports the module in the generated file.

## Can I use R.swift in a library?

Yes, just add R.swift as a buildstep in your library project and it will work just like normal. This works best if you have a dedicated Xcode project you can use to add the build script to. For Cocoapod users: this is [not the case](https://github.com/mac-cain13/R.swift/issues/430#issue-344112657) if you've used `pod lib create MyNewLib` to scaffold your library.

If you want to expose the resources to users of your library you have to make the generated code public, you can do this by adding `--accessLevel public` to the call to R.swift. For example, if you included R.swift as a cocoapod dependency to your library project, you would change your build step to: `"$PODS_ROOT/R.swift/rswift" generate --accessLevel public "$SRCROOT"`

## How does R.swift work?

During installation you add R.swift as a Build phase to your target, basically this means that:
- Every time you build R.swift will run
- It takes a look at your Xcode project file and inspects all resources linked with the target currently build
- It generates a `R.generated.swift` file that contains a struct with types references to all of your resources

