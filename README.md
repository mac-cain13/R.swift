# TypedImages
_Tool to help you use strong typed images in Swift_

## Why use this?

Normally you access your images from the `Images.xcassets` folder with `UIImage(names: "Something")` this sucks because the compiler won't warn you about unexisting images, which means you will get errors at runtime!

With TypedImages we make sure you can do `Images.Something` to get your image, the `Images` class will be automatically update on build. So it's never outdated and you will get compiler errors if you rename or delete an image.

## Setup

Todo

## License

TypedImage is released under MIT License and created by Mathijs Kadijk.
