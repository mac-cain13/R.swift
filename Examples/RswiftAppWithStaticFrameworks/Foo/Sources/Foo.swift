import UIKit

let bundle = Bundle.main.path(forResource: "Foo", ofType: "bundle").flatMap(Bundle.init(path:))!

public final class FooClass {
    public init() {}
    public func foo() {
        print("foo")
    }
    
    public func sampleImage() -> UIImage {
        R.image(bundle: bundle).user()!
    }
}
