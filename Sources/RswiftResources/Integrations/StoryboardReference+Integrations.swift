//
//  StoryboardReference+Integrations.swift
//  R.swift
//
//  Created by Tom Lokhorst on 2022-07-30.
//

#if os(iOS) || os(tvOS)
import UIKit


extension StoryboardReference where Self: InitialControllerContainer {
    /**
     Instantiates and returns the initial view controller in the view controller graph.

     - returns: The initial view controller in the storyboard.
     */
    public func instantiateInitialViewController() -> InitialController? {
        UIStoryboard(name: name, bundle: bundle).instantiateInitialViewController() as? InitialController
    }


    /**
     Instantiates and returns the initial view controller in the view controller graph with native dependency injection.

     - parameter creator: The function to inject dependency.

     - returns: The initial view controller in the storyboard.
     */
    @available(iOS 13.0, tvOS 13.0, *)
    public func instantiateInitialViewController(creator: @escaping (NSCoder) -> InitialController?) -> InitialController? where InitialController: UIViewController {
        UIStoryboard(name: name, bundle: bundle).instantiateInitialViewController(creator: creator)
    }
}

extension StoryboardViewControllerIdentifier {
    /**
     Instantiates and returns the view controller with the specified resource (`R.storyboard.*.*`).

     - returns: The view controller corresponding to the specified resource (`R.storyboard.*.*`). If no view controller is associated, this method throws an exception.
     */
    public func callAsFunction() -> ViewController? {
        UIStoryboard(name: storyboard, bundle: bundle).instantiateViewController(withIdentifier: identifier) as? ViewController
    }


    /**
     Instantiates and returns the view controller with the specified resource (`R.storyboard.*.*`) and native dependency injection.

     - parameter creator: The function to inject dependency.

     - returns: The view controller corresponding to the specified resource (`R.storyboard.*.*`).
     */
    @available(iOS 13.0, tvOS 13.0, *)
    public func callAsFunction(creator: @escaping (NSCoder) -> ViewController?) -> ViewController? where ViewController: UIViewController {
        UIStoryboard(name: storyboard, bundle: bundle).instantiateViewController(identifier: identifier, creator: creator)
    }
}

extension UIStoryboard {
    /**
     Creates and returns a storyboard object for the specified storyboard resource (`R.storyboard.*`) file.

     - parameter resource: The storyboard resource (`R.storyboard.*`) for the specific storyboard to load

     - returns: A storyboard object for the specified file. If no storyboard resource file matching name exists, an exception is thrown with description: `Could not find a storyboard named 'XXXXXX' in bundle....`
     */
    public convenience init<Reference: StoryboardReference>(resource: Reference) {
        self.init(name: resource.name, bundle: resource.bundle)
    }


    /**
     Instantiates and returns the view controller with the specified resource (`R.storyboard.*.*`).

     - parameter resource: An resource (`R.storyboard.*.*`) that uniquely identifies the view controller in the storyboard file. If the specified resource does not exist in the storyboard file, this method raises an exception.

     - returns: The view controller corresponding to the specified resource (`R.storyboard.*.*`). If no view controller is associated, this method throws an exception.
     */
    public func instantiateViewController<ViewController: UIViewController>(withIdentifier identifier: StoryboardViewControllerIdentifier<ViewController>) -> ViewController?  {
        self.instantiateViewController(withIdentifier: identifier.identifier) as? ViewController
    }
}
#endif


#if canImport(AppKit)
import AppKit


extension StoryboardReference where Self: InitialControllerContainer {
    /**
     Instantiates and returns the initial view controller in the view controller graph.

     - returns: The initial view controller in the storyboard.
     */
    public func instantiateInitialViewController() -> InitialController? {
        NSStoryboard(name: name, bundle: bundle).instantiateInitialController() as? InitialController
    }


    /**
     Instantiates and returns the initial view controller in the view controller graph with native dependency injection.

     - parameter creator: The function to inject dependency.

     - returns: The initial view controller in the storyboard.
     */
    public func instantiateInitialViewController(creator: @escaping (NSCoder) -> InitialController?) -> InitialController? where InitialController: NSViewController {
        NSStoryboard(name: name, bundle: bundle).instantiateInitialController(creator: creator)
    }
}

extension StoryboardViewControllerIdentifier {
    /**
     Instantiates and returns the view controller with the specified resource (`R.storyboard.*.*`).

     - returns: The view controller corresponding to the specified resource (`R.storyboard.*.*`). If no view controller is associated, this method throws an exception.
     */
    public func callAsFunction() -> ViewController? {
        NSStoryboard(name: storyboard, bundle: bundle).instantiateController(withIdentifier: identifier) as? ViewController
    }


    /**
     Instantiates and returns the view controller with the specified resource (`R.storyboard.*.*`) and native dependency injection.

     - parameter creator: The function to inject dependency.

     - returns: The view controller corresponding to the specified resource (`R.storyboard.*.*`).
     */
    public func callAsFunction(creator: @escaping (NSCoder) -> ViewController?) -> ViewController? where ViewController: NSViewController {
        NSStoryboard(name: storyboard, bundle: bundle).instantiateController(identifier: identifier, creator: creator)
    }
}

extension NSStoryboard {
    /**
     Creates and returns a storyboard object for the specified storyboard resource (`R.storyboard.*`) file.

     - parameter resource: The storyboard resource (`R.storyboard.*`) for the specific storyboard to load

     - returns: A storyboard object for the specified file. If no storyboard resource file matching name exists, an exception is thrown with description: `Could not find a storyboard named 'XXXXXX' in bundle....`
     */
    public convenience init<Reference: StoryboardReference>(resource: Reference) {
        self.init(name: resource.name, bundle: resource.bundle)
    }


    /**
     Instantiates and returns the view controller with the specified resource (`R.storyboard.*.*`).

     - parameter resource: An resource (`R.storyboard.*.*`) that uniquely identifies the view controller in the storyboard file. If the specified resource does not exist in the storyboard file, this method raises an exception.

     - returns: The view controller corresponding to the specified resource (`R.storyboard.*.*`). If no view controller is associated, this method throws an exception.
     */
    public func instantiateController<ViewController: NSViewController>(withIdentifier identifier: StoryboardViewControllerIdentifier<ViewController>) -> ViewController? {
        self.instantiateController(withIdentifier: identifier.identifier) as? ViewController
    }
}
#endif
