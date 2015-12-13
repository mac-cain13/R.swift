# Examples

On this page you'll find examples of the kind of resources R.swift supports and how you can use them. We aim to keep this page up to date and complete so this should be a overview of all possibilities.

## Images

R.swift will find both images from Asset Catalogs and image files in your bundle.

*Vanilla*
```swift
let settingsIcon = UIImage(named: "settings-icon")
let gradientBackground = UIImage(named: "gradient.jpg")
```

*With R.swift*
```swift
let settingsIcon = R.image.settingsIcon
let gradientBackground = R.image.gradientJpg
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
// Trigger segue with:
performSegueWithIdentifier("openSettings", sender: self)

// And then prepare it:
override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  if let settingsController = segue.destinationViewController as? SettingsController,
    segue = segue as? CustomSettingsSegue
    where segue.identifier == "openSettings" {
      segue.animationType = .LockAnimation
      settingsController.lockSettings = true
  }
}
```

*With R.swift*
```swift
// Trigger segue with:
performSegueWithIdentifier(R.segue.overviewController.openSettings, sender: self)

// And then prepare it:
override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  if let typedInfo = segue.typedInfoWithIdentifier(R.segue.overviewController.openSettings) {
    typedInfo.segue.animationType = .LockAnimation
    typedInfo.destinationViewController.lockSettings = true
  }
}
```

**Tip:** Take a look at the [SegueManager](https://github.com/tomlokhorst/SegueManager) library, it makes segues block based and is compatible with R.swift.

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

**Note:** This is a table view example, R.swift also supports collection views in the same way.

*Vanilla*
```swift
class FaqAnswerController: UITableViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    let textCellNib = UINib(nibName: "TextCell", bundle: nil)
    tableView.registerNib(textCellNib, forCellReuseIdentifier: "TextCellIdentifier")
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let textCell = tableView.dequeueReusableCellWithIdentifier("TextCellIdentifier", forIndexPath: indexPath) as! TextCell
    textCell.mainLabel.text = "Hello World"
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
    let textCell = tableView.dequeueReusableCellWithIdentifier(R.nib.textCell.reuseIdentifier, forIndexPath: indexPath)!
    textCell.mainLabel.text = "Hello World"
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

## Resource files

*Vanilla*
```swift
let jsonURL = NSBundle.mainBundle().URLForResource("seed-data", withExtension: "json")
```

*With R.swift*
```swift
let jsonURL = R.file.seedDataJson
```
