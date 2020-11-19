//
//  KTForgotPassViewController.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 1/11/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
import Spring

class KTForgotPassViewController: KTBaseViewController, KTForgotPassViewModelDelegate, UITextFieldDelegate, CountryListDelegate  {
  
  @IBOutlet weak var txtPhoneNumber : KTTextField!
  @IBOutlet weak var txtPassword : KTTextField!
  @IBOutlet weak var txtConfirmPass : KTTextField!
  @IBOutlet weak var btnSubmitt: SpringButton!
  @IBOutlet weak var lblCountryCode: UILabel!
  
  var countryList = CountryList()
  
  var previousView : KTBaseLoginSignUpViewController?
  
  var maskedEmail: String = ""
  
  //MARK: -View LifeCycle
  override func viewDidLoad() {
    viewModel = KTForgotPassViewModel(del:self)
    super.viewDidLoad()
    countryList.delegate = self
    setCountry(country: Country(countryCode: "QA", phoneExtension: "974"))
    txtPhoneNumber.textField.delegate = self
    txtPassword.textField.delegate = self
    txtConfirmPass.textField.delegate = self
    txtPhoneNumber.placeHolder = "str_phone".localized()
    txtPassword.placeHolder = "str_new_password".localized()
    txtConfirmPass.placeHolder = "str_confirm_new_password".localized()
    btnSubmitt.setTitle("txt_continue".localized(), for: .normal)
    txtPassword.passwordEntry = true
    txtConfirmPass.passwordEntry = true
    txtPhoneNumber.textField.keyboardType = .phonePad
    tapToDismissKeyboard()

    // Do any additional setup after loading the view.
    //btnSubmitt.isHidden = true
    // navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(btnSubmitTapped))
    //        let countryTap = UITapGestureRecognizer(target: self, action: #selector(countrySelectorTapped))
    //        lblCountryCode.addGestureRecognizer(countryTap)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.isNavigationBarHidden = true
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.isNavigationBarHidden = false
  }
  
  @IBAction func countrySelectorTapped(_ sender: UIButton) {
    let navController = UINavigationController(rootViewController: countryList)
    self.present(navController, animated: true, completion: nil)
  }
  
  func selectedCountry(country: Country) {
    (viewModel as! KTForgotPassViewModel).setSelectedCountry(country: country)
    setCountry(country: country)
  }
  
  func setCountry(country: Country) {
    lblCountryCode.text = country.flag! + " " + country.countryCode + " +" + country.phoneExtension
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
      otpView.countryCode = countryCode()!
      otpView.phone = phoneNumber()!
    }
    else if segue.identifier == "SegueForgotPassToMaskedEmailConfirmation"
    {
      let maskedEmailVC : KTMaskedEmailConfirmationVC = segue.destination as! KTMaskedEmailConfirmationVC
      maskedEmailVC.previousView = previousView
      maskedEmailVC.countryCode = countryCode()!
      maskedEmailVC.phone = phoneNumber()!
      maskedEmailVC.maskedEmail = maskedEmail
      maskedEmailVC.password = password()!
    }
  }
  
  @IBAction func btnSubmitTapped(_ sender: Any)
  {
    (viewModel as! KTForgotPassViewModel).btnSubmitTapped()
  }
  
  func phoneNumber() -> String? {
    return txtPhoneNumber.text?.convertToNumbersIfNeeded()
  }
  
  func countryCode() -> String? {
    return "+" + (viewModel as! KTForgotPassViewModel).country.phoneExtension
  }
  
  func password() -> String? {
    return txtPassword.text
  }
  
  func rePassword() -> String? {
    return txtConfirmPass.text
  }
  
  func navigateToOTP() {
    self.performSegue(withIdentifier: "SegueForgotPassToOTP", sender: self)
  }
  
  func navigateToEnterEmail(phone: String, password: String, maskedEmail: String)
  {
    self.maskedEmail = maskedEmail
    self.performSegue(withIdentifier: "SegueForgotPassToMaskedEmailConfirmation", sender: self)
  }
  
  @IBAction func btnCloseTapped(_ sender: Any) {
    
    if previousView != nil {
      
      previousView?.dismiss()
    }
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
  
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    if txtPassword.textField == textField {
      txtPassword.textFieldState = .focused
    }
    
    if txtConfirmPass.textField == textField {
      txtConfirmPass.textFieldState = .focused
    }
    
    if txtPhoneNumber.textField == textField {
      txtPhoneNumber.textFieldState = .focused
    }
    
    return true
  }
  
  func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
    
    if txtPassword.textField == textField {
      txtPassword.textFieldState = .normal
    }
    
    if txtConfirmPass.textField == textField {
      txtConfirmPass.textFieldState = .normal
    }
    
    if txtPhoneNumber.textField == textField {
      txtPhoneNumber.textFieldState = .normal
    }
    return true
  }
}
