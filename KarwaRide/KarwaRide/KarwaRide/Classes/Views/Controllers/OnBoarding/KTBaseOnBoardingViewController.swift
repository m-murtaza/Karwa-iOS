//
//  KTBaseOnBoardingViewController.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 5/8/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
import Spring

class KTBaseOnBoardingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("ViewDidAppear Called. It should Animate. ")
        animateView()
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
    
    func animateView() {
        
        for view in self.view.subviews {
            if view.tag == 101 {
                for v in view.subviews {
                    
                    (v as! KTSpringImageView).ktAnimate()
                    
                }
            }
        }
    }
}
