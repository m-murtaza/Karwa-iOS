//
//  KTBaseLoginSignUpViewController.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 3/1/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

class KTBaseLoginSignUpViewController: KTBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    func navigateToBooking()
    {
        self.dismiss(animated: true) {
                self.performSegue(withIdentifier: "segueToBooking", sender: self)
        }
        
        
    }
}