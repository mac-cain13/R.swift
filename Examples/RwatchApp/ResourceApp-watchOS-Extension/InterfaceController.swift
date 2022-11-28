//
//  InterfaceController.swift
//  ResourceApp-watchOS Extension
//
//  Created by Lammert Westerhoff on 28/08/2018.
//  Copyright © 2018 Mathijs Kadijk. All rights reserved.
//

import WatchKit
import Foundation

import RswiftResources



class InterfaceController: WKInterfaceController {

    @IBOutlet weak var label: WKInterfaceLabel!

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        label.setText(R.string.localizable.quote(11))
        label.setTextColor(UIColor(named: R.color.myColor.name))
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
