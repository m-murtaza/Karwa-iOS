//
//  ViewController.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 6/18/17.
//  Copyright © 2017 Karwa. All rights reserved.
//

import UIKit


class ViewController: KTBaseDrawerRootViewController {

    
    //@IBOutlet weak var Open: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //KSWebClient.sharedInstance.testServerCall()
        ///Open.target = self.revealViewController()
        //Open.action = #selector(SWRevealViewController.revealToggle(_:))
        self.navigationItem.hidesBackButton = true;
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func btnTapped(_ sender: Any) {
        
        self.revealViewController().performSegue(withIdentifier: "sw_front", sender: self)
    }
    
    
}

