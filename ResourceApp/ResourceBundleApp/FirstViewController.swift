//
//  FirstViewController.swift
//  ResourceApp
//
//  Created by Mathijs Kadijk on 20-07-15.
//  Copyright (c) 2015 Mathijs Kadijk. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

  @IBOutlet weak var titleLabel: UILabel!

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    if #available(iOS 11.0, *) {
      titleLabel.textColor = R.color.myColor()
    } else {
      // Fallback on earlier versions
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

