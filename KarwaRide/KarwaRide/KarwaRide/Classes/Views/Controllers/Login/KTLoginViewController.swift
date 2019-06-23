//
//  LoginViewController.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 7/3/17.
//  Copyright © 2017 Karwa. All rights reserved.
//

import UIKit
import Spring

let ALLOWED_NUM_PHONE_CHAR : Int = 15

class KTLoginViewController: KTBaseLoginSignUpViewController, KTLoginViewModelDelegate, UITextFieldDelegate, CountryListDelegate {
    
    //MARK: - Properties
    @IBOutlet weak var txtPhoneNumber: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var loginButton: SpringButton!
    @IBOutlet weak var lblCountryCode: UILabel!
    
    var countryList = CountryList()

    //MARK: -View LifeCycle
    override func viewDidLoad() {
        viewModel = KTLoginViewModel(del:self)
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        txtPhoneNumber.becomeFirstResponder()
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(KTLoginViewController.dismissKeyboardOld))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
        
        txtPassword.delegate = self
        txtPhoneNumber.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)

        countryList.delegate = self
        let countryTap = UITapGestureRecognizer(target: self, action: #selector(countrySelectorTapped))
        lblCountryCode.addGestureRecognizer(countryTap)
        setCountry(country: Country(countryCode: "QA", phoneExtension: "974"))
    }
  
    @objc
    func countrySelectorTapped(sender:UITapGestureRecognizer) {
        let navController = UINavigationController(rootViewController: countryList)
        self.present(navController, animated: true, completion: nil)
    }
    
    func selectedCountry(country: Country) {
        (viewModel as! KTLoginViewModel).setSelectedCountry(country: country)
        setCountry(country: country)
    }

    func setCountry(country: Country) {
        lblCountryCode.text = country.flag! + " " + country.countryCode + " +" + country.phoneExtension
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
    @objc func dismissKeyboardOld() {
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

            otpView.countryCode = (viewModel as! KTLoginViewModel).country.phoneExtension
            otpView.phone = txtPhoneNumber.text!
        }

        
    }
    
    //MARK: UI Events
    
    @IBAction func loginbtnTouchDown(_ sender: SpringButton)
    {
//        print("touch down")
        springAnimateButtonTapIn(button: loginButton)
    }
    
    @IBAction func loginbtnTouchUpOutside(_ sender: SpringButton)
    {
//        print("touch up outside")
        springAnimateButtonTapOut(button: loginButton)
    }
    
    @IBAction func loginBtnTapped(_ sender: Any)
    {
//        print("touch up inside")
        springAnimateButtonTapOut(button: loginButton)
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
        
//        if textField == txtPhoneNumber {
//
//            let currentText = textField.text ?? ""
//
//            guard let stringRange = Range(range, in: currentText) else { return false }
//
//            let changedText = currentText.replacingCharacters(in: stringRange, with: string)
//
//            return changedText.count <= ALLOWED_NUM_PHONE_CHAR
//        }
        return true
    }
   
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if textField == txtPassword
        {
            textField.resignFirstResponder()
            (viewModel as! KTLoginViewModel).loginBtnTapped()
        }
        return true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField)
    {
        txtPhoneNumber.text = textField.text?.replacingOccurrences(of: "+974", with: "")
        txtPhoneNumber.text = textField.text?.replacingOccurrences(of: " ", with: "")
        
        if(txtPhoneNumber.text?.count == ALLOWED_NUM_PHONE_CHAR)
        {
            txtPhoneNumber.resignFirstResponder()
            txtPassword.becomeFirstResponder()
        }
    }
}
