//
//  KTOTPViewController.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 1/9/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

class KTOTPViewController: KTBaseViewController,KTOTPViewModelDelegate {
    var viewModel : KTOTPViewModel!
    
    @IBOutlet weak var otpView: VPMOTPView!
    var otpString : String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        viewModel = KTOTPViewModel.init(del: self)
        
        otpView.otpFieldsCount = 4
        otpView.otpFieldDisplayType = .square
        otpView.otpFieldDefaultBorderColor = UIColor.lightGray
        otpView.otpFieldEnteredBorderColor = UIColor.darkGray
        otpView.otpFieldDefaultBackgroundColor = UIColor.white
        otpView.otpFieldEnteredBackgroundColor = UIColor.gray
        otpView.otpFieldBorderWidth = 1
        otpView.delegate = self
        // Create the UI
        otpView.initalizeUI()
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
        viewModel.confirmCode()
    }
    
    func OTPCode() -> String? {
        return otpString
    }
}


extension KTOTPViewController: VPMOTPViewDelegate {
    func shouldBecomeFirstResponderForOTP(otpFieldIndex index: Int) -> Bool {
        return true
    }
    
    func hasEnteredAllOTP(hasEntered: Bool) {
        print("Has entered all OTP? \(hasEntered)")
    }
    
    func enteredOTP(otp: String) {
        print("OTPString: \(otpString)")
        otpString = otp
        
    }
}
