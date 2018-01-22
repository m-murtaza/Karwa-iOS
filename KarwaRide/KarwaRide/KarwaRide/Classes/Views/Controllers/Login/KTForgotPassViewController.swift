//
//  KTForgotPassViewController.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 1/11/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

class KTForgotPassViewController: KTBaseViewController,KTForgotPassViewModelDelegate {
    
    @IBOutlet weak var txtPhoneNumber : UITextField!
    @IBOutlet weak var txtPassword : UITextField!
    @IBOutlet weak var txtConfirmPass : UITextField!
    
    let viewModel : KTForgotPassViewModel = KTForgotPassViewModel(del: self)
    //MARK: -View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //viewModel! = KTLoginViewModel(del:self)
        // Do any additional setup after loading the view.
        viewModel.delegate = self
    }
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "SegueForgotPassToOTP"
        {
            
            let otpView : KTOTPViewController = segue.destination as! KTOTPViewController
            otpView.phone = phoneNumber()!
        }
    }
    
    @IBAction func btnSubmitTapped(_ sender: Any)
    {
        viewModel.btnSubmitTapped()
    }
    
    func phoneNumber() -> String? {
        return txtPhoneNumber.text
    }
    
    func password() -> String? {
        return txtPassword.text
    }
    
    func rePassword() -> String? {
        return txtConfirmPass.text
    }
    
    func navigateToOTP() {
        self.performSegue(withIdentifier: "SegueForgotPassToOTP", sender: self)
    }
}