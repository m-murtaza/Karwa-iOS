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
    
    var viewModel : KTSignUpFormViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = KTSignUpFormViewModel.init(del: self)
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
    }
 
    
    // MARK : - User Intraction
    @IBAction func btnTremsOfServicesTapped(_ sender: Any) {
    }
    
    @IBAction func btnSubmitTapped(_ sender: Any) {
        viewModel.SignUp()
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
    
    func showError(title: String, message: String) {
        // create the alert
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
}
