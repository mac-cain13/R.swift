import UIKit

let bundle = Bundle.main.path(forResource: "Bar", ofType: "bundle").flatMap(Bundle.init(path:))!

public final class BarClass {
    public init() {}
    public func bar() {
        print("bar")
    }
    
    public func sampleImage() -> UIImage {
        R.image(bundle: bundle).colorsJpg()!
    }
}
