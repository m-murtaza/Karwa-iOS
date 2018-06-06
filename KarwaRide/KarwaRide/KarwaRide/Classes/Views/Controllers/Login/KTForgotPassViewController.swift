//
//  KTForgotPassViewController.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 1/11/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

class KTForgotPassViewController: KTBaseViewController, KTForgotPassViewModelDelegate, UITextFieldDelegate  {
    
    @IBOutlet weak var txtPhoneNumber : UITextField!
    @IBOutlet weak var txtPassword : UITextField!
    @IBOutlet weak var txtConfirmPass : UITextField!
    
    var previousView : KTBaseLoginSignUpViewController?
    
    //MARK: -View LifeCycle
    override func viewDidLoad() {
        viewModel = KTForgotPassViewModel(del:self)
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
    }
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "SegueForgotPassToOTP"
        {
            
            let otpView : KTOTPViewController = segue.destination as! KTOTPViewController
            otpView.previousView = previousView
            otpView.phone = phoneNumber()!
        }
    }
    
    @IBAction func btnSubmitTapped(_ sender: Any)
    {
        (viewModel as! KTForgotPassViewModel).btnSubmitTapped()
        //navigateToOTP()
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
    
    @IBAction func btnCloseTapped(_ sender: Any) {
    
        if previousView != nil {
            
            previousView?.dismiss()
        }
    }
    
    //MARK:- TextField Delegate
    //Bug 2567 Fixed.
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == txtPhoneNumber {
            
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            
            let changedText = currentText.replacingCharacters(in: stringRange, with: string)
            
            return changedText.count <= ALLOWED_NUM_PHONE_CHAR
        }
        return true
    }
}
