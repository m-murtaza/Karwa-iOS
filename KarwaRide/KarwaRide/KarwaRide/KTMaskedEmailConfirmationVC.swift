//
//  KTMaskedEmailConfirmationVC.swift
//  KarwaRide
//
//  Created by SAM on 5/20/19.
//  Copyright © 2019 Karwa. All rights reserved.
//

import Foundation
import Spring
import MaterialComponents

class KTMaskedEmailConfirmationVC: KTBaseViewController, KTMaskedEmailViewModelDelegate {
  
  @IBOutlet weak var lblMaskedEmail: SpringLabel!
  @IBOutlet weak var emailTextField: MDCFilledTextField!
  
  var phone : String = ""
  var password: String = ""
  var maskedEmail: String = ""
  var countryCode: String = ""
  var previousView : KTBaseLoginSignUpViewController?
  
  //MARK: -View LifeCycle
  override func viewDidLoad() {
    viewModel = KTMasedEmailConfirmationViewModel(del:self)
    super.viewDidLoad()
    lblMaskedEmail.text = maskedEmail
    emailTextField.delegate = self
    emailTextField.label.text = "str_email".localized()
    InputFieldUtil.applyTheme(emailTextField, false)
    tapToDismissKeyboard()
    // Do any additional setup after loading the view.
    //navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(btnSubmitTapped))
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.isNavigationBarHidden = true
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.isNavigationBarHidden = false
  }
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    if segue.identifier == "SegueMaskedEmailToOTP"
    {
      
      let otpView : KTOTPViewController = segue.destination as! KTOTPViewController
      otpView.previousView = previousView
      otpView.countryCode = countryCode
      otpView.phone = phoneNumber()!
      otpView.password = self.password
    }
  }
  
  @IBAction func btnSubmitTapped(_ sender: Any)
  {
    (viewModel as! KTMasedEmailConfirmationViewModel).btnSubmitTapped()
  }
  
  func countryCallingCode() -> String? {
    return countryCode
  }
  
  func phoneNumber() -> String? {
    return phone
  }
  
  func email() -> String? {
    return emailTextField.text
  }
  
  func md5password() -> String? {
    return password
  }
  
  func navigateToOTP() {
    self.performSegue(withIdentifier: "SegueMaskedEmailToOTP", sender: self)
  }
  
  @IBAction func btnCloseTapped(_ sender: Any) {
    
    if previousView != nil {
      
      previousView?.dismiss()
    }
  }
  
}

extension KTMaskedEmailConfirmationVC: UITextFieldDelegate {
//  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//
//    if emailTextField == textField {
//      emailTextField = .focused
//    }
//    return true
//  }
//
//  func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
//
//    if emailTextField.textField == textField {
//      emailTextField.textFieldState = .normal
//    }
//    return true
//  }
}

