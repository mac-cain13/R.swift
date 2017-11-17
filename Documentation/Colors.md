About Colors
============

R.swift can parse .clr color palette files and generate structs in `R.clr.*`.
This is useful if you're using .clr color palettes as the source of colors in your project.

_NOTE: Make sure the .clr file is part of the project, and a member of the target, for R.swift to pick it up._ 

A potential work flow is this:
> A designer maintains a color palette called `App Colors.clr`, a developer refers to colors like so: `R.clr.appColors.errorColor()`.
>
> When the designer updates the color, the new `App Colors.clr` file is copied to the project, and R.swift will generate a new color constant with the same identifier.

There are some things to be aware of to using .clr files in a Xcode project:

- `.clr` files must be placed in the `~/Library/Colors` directory to show up in Mac OSX's color picker. The color picker is used across different applications, for example in Pixelmator and Interface Builder.
- `.clr` files are binary, so conflicts between two versions of the same file are not easily resolved.
- Colors chosen from a color palette in Interface Builder are _copied_ to the .xib or .storyboard, they're not references. If the color palette changes, the old colors are still used in Interface Builder.

The above points are not resolved by R.swift, so keep these in mind when using color palettes!

### Further reading

- Discussion on using [other file formats](https://github.com/mac-cain13/R.swift/issues/204)
- R.swift issue: [Add support for R.colors from .clr files](https://github.com/mac-cain13/R.swift/issues/169)
- Natasha The Robot: [Xcode Tip: Color palette](http://natashatherobot.com/xcode-color-palette/)
