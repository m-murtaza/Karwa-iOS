//
//  KTOTPViewController.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 1/9/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

class KTOTPViewController: KTBaseViewController,KTOTPViewModelDelegate {
    
    @IBOutlet weak var btnConfirmCode: ButtonWithShadow!
    @IBOutlet weak var otpView: VPMOTPView!
    var otpString : String?
    var countryCode: String?
    var phone : String = ""
    var password : String = ""
    var email : String = ""

    var previousView : KTBaseLoginSignUpViewController?
    
    override func viewDidLoad() {
        viewModel = KTOTPViewModel(del:self)
        super.viewDidLoad()

        // Do any additional setup after loading the view.
       
        // Create the UI
        otpView.initalizeUI()
        otpView.delegate = self
        
        btnConfirmCode.isHidden = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(confrimCodeTapped))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func btnConfirmCode(_ sender: Any) {
        confrimCodeTapped()
    }
    
    @objc func confrimCodeTapped()
    {
        (viewModel as! KTOTPViewModel).confirmCode()
    }
    
    func getCountryCode() -> String{
        return countryCode ?? "+974"
    }
    
    @IBAction func btnCloseTapped(_ sender: Any) {
        
        if previousView != nil {
            
            previousView?.dismiss()
        }
        
    }
    
    @IBAction func btnReSendOTP(_ sender: Any) {
        
        (viewModel as! KTOTPViewModel).resendOTP()
    }
    
    func OTPCode() -> String? {
        return otpString
    }
    func countryCallingCode() -> String?  {
        return countryCode
    }
    func phoneNum() -> String?  {
        return phone
    }
    
    func navigateToBooking() {
        //self.performSegue(withIdentifier: "segueOtpToBooking", sender: self)
       // previousView?.dismiss()
        previousView?.dismissAndNavigateToBooking()
    }
}


extension KTOTPViewController: VPMOTPViewDelegate {
    func shouldBecomeFirstResponderForOTP(otpFieldIndex index: Int) -> Bool {
        return true
    }
    
    func hasEnteredAllOTP(hasEntered: Bool) {
        print("Has entered all OTP? \(hasEntered)")
        btnConfirmCode.isEnabled = hasEntered
        //btnConfirmCode.updateLayerProperties()
        btnConfirmCode.layoutIfNeeded()
    }
    
    func enteredOTP(otpString otp: String) {
        print("OTPString: \(String(describing: otpString))")
    
        otpString = otp
        
        if(otp.count == 4)
        {
            confrimCodeTapped()
        }
    }
}
