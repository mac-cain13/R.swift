## 5.0.0

- Compatible with Xcode 10 / iOS 12 SDK, this release is not compatible with older versions use R.swift 4 if you still need that compatibility
- Removed CLR file support, use color resources instead
- Easier nib loading with new method
- Ignore file supports explicit include (by @renrawnalon)
- Validation for named colors
- Empty structs are not generated anymore (by @soberman)
- Update XcodeEdit
- Performance tweaks by @bclymer
- Fix for validate images by @cooler333
- Nib parsing fixes for Xcode 10 from @rafaelnobrepd

## 5.0.0.rc.2

- Improve R.swift 5 migration errors

## 5.0.0.rc.1

- Xcode 10 compatibility fixes

## 5.0.0.alpha.3

- Update XcodeEdit
- Performance tweaks by @bclymer
- Fix for validate images by @cooler333

## 5.0.0.alpha.2

- Nib parsing fixes for Xcode 10 from @rafaelnobrepd

## 5.0.0.alpha.1

- Removed CLR file support, use color resources instead
- Easier nib loading with new method
- Ignore file supports explicit include (by @renrawnalon)
- Validation for named colors
- Empty structs are not generated anymore (by @soberman)
- Compatible with Xcode 10 / Swift 4.2 / iOS 12 SDK, this release is not compatible with older versions use R.swift 4 if you still need that compatibility

## 4.0.0

- Improved Xcodeproj errors
- New color assets are now supported
- Better capitalization is now enabled by default
- Xcode 9/Swift 4/SPM fixes
- Deprecate clr based color resources
- Introduce color asset based color resources

## 4.0.0.alpha.4

- Changes for latest Swift 4 betas
- Improved Xcodeproj errors

## 4.0.0.alpha.3

- New color assets are now supported
- Better capitalization is now enabled by default
- Use new XcodeEdit version that warns when your projectfile is corrupt
- Xcode 9/Swift 4/SPM fixes

## 4.0.0.alpha.2

- Fix incorrectly merged color PR

## 4.0.0.alpha.1

- Deprecate clr based color resources
- Introduce color asset based color resources

## 3.3.0

*New features:*
- Better checks for color spaces in clr files
- Include base translation in R.strings code

*Fixed issues:*
- Validating images from nibs now respects bundle

*Other:*
- We now use swift package manager as our build tool

## 3.3.0.beta.1

*New features:*
- Better checks for color spaces in clr files

*Fixed issues:*
- Validating images from nibs now respects bundle

*Other:*
- We now use swift package manager as our build tool

## 3.2.0

New features:
- Added option to explicitly import modules (fixes #277)
- Support for an ignore file to skip resources (thanks @shiraji / fixes #276)
- Add edge flag to enable new stable feature that are breaking changes
- New nicer casing of identifiers (is behind the edge flag)

Bugfix:
- Load hosting bundle by class instead of identifier (fixes #293)

## 3.1.0

New features:

- Support for `--accessLevel public` flag that makes all `R` things public (handy for libraries)
- Handle multiple locales for resource files (`R.file.*`) by @tomlokhorst
- Add some more checks while parsing nibs by @Tvede-dk
- Use fully qualified names in the generated file to prevent naming conflicts
- Validation for custom fonts and images in nibs

Deprecated:
- Deprecated `assertValid` method, use `validate` from a test instead

Bugfix:

- Duplicate printed errors on storyboards
- Validation generated not compilable code when duplicate storyboard identifiers where present

## 3.0.0

New features:

- Swift 3 support

**Breaking changes:**
- Swift 2 is not supported anymore, use the 2.* versions for Swift 2
- Some methods are renamed, those are annotated with an availability annotation so the compiler will help you rename

## 2.5.0

New features:

- Bundle is used in string resources

Bugfix:

- Detect all segues correctly
- Fix namespace problems with validation errors

## 2.4.0

New features:

- Swift 2.3 support

## 2.3.0

New features:
- Add `--version` parameter that shows the version of R.swift you are running

Fixed issues:
- Use correct locale for localized strings
- Fix typo in generated comments (by @waywalker)

## 2.2.2

Fixed issues:

- Fix for using CR + LF in localized strings (by @tomlokhorst)

## 2.2.1

This is an incorrectly released version and is therefore exactly the same as 2.2.0.

## 2.2.0

New features:
- Localized string support (by @renrawnalon and @tomlokhorst)

Fixed issues:
- Updated reserved keywords (by @tomlokhorst)

## 2.1.0

New features:
- Add support for "imagestack" assets, parallax images used on AppleTV (@chillpop) 

## 2.0.0

Fixed issue:
- Use new version of R.swift.Library to avoid Swift 2.2 warnings
- This version is not compatible with Swift 2.1 and therefore a breaking change, use 1.4.2 if you need Swift 2.1 compatibility.

## 1.4.2

Fixed issue:
- Make this version compatible with Swift 2.1
- This release is exactly the same version as 1.4.0

## 1.4.1

**Note: Do not use this version, use version 2.0.0 or 1.4.2 instead.**

Fixed issue:
- Use new version of R.swift.Library to avoid Swift 2.2 warnings

## 1.4.0

New features:
- Added support for CLR color lists (@tomlokhorst)
- SwiftDoc comments are generated in the `R.generated.swift` file (@tomlokhorst)
- R.swift is made available on Homebrew (maintained by @tomasharkema)
- Synthesizing let accessors for storyboard identifiers (@JaviSoto)
- New `NSData(resource: R.file.someFile)` constructor is now available (@tomlokhorst)

Fixed issues:
- **Breaking:** `R.file.someFile() as String` is removed to prevent ambiguity errors, use `R.file.someFile.path()` instead (@tomlokhorst)
- Generated variable/function names will never be empty anymore (@tomlokhorst)
- If the first view in a nib is a standard Apple Interface Builder class it will now typecast correctly instead of falling back to `UIView`
- NSBundle now falls correctly back on the main bundle, this was documented as such but did not always happen
- Swift keyword list updated to avoid generation of invalid variable/function names

## 1.3.0
New features:
- `R.file.*.path()` and `R.file.*.url()` are now available

Fixed issues:
- It was possible to invoke segues that didn’t match the source view controller, this is fixed now by restricting some types
- Support `UICollectionReusableView` as root view in a nib

## 1.2.0
New features:
- Unwind segues are now supported

Fixed issues:
- Avoid creation of empty validate methods

## 1.1.1

Fixed issues:
- Validate methods could have invalid code in their body
- Help exited with code 1, should be 0
- Also; Improved compile time by 7 seconds with some small code changes

## 1.1.0

New features:
- Storyboard references are now supported

Fixed issues:
- Segues from views did crash R.swift

## 1.0.2

Fixed issues:
- `Validateable` was not written out as `Rswift.Validateable` in all cases

## 1.0.1

Fixed issues:
- `Validatable` collision, since it's quite a common name R.swift now states explicitly it means the one in the R.swift.Library
- Imports where missing when the module was only used in the generated code in a inferred way
- The code to call the `_R.validate()` function was always generated, it's now conditional and only generated when needed

## 1.0.0

**Breaking changes:**
- iOS 7 support is dropped, use [R.swift 0.13](https://github.com/mac-cain13/R.swift/releases/tag/v0.13.0) if you still have to support it.
- Generated code now depends on the [R.swift.Library](https://github.com/mac-cain13/R.swift.Library), CocoaPods users don't need to do anything. Manual installation users need to include this library themselves, see the readme for instructions.
- In general; properties that created new stuff are now functions to represent better that they actually create a new instance.
 * `R.image.settingsIcon` changed to  `R.image.settingsIcon()`
 * `R.file.someJson` changed to `R.file.someJson()`
 * `R.storyboard.main.initialViewController` changed to `R.storyboard.main.initialViewController()`
 * `R.storyboard.main.someViewController` changed to `R.storyboard.main.someViewController()`
- In general; Where you needed to use `.initialize()` to get the instance, a shorter function is available now:
 * `R.storyboard.main.initialize()` changed to `R.storyboard.main()`
 * `R.nib.someView.initiate()` changed to `R.nib.someView()`
- Nib root view loading changed from `R.nib.someView.firstView(nil, options: nil)` to `R.nib.someView.firstView(owner: nil)`
- Typed segue syntax changed from `segue.typedInfoWithIdentifier(R.segue.someViewController.someSegue)` to `R.segue.someViewController.someSegue(segue: segue)`
- Runtime validation changed:
 * `R.validate()` now throws errors it encounters
 * `R.assertValid()` asserts on errors and only performs action in a debug/non-optimized build
 * For regular use cases using `R.assertValid()` is recommended

**Major features and fixes:**
- Writing extensions for R.swift generated code is possible by using the types from the new [R.swift.Library](https://github.com/mac-cain13/R.swift.Library)
- Improved `import`statements, R.swift will detect modules that you use and import them in the generated file.
- Improved error reporting, on incorrect calls to the `rswift` binary as well as during project parsing
- `UITraitCollection` can be specified when loading images
- The `String` based path as well as the `NSURL` of a file can now easily be accessed thanks to an overloaded function
- Constructors are available for all types to provide more flexibility and late initialization (eg. passing a `ImageResource` around and only creating the image with the special `UIImage` constructor when you need it)
- Information about resources is now accessible, a few examples:
 * `R.image.settingsIcon.name` returns the name of the image
 * `R.nib.myCell.identifier` returns the reuse identifier string of the cell
 * `R.storyboard.main.name` returns the name of the storyboard

## 0.13

New typed segues
- iOS 7 compatible image loading
- Upgrade notice:
- The new R.segue.* structure is a breaking change, upgrading will give you compile errors because the structure has changed.

_Old:_ R.segue.mySegue
_New:_ R.segue.myViewController.mySegue

This enables you to reuse segue identifier names between different source view controllers. Segues now also contain type information. See [the documentation](https://github.com/mac-cain13/R.swift/blob/master/Documentation/Examples.md#segues) on how you can leverage from that.

## 0.12

Fixes use of a R.generated.swift-file in a different than the main bundle:

- Loading of assets now use a specific bundle instead of the main bundle
- Mentioning of the bundle name in types is now only done when it's not the bundle the R-file is generated for

## 0.11

- Correct @2x/3x loading for non-PNG files and device specific suffixes like ~ipad and ~iphone
- Use correct product name during build (Thanks @kylejm)
- Support tvOS in podspec (Thanks @tomlokhorst for testing basic tvOS support)
- Better cleanup of invalid characters in filenames when converting to variable names, also preserve capitals for better readability

## 0.10

- Support for images outside of an asset folder (like jpeg images: R.image.gradientJpg)
- Support for resource files in your project (like video files: R.file.myVideoMov)
- Reads projectfile instead of scanning folders (Thanks to Xcode.swift)
- Ability to take flags in the call to R.swift like: rswift --target MyApp ./outputFolder (Thanks to OptionKit)
- Improved documentation and Readme

## 0.9

- Swift 2 support
- Duplicated identifier detection
- A few other small improvements

## 0.8.5

Fixes incorrect handling of Nib names with a space in them, see issue #56.

## 0.8.4

When using the assistant editor Xcode will not sugged the R.generated.swift file as a good place to add outlets and such.

## 0.8.3

Fixes lowercase issue in previous release

## 0.8.1

- Spaces in image names are now supported
- Introduced registerNibs to register multiple nibs at once

## 0.8

This release adds features to use typed overloads of table- and collectionview methods:

- registerNib with R.nib.*
- dequeueSomethingSomething(R.reuseIdentifier.*) and get an object of the correct type returned

## 0.7.1

- R.swift now support asset catalog folders/groups
- Fix when using assets that have names that are Swift keywords, they are now properly escaped

## 0.7

- Rewrote codebase to Swift 1.2
- Added R.storyboard.[name].initialViewController to get the initial view controller from a storyboard
- Added missing newline if using multiple storyboard

## 0.6.1

Fixed a bug where some files where skipped during search and not included in the R-struct. This is now fixed.

## 0.6

- Added support for nibs(/xibs) use R.nib.[name].firstView to get the first view in your nib fully typed!
- All reuse identifiers in your project (nibs and storyboards) are available under R.reuseIdentifier.[name]
- We now leave the generated file untouched if there are no updates
- Errors in executing R.swift will now appear in between you Xcode build errors/warnings
- UIViewController subclasses in your storyboard (like UINavigationController or UISplitviewController) are now correctly typed
- Internal rewrite in the way we generate the R-struct

## 0.5.1

This release fixes an issue where not importing UIKit import can sometimes give compile errors.

## 0.5

Now you also can load view controllers from a Storyboard without using strings. You can access them with R.storyboard.[name].[viewControllerIdentifier]. They are even validated when you call R.validate()!

## 0.4

In this release a serie of improvements in the codebase as well as in the generated struct. The new resources can be accessed through:

- UIImage: R.image.[imageName]
- UIStoryboardSegue identifier: R.segue.[segueIdentifier]
- UIStoryboard: R.storyboard.[storyboardName].instance
- Validate images used in the given storyboard: R.storyboard.[storyboardName].validateImages()
- Validate all images in all storyboards: R.validate()

## 0.3

R.swift now generated strongly typed segues and provides methods to validate if the images used in your storyboard do exist.

- R.[storyboardName].[segueIdentifier] to get the identifier of a segue
- R.validateStoryboardImages() to validate images in all storyboards
- R.[storyboardName].validateStoryboardImages() to validate images in a single storyboard

## 0.2

Better structure, better name, lots of breaking changes!

- Renamed from TypedImages via Strongly to R.swift
- Refactored about all of the code
- Now use R.[assetFolder].[imageName] instead of the UIImage.* approach

## 0.1

- First public release