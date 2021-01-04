import UIKit
import Foo
import Bar

final class ViewController: UIViewController {

    @IBOutlet weak var fooImageView: UIImageView!
    @IBOutlet weak var barImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fooImageView.image = FooClass().sampleImage()
        barImageView.image = BarClass().sampleImage()
    }
}
