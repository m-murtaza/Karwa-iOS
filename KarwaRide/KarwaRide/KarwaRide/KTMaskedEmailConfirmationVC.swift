//
//  KTMaskedEmailConfirmationVC.swift
//  KarwaRide
//
//  Created by SAM on 5/20/19.
//  Copyright © 2019 Karwa. All rights reserved.
//

import Foundation
import Spring

class KTMaskedEmailConfirmationVC: KTBaseViewController, KTMaskedEmailViewModelDelegate {

    @IBOutlet weak var lblMaskedEmail: SpringLabel!
    @IBOutlet weak var lblEmail: SpringTextField!
    
    var phone : String = ""
    var password: String = ""
    var maskedEmail: String = ""
    var previousView : KTBaseLoginSignUpViewController?
    
    //MARK: -View LifeCycle
    override func viewDidLoad() {
        viewModel = KTMasedEmailConfirmationViewModel(del:self)
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.

        lblMaskedEmail.text = maskedEmail
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(btnSubmitTapped))
        
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
            otpView.phone = phone
            otpView.password = self.password
        }
    }
    
    @IBAction func btnSubmitTapped(_ sender: Any)
    {
        (viewModel as! KTMasedEmailConfirmationViewModel).btnSubmitTapped()
        //navigateToOTP()
    }
    
    func phoneNumber() -> String? {
        return phone
    }
    
    func email() -> String? {
        return lblEmail.text
    }
    
    func md5password() -> String? {
        return password
    }
    
    func navigateToOTP() {
        self.performSegue(withIdentifier: "SegueForgotPassToOTP", sender: self)
    }
    
    @IBAction func btnCloseTapped(_ sender: Any) {
        
        if previousView != nil {
            
            previousView?.dismiss()
        }
    }
}

