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

R.swift works with iOS 8 and tvOS 9 and higher, your development machine should be on OS X 10.11 with Xcode 7 or higher.

## How to use methods with a `Void` argument?

Xcode might autocomplete a function with a `Void` argument (`R.image.settingsIcon(Void)`), just remove the `Void` argument and you're good to go: `R.image.settingsIcon()`.

The reason this happens is because of the availability of the var `R.image.settingsIcon.*` for information about the image and also having a function with named the same name.

## How to fix missing imports in the generated file?

If you get errors like `Use of undeclared type 'SomeType'` in the `R.generated.swift` file most of the time this can be fixed by [explicitly stating the module in your xib or storyboard](Images/ExplicitCustomModule.png). This will make R.swift recognize that an import is necessary.

## Can I use R.swift in a library?

Yes, just add R.swift as a buildstep in your library project and it will work just like normal. If you want to expose the resources to users of your library you have to make the generated code public, you can do this by adding `--accessLevel public` to the call to R.swift.

For example Cocoapods users would change their build step to: `"$SRCROOT/rswift" --accessLevel public "$SRCROOT"`

## How does R.swift work?

During installation you add R.swift as a Build phase to your target, basically this means that:
- Every time you build R.swift will run
- It takes a look at your Xcode project file and inspects all resources linked with the target currently build
- It generates a `R.generated.swift` file that contains a struct with types references to all of your resources

