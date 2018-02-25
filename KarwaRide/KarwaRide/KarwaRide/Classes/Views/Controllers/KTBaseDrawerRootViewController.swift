//
//  KSBaseDrawerRootViewController.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 11/23/17.
//  Copyright © 2017 Karwa. All rights reserved.
//

import UIKit

class KTBaseDrawerRootViewController: KTBaseViewController {

    @IBOutlet weak var revealBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        /*revealBarButton.target = self.revealViewController()
        revealBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())*/
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
