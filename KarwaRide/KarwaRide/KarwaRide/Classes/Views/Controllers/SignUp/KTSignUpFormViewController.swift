//
//  KTSignUpFormViewController.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 1/8/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
import Spring
import MaterialComponents

class KTSignUpFormViewController: KTBaseLoginSignUpViewController, KTSignUpViewModelDelegate, CountryListDelegate {
  
  @IBOutlet weak var nameTextField: MDCFilledTextField!
  @IBOutlet weak var phoneNumberTextField: MDCFilledTextField!
  @IBOutlet weak var emailTextField: MDCFilledTextField!
  @IBOutlet weak var passwordTextField: MDCFilledTextField!
  @IBOutlet weak var signUpBtn: SpringButton!
  @IBOutlet weak var lblCountryCode: UILabel!
  @IBOutlet weak var backButton: UIButton!
  @IBOutlet weak var scrollView: UIScrollView!
  
  var countryList = CountryList()
  
  override func viewDidLoad() {
    viewModel = KTSignUpFormViewModel(del:self)
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    navigationItem.title = "New Account"
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(btnSubmitTapped))
    
    countryList.delegate = self
    
    setCountry(country: Country(countryCode: "QA", phoneExtension: "974"))
    
//    nameTextField.placeHolder = "str_name".localized()
//    emailTextField.placeHolder = "str_email".localized()
//    phoneNumberTextField.placeHolder = "str_phone".localized()
//    passwordTextField.placeHolder = "str_password".localized()
//    passwordTextField.passwordEntry = true
//    phoneNumberTextField.textField.delegate = self
//    passwordTextField.textField.delegate = self
//    emailTextField.textField.delegate = self
//    nameTextField.textField.delegate = self
//    phoneNumberTextField.textField.keyboardType = .phonePad
    
    backButton.setImage(UIImage(named: "back_arrow_ico")?.imageFlippedForRightToLeftLayoutDirection(), for: .normal)
    tapToDismissKeyboard()
    [phoneNumberTextField,
     passwordTextField,
     nameTextField,
     passwordTextField,
     emailTextField].forEach({ $0.addTarget(self, action: #selector(textFieldsIsNotEmpty), for: .editingChanged) })
    signUpBtn.isEnabled = false
    NotificationCenter.default.addObserver(self, selector: #selector(handlerKeyboard), name: Notification.Name.UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(handlerKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
      self.phoneNumberTextField.becomeFirstResponder()
    }
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  @objc private func handlerKeyboard(notification: Notification) {
    guard let value = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue else { return }
    let showKeyboard = notification.name == Notification.Name.UIKeyboardWillShow
    var height = value.cgRectValue.height
    let insets = self.scrollView.contentInset
    height = showKeyboard ? height : 0.0
    self.scrollView.contentInset = UIEdgeInsets(top: insets.top,
                                                left: insets.left,
                                                bottom: height,
                                                right: insets.right)
    // animate changes
    UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut, animations: {
      self.view.layoutIfNeeded()
    }) { (animated) in
      ()
    }
  }
  
  @objc func textFieldsIsNotEmpty(sender: UITextField) {
    
    sender.text = sender.text?.trimmingCharacters(in: .whitespaces)
    
    guard
      let number = phoneNumberTextField.text, !number.isEmpty,
      let password = passwordTextField.text, !password.isEmpty
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
    
    setupUI()
  }
  
    func setupUI()
    {
        nameTextField.label.text = "str_name".localized()
        emailTextField.label.text = "str_email".localized()
        phoneNumberTextField.label.text = "str_phone".localized()
        passwordTextField.label.text = "str_password".localized()
        
        InputFieldUtil.applyTheme(nameTextField, false)
        InputFieldUtil.applyTheme(emailTextField, false)
        InputFieldUtil.applyTheme(phoneNumberTextField, false)
        InputFieldUtil.applyTheme(passwordTextField, true)

        phoneNumberTextField.delegate = self
        passwordTextField.delegate = self
        emailTextField.delegate = self
        nameTextField.delegate = self
        phoneNumberTextField.keyboardType = .phonePad
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
      webView.navTitle = "about_terms".localized()
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
    
    if textField == phoneNumberTextField {
      
      let currentText = textField.text ?? ""
      guard let stringRange = Range(range, in: currentText) else { return false }
      
      let changedText = currentText.replacingCharacters(in: stringRange, with: string)
      
      return changedText.count <= ALLOWED_NUM_PHONE_CHAR
    }
    return true
  }
  
//  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//    if nameTextField.textField == textField {
//      nameTextField.textFieldState = .focused
//    }
//
//    if emailTextField.textField == textField {
//      emailTextField.textFieldState = .focused
//    }
//
//    if phoneNumberTextField.textField == textField {
//      phoneNumberTextField.textFieldState = .focused
//    }
//
//    if passwordTextField.textField == textField {
//      passwordTextField.textFieldState = .focused
//    }
//    return true
//  }
//
//  func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
//
//    if nameTextField.textField == textField {
//      nameTextField.textFieldState = .normal
//    }
//
//    if emailTextField.textField == textField {
//      emailTextField.textFieldState = .normal
//    }
//
//    if phoneNumberTextField.textField == textField {
//      phoneNumberTextField.textFieldState = .normal
//    }
//
//    if passwordTextField.textField == textField {
//      passwordTextField.textFieldState = .normal
//    }
//    return true
//  }
}
