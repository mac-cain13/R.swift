# Migration

Pointers for migration between major versions.

## Upgrading to 1.0

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
