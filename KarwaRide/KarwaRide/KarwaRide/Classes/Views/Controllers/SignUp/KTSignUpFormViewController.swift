//
//  KTSignUpFormViewController.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 1/8/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
import Spring

class KTSignUpFormViewController: KTBaseLoginSignUpViewController, KTSignUpViewModelDelegate, CountryListDelegate {
  
  @IBOutlet weak var nameTextField: KTTextField!
  @IBOutlet weak var phoneNumberTextField: KTTextField!
  @IBOutlet weak var emailTextField: KTTextField!
  @IBOutlet weak var passwordTextField: KTTextField!
  @IBOutlet weak var signUpBtn: SpringButton!
  @IBOutlet weak var lblCountryCode: UILabel!
  @IBOutlet weak var backButton: UIButton!
  
  var countryList = CountryList()
  
  override func viewDidLoad() {
    viewModel = KTSignUpFormViewModel(del:self)
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    navigationItem.title = "New Account"
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(btnSubmitTapped))
    
    countryList.delegate = self
    
    setCountry(country: Country(countryCode: "QA", phoneExtension: "974"))
    
    nameTextField.placeHolder = "str_name".localized()
    emailTextField.placeHolder = "str_email".localized()
    phoneNumberTextField.placeHolder = "str_phone".localized()
    passwordTextField.placeHolder = "str_password".localized()
    passwordTextField.passwordEntry = true
    phoneNumberTextField.textField.delegate = self
    passwordTextField.textField.delegate = self
    emailTextField.textField.delegate = self
    nameTextField.textField.delegate = self
    phoneNumberTextField.textField.keyboardType = .phonePad
    
    backButton.setImage(UIImage(named: "back_arrow_ico")?.imageFlippedForRightToLeftLayoutDirection(), for: .normal)
    tapToDismissKeyboard()
    [phoneNumberTextField.textField,
     passwordTextField.textField,
     nameTextField.textField,
     passwordTextField.textField,
     emailTextField.textField].forEach({ $0.addTarget(self, action: #selector(textFieldsIsNotEmpty), for: .editingChanged) })
      signUpBtn.isEnabled = false
  }

  
  
  @objc func textFieldsIsNotEmpty(sender: UITextField) {

   sender.text = sender.text?.trimmingCharacters(in: .whitespaces)

   guard
     let number = phoneNumberTextField.textField.text, !number.isEmpty,
     let password = passwordTextField.textField.text, !password.isEmpty
     else
   {
     self.signUpBtn.isEnabled = false
     return
   }
   // enable okButton if all conditions are met
    self.signUpBtn.isEnabled = true
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
    (viewModel as! KTSignUpFormViewModel).setSelectedCountry(country: country)
    setCountry(country: country)
  }
  
  func setCountry(country: Country) {
    lblCountryCode.text = country.flag! + " " + country.countryCode + " +" + country.phoneExtension
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
      
      let otpViewNav : UINavigationController  = segue.destination as! UINavigationController
      let otpView = otpViewNav.topViewController as! KTOTPViewController
      otpView.previousView = self
      
      otpView.countryCode = "+" + (viewModel as! KTSignUpFormViewModel).country.phoneExtension
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
  
  @IBAction func backButtonAction(_ sender: Any) {
    self.navigationController?.popViewController(animated: true)
  }
  
  @IBAction func loginButtonAction(_ sender: Any) {
    var found = false
    if let controllers = navigationController?.viewControllers {
      for controller in controllers {
        if controller is KTLoginViewController {
          found = true
          navigationController?.popToViewController(controller, animated: true)
          break
        }
      }
    }
    
    if !found {
      performSegue(withIdentifier: "showLoginScreen", sender: nil)
    }
    
  }
  
  @IBAction func btnSubmitTapped(_ sender: Any) {
    (viewModel as! KTSignUpFormViewModel).SignUp()
    //To Skip signup process
    //--self.performSegue(withIdentifier: "segueSignupToOtp", sender: self)
  }
  
  // MARK: - View model Delegates
  func name() -> String? {
    return nameTextField.text
  }
  
  func mobileNo() -> String? {
    return phoneNumberTextField.text?.convertToNumbersIfNeeded()
  }
  
  func email() -> String? {
    return emailTextField.text
  }
  
  func password() -> String? {
    return passwordTextField.text
  }
  
  func navigateToOTP() {
    self.performSegue(withIdentifier: "segueSignupToOtp", sender: self)
  }
  
  //    override func navigateToBooking()
  //    {
  //        self.performSegue(withIdentifier: "segueSignUpToBooking", sender: self)
  //    }
  
}

extension KTSignUpFormViewController: UITextFieldDelegate {
  
  //MARK:- TextField Delegate
  //Bug 2567 Fixed.
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    
    if textField == phoneNumberTextField.textField {
      
      let currentText = textField.text ?? ""
      guard let stringRange = Range(range, in: currentText) else { return false }
      
      let changedText = currentText.replacingCharacters(in: stringRange, with: string)
      
      return changedText.count <= ALLOWED_NUM_PHONE_CHAR
    }
    return true
  }
  
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    if nameTextField.textField == textField {
      nameTextField.textFieldState = .focused
    }
    
    if emailTextField.textField == textField {
      emailTextField.textFieldState = .focused
    }
    
    if phoneNumberTextField.textField == textField {
      phoneNumberTextField.textFieldState = .focused
    }
    
    if passwordTextField.textField == textField {
      passwordTextField.textFieldState = .focused
    }
    return true
  }
  
  func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
    
    if nameTextField.textField == textField {
      nameTextField.textFieldState = .normal
    }
    
    if emailTextField.textField == textField {
      emailTextField.textFieldState = .normal
    }
    
    if phoneNumberTextField.textField == textField {
      phoneNumberTextField.textFieldState = .normal
    }
    
    if passwordTextField.textField == textField {
      passwordTextField.textFieldState = .normal
    }
    return true
  }
}
