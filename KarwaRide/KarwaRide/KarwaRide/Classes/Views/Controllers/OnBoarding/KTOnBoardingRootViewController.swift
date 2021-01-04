//
//  KTOnBoardingRootViewController.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 5/9/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

class KTOnBoardingRootViewController: KTBaseViewController,KTOnBoardingViewControllerDelegate {

    //@IBOutlet weak var pageView : KTOnBoardingViewController!
    @IBOutlet weak var imgSteps : UIImageView!
    @IBOutlet weak var btnSkipFinish : UIButton!
    var pageViewController : KTOnBoardingViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        //segueRootToOnBoarding
        if segue.identifier == "segueRootToOnBoarding" {
            
            pageViewController = segue.destination as? KTOnBoardingViewController
            pageViewController?.onBoardingDelegate = self
        }
    }
    
    //MARK:- KTOnBoardingViewControllerDelegate
    func update(index: Int) {
        updateStepImage(forIndex: index)
        updateButton(forIndex:index)
    }
    
    func updateStepImage(forIndex idx:Int)  {
        switch idx {
        case 1:
            imgSteps.image = UIImage(named: "step1")
        case 2:
            imgSteps.image = UIImage(named: "step2")
        case 3:
            imgSteps.image = UIImage(named: "step3")
        case 4:
            imgSteps.image = UIImage(named: "step4")
        default:
            imgSteps.image = UIImage(named: "step5")
        }
    }
    
    func updateButton(forIndex idx: Int) {
        if idx == pageViewController?.stepsViewControllers.count {
            btnSkipFinish.setTitle(Locale.current.languageCode == "ar" ? "تخطى" : "FINISH", for: .normal)
        }
        else {
            btnSkipFinish.setTitle(Locale.current.languageCode == "ar" ? "تخطى" : "SKIP", for: .normal)
        }
        btnSkipFinish.layoutIfNeeded()
    }

}
