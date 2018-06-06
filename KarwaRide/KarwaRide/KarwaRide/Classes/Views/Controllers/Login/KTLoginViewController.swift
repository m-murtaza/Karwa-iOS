//
//  LoginViewController.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 7/3/17.
//  Copyright © 2017 Karwa. All rights reserved.
//

import UIKit

let ALLOWED_NUM_PHONE_CHAR : Int = 8

class KTLoginViewController: KTBaseLoginSignUpViewController, KTLoginViewModelDelegate,UITextFieldDelegate {
    
    //MARK: - Properties
    @IBOutlet weak var txtPhoneNumber: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    //MARK: -View LifeCycle
    override func viewDidLoad() {
        viewModel = KTLoginViewModel(del:self)
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        txtPhoneNumber.becomeFirstResponder()
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "segueLoginToForgotPass" {
            let forgotPassNav : UINavigationController  = segue.destination as! UINavigationController
            let forgotPassViewController = forgotPassNav.topViewController as! KTForgotPassViewController
            forgotPassViewController.previousView = self
        }
        else if  segue.identifier == "segueLoginToOTP"
        {
            
            let otpViewNav : UINavigationController  = segue.destination as! UINavigationController
            let otpView = otpViewNav.topViewController as! KTOTPViewController
            otpView.previousView = self
            
            otpView.phone = txtPhoneNumber.text!
        }

        
    }
    
    //MARK: UI Events
    
    @IBAction func loginBtnTapped(_ sender: Any)
    {
        (viewModel as! KTLoginViewModel).loginBtnTapped()
    }
    
    @IBAction func btnBackTapped(_ sender:Any)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    //Mark: - View Model Delegate
    func phoneNumber() -> String {
        guard let _ =  txtPassword.text else {
            return ""
        }
        
        return txtPhoneNumber.text!
    }
    
    func password() -> String {
        guard let _ = txtPassword.text else {
            
            return ""
        }
        return txtPassword.text!
    }
    
    func navigateToBooking()
    {
        self.performSegue(withIdentifier: "segueToBooking", sender: self)
    }
    func navigateToOTP() {
        self.performSegue(withIdentifier: "segueLoginToOTP", sender: self)
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
