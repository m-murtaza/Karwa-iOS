//
//  KTOnboardingStep5ViewController.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 5/8/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

class KTOnboardingStep5ViewController: KTBaseOnBoardingViewController {

    @IBOutlet weak var card : KTSpringImageView!
    @IBOutlet weak var finger : KTSpringImageView!
    @IBOutlet weak var leftPad : KTSpringImageView!
    @IBOutlet weak var rightPad : KTSpringImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animateCardandFinger()
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
    
    func animateCardandFinger() {
        card.ktAnimate()
        finger.ktAnimateNext {
            self.animateFingerLeft()
        }
    }
    
    
    func animateFingerLeft() {
        
        UIView.animate(withDuration: 0.6,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseIn,
                       animations: { () -> Void in
                        self.card.frame.origin.x -= 40
                        self.finger.frame.origin.x -= 40
                        self.leftPad.frame.origin.x -= 40
                        
        }, completion: { (finished) -> Void in
            self.animateFingerRightPart1()
        })
    }
    
    func animateFingerRightPart1() {
        UIView.animate(withDuration: 1.2,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseIn,
                       animations: { () -> Void in
                        self.card.frame.origin.x += 80
                        self.finger.frame.origin.x += 80
                        self.leftPad.frame.origin.x += 40
                        self.rightPad.frame.origin.x += 40
        }, completion: { (finished) -> Void in
            self.animateFingerBackToPosition()
            
        })
    }

    func animateFingerBackToPosition() {
        UIView.animate(withDuration: 0.6,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseIn,
                       animations: { () -> Void in
                        self.card.frame.origin.x -= 40
                        self.finger.frame.origin.x -= 40
                        //self.leftPad.frame.origin.x -= 40
                        self.rightPad.frame.origin.x -= 40
        }, completion: { (finished) -> Void in
     
        })
    }

}
