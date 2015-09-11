# Examples

On this page you'll find some examples of what kind of resources R.swift supports and how you can use them.

## Images

R.swift will find images available in Asset Catalogs in your project.

*Vanilla*
```swift
let image = UIImage(named: "settings-icon")
```

*With R.swift*
```swift
let image = R.image.settingsIcon
```

## Storyboards

*Vanilla*
```swift
let storyboard = UIStoryboard(name: "Main", bundle: nil)
let initialTabBarController = storyboard.instantiateInitialViewController() as? UITabBarController
let settingsController = self.instantiateViewControllerWithIdentifier("settingsController") as? SettingsController
```

*With R.swift*
```swift
let storyboard = R.storyboard.main.instance
let initialTabBarController = R.storyboard.main.initialViewController
let settingsController = R.storyboard.main.settingsController

// Validate at runtime if all images used in the storyboard can be loaded.
// Uses assertions and only has effect when your app is in debug mode.
R.storyboard.main.validateImages()

// Validate if view controllers with identifiers can be loaded
// Uses assertions and only has effect when your app is in debug mode.
R.storyboard.main.validateViewControllers()
```

**Tip:** Use `R.validate()` to call all validation methods at once and put it somewhere into you `AppDelegate`.

## Segues

*Vanilla*
```swift
performSegueWithIdentifier("openSettings")
```

*With R.swift*
```swift
performSegueWithIdentifier(R.segue.openSettings)
```

## Nibs

*Vanilla*
```swift
let nameOfNib = "CustomView"
let customViewNib = UINib(nibName: "CustomView", bundle: nil)
let rootViews = customViewNib.instantiateWithOwner(nil, options: nil)
let customView = rootViews[0] as? CustomView

let viewControllerWithNib = CustomViewController(nibName: "CustomView", bundle: nil)
```

*With R.swift*
```swift
let nameOfNib = R.nib.customView.name
let customViewNib = R.nib.customView
let rootViews = R.nib.customView.instantiateWithOwner(nil, options: nil)
let customView = R.nib.customView.firstView(nil, options: nil)

let viewControllerWithNib = CustomViewController(nib: R.nib.customView)
```

## Reusable cells

*Vanilla*
```swift
class FaqAnswerController: UITableViewController {
	override func viewDidLoad() {
	    super.viewDidLoad()
	    let textCellNib = UINib(nibName: "TextCell", bundle: nil)
	    tableView.registerNib(textCellNib, forCellReuseIdentifier: "TextCellIdentifier")
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    	let textCell = tableView.dequeueReusableCellWithIdentifier("TextCellIdentifier", forIndexPath: indexPath) as? TextCell
    	textCell?.mainLabel.text = "Hello World"
    	return textCell
  	}
}
```

*With R.swift*
```swift
class FaqAnswerController: UITableViewController {
	override func viewDidLoad() {
	    super.viewDidLoad()
	    tableView.registerNib(R.nib.textCell)
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    	let textCell = tableView.dequeueReusableCellWithIdentifier(R.nib.textCell.reuseIdentifier, forIndexPath: indexPath)
    	textCell?.mainLabel.text = "Hello World"
    	return textCell
  	}
}
```

## Custom fonts

*Vanilla*
```swift
let lightFontTitle = UIFont(name: "Acme-Light", size: 22)
```

*With R.swift*
```swift
let lightFontTitle = R.font.acmeLight(size: 22)
```
