//
//  InterfaceController.swift
//  ResourceAppWatchApp Extension
//
//  Created by Tomas Harkema on 14-05-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController {

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        let image = R.image.watchIcon()
        let string = R.string.things.thingy()
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
