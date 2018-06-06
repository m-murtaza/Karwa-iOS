//
//  KTOnboardingStep2ViewController.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 5/8/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

class KTOnboardingStep2ViewController: KTBaseOnBoardingViewController {

    @IBOutlet weak var fingerPointer : KTSpringImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func animateFinger() {
        fingerPointer.animateNext {
            self.animateFingerLeft()
        }
    }

    func animateFingerLeft() {
        UIView.animate(withDuration: 0.4,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseIn,
                       animations: { () -> Void in
                        self.fingerPointer.frame.origin.x -= 70
                        self.fingerPointer.layoutIfNeeded()
        }, completion: { (finished) -> Void in
            self.animateFingerRight()
        })
    }
    
    func animateFingerRight() {
        UIView.animate(withDuration: 0.4,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseIn,
                       animations: { () -> Void in
                        self.fingerPointer.frame.origin.x += 100
                        self.fingerPointer.layoutIfNeeded()
        }, completion: { (finished) -> Void in
            self.animateFingerBackToPosition()
        })
    }
    
    func animateFingerBackToPosition() {
        UIView.animate(withDuration: 0.4,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseIn,
                       animations: { () -> Void in
                        self.fingerPointer.frame.origin.x -= 30
                        self.fingerPointer.layoutIfNeeded()
        }, completion: { (finished) -> Void in
            
        })
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
