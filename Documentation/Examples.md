# Examples

On this page you'll find examples of the kind of resources R.swift supports and how you can use them. We aim to keep this page up to date and complete so this should be a overview of all possibilities.

## Runtime validation

Call `R.assertValid()` to call all validation methods that R.swift generates, this will check:
- If all images used in storyboards are available
- If all view controllers with storyboard identifiers can be loaded

The `assertValid()` method does nothing when in release mode, only in debug mode it will perform checks and assert if a check fails. If you want more control you can also use `try R.validate()` which will throw a detailed error about the problems that occur and will always perform checks, even in release builds.

_Note:_ The validation methods are there to perform checks that can't be done at compile time, it's recommended to put `R.assertValid()` in your `AppDelegate`.

## Images

R.swift will find both images from Asset Catalogs and image files in your bundle.

*Vanilla*
```swift
let settingsIcon = UIImage(named: "settings-icon")
let gradientBackground = UIImage(named: "gradient.jpg")
```

*With R.swift*
```swift
let settingsIcon = R.image.settingsIcon()
let gradientBackground = R.image.gradientJpg()
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
let jsonPath = NSBundle.mainBundle().pathForResource("seed-data", withExtension: "json")
```

*With R.swift*
```swift
let jsonURL = R.file.seedDataJson()
let jsonPath = R.file.seedDataJson.path()
```

## Colors

*Vanilla*
```swift
label.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.5)
label.textColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
```

*With R.swift*
```swift
label.backgroundColor = R.color.appColors.backgroundColor()
label.textColor = R.color.appColors.textColor()
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
let storyboard = R.storyboard.main()
let initialTabBarController = R.storyboard.main.initialViewController()
let settingsController = R.storyboard.main.settingsController()
```

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
  if let typedInfo = R.segue.overviewController.openSettings(segue: segue) {
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
let customViewNib = R.nib.customView()
let rootViews = R.nib.customView.instantiateWithOwner(nil)
let customView = R.nib.customView.firstView(owner: nil)

let viewControllerWithNib = CustomViewController(nib: R.nib.customView)
```

## Reusable table view cells

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
    let textCell = tableView.dequeueReusableCellWithIdentifier(R.nib.textCell.identifier, forIndexPath: indexPath)!
    textCell.mainLabel.text = "Hello World"
    return textCell
  }
}
```

## Reusable collection view cells

*Vanilla*
```swift
class RecentsController: UICollectionViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    let talkCellNib = UINib(nibName: "TalkCell", bundle: nil)
    collectionView?.registerNib(talkCellNib, forCellWithReuseIdentifier: "TalkCellIdentifier")
  }

  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("TalkCellIdentifier", forIndexPath: indexPath) as! TalkCell
    cell.configureCell("Item \(indexPath.item)")
    return cell
  }
}
```

*With R.swift*
```swift
class RecentsController: UICollectionViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    collectionView?.registerNib(R.nib.talkCell)
  }

  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(R.reuseIdentifier.talkCell, forIndexPath: indexPath)!
    cell.configureCell("Item \(indexPath.item)")
    return cell
  }
}
```
