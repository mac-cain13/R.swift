# Thank you!

Thank you for taking some of your precious time helping this project move forward. Really great that you're showing interest in contributing. You don't have to be an expert to help us, every small tweak, crazy idea and/or bugreport is highly appreciated!

# Contributing

## Questions, issues and ideas

Most important is to read the docs and scan the issue tracker before so you're sure your question/idea/bugreport isn't already answered/in the make/being fixed:

- [Read the Readme](https://github.com/mac-cain13/R.swift/blob/master/Readme.md)
- [Read the other documentation](https://github.com/mac-cain13/R.swift/tree/master/Documentation)
- [Check open pull requests](https://github.com/mac-cain13/R.swift/pulls)
- [Search the issue tracker](https://github.com/mac-cain13/R.swift/issues)

If you find your idea/bugreport feel free to comment with an emoji or text reaction to let us know that you'd like this to be implemented. Is your idea/bugreport not in there? Please submit it to the [issue tracker](https://github.com/mac-cain13/R.swift/issues)!

## Pull requests

If you'd like to implement a feature:

- Check [the steps above](#questions-issues-and-ideas) to make sure it isn't already being build
- Feel free to discuss the change in an issue, this will increase the chance of it being merged in
- Keep your PR small, so it's easy to review
- Follow the coding guidelines below

### Coding guidelines

Principles R.swift code should follow:

- Follow existing patterns/code style; Pattern/style improvements should go in a seperate issue/PR
- Warn the user if you're skipping items
- Code defensively; most formats we parse are undocumented and will change without notice

Principles generated code should follow:

- Never crash; No use of ! for example.
- Always compile; Rather skip an item than generate corrupt code.
- Clarity over brevity; Don't use R.swift.Library methods for example ([Read more](https://github.com/mac-cain13/R.swift/issues/177))
- Generate inline comments where it's relevant
