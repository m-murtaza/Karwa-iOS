//
//  KTSignUpFormViewController.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 1/8/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

class KTSignUpFormViewController: KTBaseViewController,KTSignUpViewModelDelegate {
    
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtMobileNo: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!

    override func viewDidLoad() {
        viewModel = KTSignUpFormViewModel(del:self)
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
        if segue.identifier == "segueSignupToOtp"
        {
            let otpView : KTOTPViewController = segue.destination as! KTOTPViewController
            otpView.phone = mobileNo()!
        }
        if segue.identifier == "segueRegisterToWebView"
        {
            let webView : KTWebViewController = segue.destination as! KTWebViewController
            webView.url = Constants.TOSUrl
            webView.navTitle = "Terms of Service"
        }
    }
 
    // MARK : - User Intraction
    @IBAction func btnTremsOfServicesTapped(_ sender: Any) {
    }
    
    @IBAction func btnSubmitTapped(_ sender: Any) {
        (viewModel as! KTSignUpFormViewModel).SignUp()
    }
    
    // MARK: - View model Delegates
    func name() -> String? {
        return txtName.text
    }
    
    func mobileNo() -> String? {
        return txtMobileNo.text
    }
    
    func email() -> String? {
        return txtEmail.text
    }
    
    func password() -> String? {
        return txtPassword.text
    }
    
    func navigateToOTP() {
        self.performSegue(withIdentifier: "segueSignupToOtp", sender: self)
    }
    
}
