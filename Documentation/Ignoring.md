# Ignoring resources

R.swift will discover resources used in your project automatically. To make sure you can continue to use R.swift in the rare case that a file gives problems it is possible to ignore resources.

It is also possible to only run certain generators to skip other `R.something` items.


## How does it work?

Create a `.rswiftignore` file in the source root of your project, this file will automatically be discovered by R.swift. The format of the file is nearly the same as [a `.gitignore` file](https://git-scm.com/docs/gitignore#_pattern_format). Wildcards like `*` and `**` are supported and you can add comments by starting a line with a `#`. Explicitly including single or multiple files that are otherwise globally ignored is also supported by starting a pattern with `!`.

_Note:_ All patterns are file paths relative to the path of the `.rswiftignore` file.

### Example

```
# Ignore a specific font file
fonts/myspecialfont.ttf

# Ignore all tiff and tif files in the images folder
images/*.tif
images/*.tiff

# Ignore all strings files wherever they are
**/*.strings

# Ignore all files containing '.ignore.'
**/*.ignore.*

# Explicitly include a single file
!keepme.ignore.png

# Explicitly include all files containing '.keepme.'
!**/*.keepme.*
```

## Custom file location

It is also possible to call the binary with the `--rswiftignore` flag and give a custom location of the ignore file this way.


## Only run specific generators (exclude R.something)
By default, R.swift runs all generators, for images, nibs, strings and many more. In some situations you may not want to generate R structs for all these types. You can choose to run only certain generators by adding a flag like this: `--generators image,string` to the call to the [Build Phase](/Documentation/Images/BuildPhaseExample.png)

These are the available generators:

- `image`
- `string`
- `color`
- `file`
- `font`
- `nib`
- `segue`
- `storyboard`
- `reuseIdentifier`
- `entitlements`
- `info`
- `id`
