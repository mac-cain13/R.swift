//
//  StoryboardReference+Integrations.swift
//
//
//  Created by Tom Lokhorst on 2022-07-30.
//

import Foundation


#if os(iOS) || os(tvOS)
import UIKit


public extension StoryboardReference where Self: InitialControllerContainer {
    /**
     Instantiates and returns the initial view controller in the view controller graph.

     - returns: The initial view controller in the storyboard.
     */
    func instantiateInitialViewController() -> InitialController? {
        UIStoryboard(name: name, bundle: bundle).instantiateInitialViewController() as? InitialController
    }
}


public extension StoryboardViewControllerIdentifier {
    /**
     Instantiates and returns the view controller with the specified resource (`R.storyboard.*.*`).

     - returns: The view controller corresponding to the specified resource (`R.storyboard.*.*`). If no view controller is associated, this method throws an exception.
     */
    func callAsFunction() -> ViewController? {
        UIStoryboard(name: storyboard, bundle: bundle).instantiateViewController(withIdentifier: identifier) as? ViewController
    }
}


public extension UIStoryboard {
    /**
     Creates and returns a storyboard object for the specified storyboard resource (`R.storyboard.*`) file.

     - parameter resource: The storyboard resource (`R.storyboard.*`) for the specific storyboard to load

     - returns: A storyboard object for the specified file. If no storyboard resource file matching name exists, an exception is thrown with description: `Could not find a storyboard named 'XXXXXX' in bundle....`
     */
    convenience init<Reference: StoryboardReference>(resource: Reference) {
        self.init(name: resource.name, bundle: resource.bundle)
    }


    /**
     Instantiates and returns the view controller with the specified resource (`R.storyboard.*.*`).

     - parameter resource: An resource (`R.storyboard.*.*`) that uniquely identifies the view controller in the storyboard file. If the specified resource does not exist in the storyboard file, this method raises an exception.

     - returns: The view controller corresponding to the specified resource (`R.storyboard.*.*`). If no view controller is associated, this method throws an exception.
     */
    func instantiateViewController<ViewController: UIViewController>(withIdentifier identifier: StoryboardViewControllerIdentifier<ViewController>) -> ViewController?  {
        self.instantiateViewController(withIdentifier: identifier.identifier) as? ViewController
    }
}
#endif
