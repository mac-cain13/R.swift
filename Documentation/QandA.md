# Questions and Answers

## Why was R.swift created?

Swift is a beautiful language and one of it's main advantages is that more and more is typed. This catches a lot of errors at compile time. It feels very strange to refer to resources with strings that will always compile and then fail at runtime. It makes refactoring hard and it's to easy to create bugs like missing images etc.

In Android there is a generated R class that kind of solves this problem. That was why I decided to make something like it for us Swift developers and called the project R.swift. It was well received by colleagues, friends and Github stargazers, so here we are now.

## Why should I choose R.swift over alternative X or Y?

There are many nice R.swift alternatives like [Shark](https://github.com/kaandedeoglu/Shark), [Natalie](https://github.com/krzyzanowskim/Natalie) and [SwiftGen](https://github.com/AliSoftware/SwiftGen). I believe R.swift has important advantages over all of them:
- R.swift inspects your Xcodeproj file for resources instead of scanning folders or asking you for files
- R.swift supports a lot of different assets
- R.swift stays very close to the vanilla Apple API's, it's a minimal code change with maximum impact

## What are the requirements to run R.swift?

Recommended is the latest stable version of OS X, Xcode with the app targeting iOS 8 or higher. But OS X 10.10 with Xcode 7 while targeting iOS 7 or higher should work. R.swift should also always be runned within the Xcode build process since it needs some of the environment variables. Otherwise it could throw errors at you.

## How does R.swift work?

During installation you add R.swift as a Build phase to your target, basically this means that:
- Every time you build R.swift will be runned
- It takes a look at your Xcode project file and inspects all resources linked with the target currently build
- It generates a `R.generated.swift` file that contains a struct with types references to all resources
