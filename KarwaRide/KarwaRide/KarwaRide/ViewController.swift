//
//  ViewController.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 6/18/17.
//  Copyright © 2017 Karwa. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        KSWebClient.sharedInstance.testServerCall()
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

