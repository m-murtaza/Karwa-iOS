//
//  KTFirstViewController.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 5/13/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

class KTFirstViewController: KTBaseViewController, KTFirstViewModelDelegate {

    private var vModel : KTFirstViewModel?
    override func viewDidLoad() {
        self.viewModel = KTFirstViewModel(del: self)
        vModel = viewModel as? KTFirstViewModel
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

    func userLogin(isLogin: Bool) {
        
        if !isLogin {
           self.performSegue(name: "segueFirstToLogin")
        }
        else {
           self.performSegue(name: "segueOnboardingToBooking")
        }
    }
}

