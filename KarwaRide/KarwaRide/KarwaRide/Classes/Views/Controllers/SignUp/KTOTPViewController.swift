//
//  KTOTPViewController.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 1/9/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

/*
 "raw": "{\r\n \"Phone\": \"59581713\",\r\n \"CountryCode\": \"+974\",\r\n \"otp\": \"9072\",\r\n \"otpType\": \"RESET_PASSWORD_CHALLENGE\",\r\n \"deviceToken\": \"...\"\r\n}",
 */

import UIKit

class KTOTPViewController: KTBaseViewController, KTOTPViewModelDelegate {
    
    @IBOutlet weak var btnConfirmCode: ButtonWithShadow!
    @IBOutlet weak var otpView: VPMOTPView!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    var otpString : String?
    var countryCode: String?
    var phone : String = ""
    var password : String = ""
    var email : String = ""
    var otpType : String = ""
    var maskedString: String = ""
    var challengeType = ""
    
    var previousView : KTBaseLoginSignUpViewController?
    
    override func viewDidLoad() {
        viewModel = KTOTPViewModel(del:self)
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // Create the UI
        otpView.initalizeUI()
        otpView.delegate = self
        
        //btnConfirmCode.isHidden = true
        /*navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done",
         style: .plain,
         target: self, action: #selector(confrimCodeTapped))*/
        self.phoneNumberLabel.text = phone
        
    }
    
    @IBAction func goBack(_ sender: UIButton) {
        
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
        
        if otpType == "CHANGE_NUMBER_CHALLENGE" {
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    @IBAction func btnReSendOTP(_ sender: Any) {
        
        (viewModel as! KTOTPViewModel).resendOTP()
    }
    
    func OTPCode() -> String? {
        return otpString?.convertToNumbersIfNeeded()
    }
    
    func countryCallingCode() -> String?  {
        return countryCode?.convertToNumbersIfNeeded()
    }
    
    func phoneNum() -> String?  {
        return phone.convertToNumbersIfNeeded()
    }
    
    func getOtpType() -> String? {
        return otpType
    }
    
    func navigateToBooking() {
        //self.performSegue(withIdentifier: "segueOtpToBooking", sender: self)
        // previousView?.dismiss()
        if otpType == "CHANGE_NUMBER_CHALLENGE" {
            self.navigationController?.isNavigationBarHidden = false
            self.navigationController?.popToRootViewController(animated: true)
        } else{
            previousView?.dismissAndNavigateToBooking()
        }
    }
    
    func navigateToChallengeVerificationScreen(maskedString: String, challengeType: String) {
        self.maskedString = maskedString
        self.challengeType = challengeType
        self.performSegue(withIdentifier: "SegueOTPToMaskedEmail", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueOTPToMaskedEmail" {
            let maskedEmailVC : KTMaskedEmailConfirmationVC = segue.destination as! KTMaskedEmailConfirmationVC
            maskedEmailVC.previousView = previousView
            maskedEmailVC.countryCode = countryCallingCode()!
            maskedEmailVC.phone = phoneNum()!
            maskedEmailVC.maskedEmail = maskedString
            maskedEmailVC.challengeType = challengeType
        }
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
