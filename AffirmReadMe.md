# Affirm R.swift

We use our own version of R.swift forked from [https://github.com/mac-cain13/R.swift](https://github.com/mac-cain13/R.swift).

The Affirm repo is at [https://github.com/Affirm/R.swift](https://github.com/Affirm/R.swift).

Code generation extensions:

* Adds a new CLI flag to turn off missing string warnings.
  - This is the `silenceLanguageWarnings` command flag.

* Adds a default language to each generated string function.
  - Defaults to the current value of `R.affirm_preferredLanguageIdentifier`.
  - Changeable during runtime.

* An R.swift internal change that allows struct generators to create either `var` or `let` variables.
  - This was added to allow changes to `R.affirm_preferredLanguageIdentifier` during runtime.

* Added `AffirmLocalizedString` and `AffirmDisplayKey` to R.swift string generation to prevent
  leaking string key names if a language bundle is not found. This is only affects keys in
  `Confidential.strings` language tables.

## R.Swift Overview

R.swift scans the resources of an Xcode project and generates type safe and name safe Swift code
that loads the resources. The `rswift` command line tool generates the files at build time.

R.swift also has a support library called `R.swift.Library` located at
[mac-cain13/R.swift.Library](https://github.com/mac-cain13/R.swift.Library). The library contains
class extensions and helper code to make R.swift easier to use. After we upgrade to version 7 of
R.swift this will no longer be needed as this will be included as part of the code generation.

## Development Process

1. Pull the repo from [https://github.com/Affirm/R.swift](https://github.com/Affirm/R.swift).

2. Create your development branch off of `affirm-main` branch. The `affirm-main` is the branch
   with all the Affirm specific changes.

3. When opening a PR, use `Affirm` / `affirm-main` as the base branch and land your changes there.
   You'll need a PR review to land to `affirm-main`.

4. You can open the R.swift `Package.swift` like an Xcode project file and code using the IDE while
   updating the code.

The R.swift coding philosophy is helpful in understanding their design choices:
[R.swift development philosophy](https://github.com/mac-cain13/R.swift/issues/177)

The Affirm extensions don't strictly follow the philosophy but it's nice to know.

### Command Line Builds

```bash
cd ./R.swift
swift build # Build for debugging.
swift test  # Run tests
swift build -c release --arch arm64 --arch x86_64 # Make a release fat binary.
```

The build products are in the `.build` folder which is a hidden dot directory (so helpful). Open
it from the command line with `open .build` and it'll open in a Finder window.

## Updating Affirm R.Swift to the latest origin version

All the Affirm changes are on the `affirm-main` branch so we can pull the fork-origin `master`
branch and rebase `affirm-main` onto it, preserving our changes when updating to the latest R.swift.

1. Checkout `master`.
2. Pull from their remote to refresh our master and push.
3. Rebase `affirm-main` on top off the new master.
4. Rebuild our tool.
