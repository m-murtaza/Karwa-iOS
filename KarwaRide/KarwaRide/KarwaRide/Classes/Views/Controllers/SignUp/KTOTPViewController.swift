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
    var phone : String = ""
    
    var previousView : KTBaseLoginSignUpViewController?
    
    override func viewDidLoad() {
        viewModel = KTOTPViewModel(del:self)
        super.viewDidLoad()

        // Do any additional setup after loading the view.
       
        // Create the UI
        otpView.initalizeUI()
        otpView.delegate = self
    }

//    override func viewWillAppear(_ animated: Bool) {
//        self.view .layoutIfNeeded()
//        
//    }
    
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

    @IBAction func btnConfirmCode(_ sender: Any) {
       (viewModel as! KTOTPViewModel).confirmCode()
        
        //navigateToBooking()
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
        
    }
}
