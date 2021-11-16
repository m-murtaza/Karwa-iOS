//
//  LoginViewController.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 7/3/17.
//  Copyright © 2017 Karwa. All rights reserved.
//

import UIKit
import Spring
import MaterialComponents

let ALLOWED_NUM_PHONE_CHAR : Int = 15

class KTLoginViewController: KTBaseLoginSignUpViewController, KTLoginViewModelDelegate, UITextFieldDelegate, CountryListDelegate {
  
    
    
  //MARK: - Properties
  @IBOutlet weak var loginButton: SpringButton!
  @IBOutlet weak var lblCountryCode: UILabel!
    @IBOutlet weak var phoneNumberTextFieldBGView: UIView!
  @IBOutlet weak var phoneNumberTextField: MDCFilledTextField!
    @IBOutlet weak var passwordTextFieldView: UIView!
  @IBOutlet weak var passwordTextField: MDCFilledTextField!
  @IBOutlet weak var backButton: UIButton!
  @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var toggleEnvironmentButton: UIButton!
    @IBOutlet weak var lblLoginHeader: UILabel!
  
  var countryList = CountryList()
    var toggleEnvironmentClickCount = 0
  
  //MARK: -View LifeCycle
  override func viewDidLoad() {
    viewModel = KTLoginViewModel(del:self)
    
    super.viewDidLoad()
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        self.phoneNumberTextField.becomeFirstResponder()
    }

    setupUI()
  }
    
    func setupUI()
    {
        phoneNumberTextField.label.text = "str_phone".localized()
        passwordTextField.label.text = "str_password".localized()
                
        phoneNumberTextField.label.font = UIFont(name: "MuseoSans-500", size: 11.0)!
        passwordTextField.label.font = UIFont(name: "MuseoSans-500", size: 11.0)!

        phoneNumberTextField.setUnderlineColor(UIColor(hexString: "#005866"), for: .editing)
        phoneNumberTextField.setUnderlineColor(UIColor(hexString: "#C9C9C9"), for: .normal)
        passwordTextField.setUnderlineColor(UIColor(hexString: "#005866"), for: .editing)
        passwordTextField.setUnderlineColor(UIColor(hexString: "#C9C9C9"), for: .normal)
        
        phoneNumberTextField.setUnderlineColor(UIColor.clear, for: .editing)
        phoneNumberTextField.setUnderlineColor(UIColor.clear, for: .normal)
        passwordTextField.setUnderlineColor(UIColor.clear, for: .editing)
        passwordTextField.setUnderlineColor(UIColor.clear, for: .normal)

        phoneNumberTextField.label.textColor = UIColor(hexString: "#6CB1B7")
        
        phoneNumberTextField.tintColor = UIColor(hexString: "#6CB1B7")
        passwordTextField.tintColor = UIColor(hexString: "#6CB1B7")
        
        phoneNumberTextField.inputView?.tintColor = UIColor(hexString: "#6CB1B7")

        phoneNumberTextField.label.textColor = UIColor(hexString: "#6CB1B7")
        phoneNumberTextField.setFilledBackgroundColor(UIColor(hexString: "#FFFFFF"), for: .normal)
        phoneNumberTextField.setFilledBackgroundColor(UIColor(hexString: "#FFFFFF"), for: .editing)
        passwordTextField.setFilledBackgroundColor(UIColor(hexString: "#FFFFFF"), for: .normal)
        passwordTextField.setFilledBackgroundColor(UIColor(hexString: "#FFFFFF"), for: .editing)

        passwordTextField.isSecureTextEntry = true
        phoneNumberTextField.keyboardType = UIKeyboardType.numberPad

        phoneNumberTextField.delegate = self
        passwordTextField.delegate = self
        
        countryList.delegate = self

        setCountry(country: Country(countryCode: "QA", phoneExtension: "974"))
        backButton.setImage(UIImage(named: "back_arrow_ico")?.imageFlippedForRightToLeftLayoutDirection(), for: .normal)
        tapToDismissKeyboard()

        NotificationCenter.default.addObserver(self, selector: #selector(handlerKeyboard), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handlerKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        
        phoneNumberTextFieldBGView.clipsToBounds = true
        passwordTextFieldView.clipsToBounds = true
        
        phoneNumberTextFieldBGView.customBorderWidth = 0
        passwordTextFieldView.customBorderWidth = 0
        
        setupLoginHeaderTap()
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
  
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        let maxLength = ALLOWED_NUM_PHONE_CHAR
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        print(textField.tag)
        
        if textField.tag == 10 {
            phoneNumberTextFieldBGView.customBorderWidth = 3
            passwordTextFieldView.customBorderWidth = 0
        } else {
            phoneNumberTextFieldBGView.customBorderWidth = 0
            passwordTextFieldView.customBorderWidth = 3
        }
        
        
      return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        
        if textField.tag == 10 {
            phoneNumberTextFieldBGView.customBorderWidth = 0
        } else if textField.tag == 11 {
            passwordTextFieldView.customBorderWidth = 0
        }
        
//        phoneNumberTextFieldBGView.customBorderWidth = 0
//        passwordTextFieldView.customBorderWidth = 0
      return true
    }
  
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 10 {
            phoneNumberTextFieldBGView.customBorderWidth = 0
        } else if textField.tag == 11 {
            passwordTextFieldView.customBorderWidth = 0
        }
    }
    
    func setupLoginHeaderTap() {
        let labelTap = UITapGestureRecognizer(target: self, action: #selector(self.onLoginHeaderTap(_:)))
        self.lblLoginHeader.isUserInteractionEnabled = true
        self.lblLoginHeader.addGestureRecognizer(labelTap)
    }
    
    @objc func onLoginHeaderTap(_ sender: UITapGestureRecognizer) {
        self.toggleEnvironmentClickCount += 1
        if self.toggleEnvironmentClickCount == 10 {
            self.toggleEnvironmentButton.setTitle(KTConfiguration.sharedInstance.environment ?? "STAGE", for: .normal)
            self.toggleEnvironmentButton.isHidden = false
        }
    }
    
    @IBAction func toggleEnvironmentTapped(_ sender: Any) {
        KTConfiguration.sharedInstance.setEnvironment(environment: KTConfiguration.sharedInstance.environment == "STAGE" ? .PROD : .STAGE)
        KTWebClient.sharedInstance.baseURL = KTConfiguration.sharedInstance.envValue(forKey: Constants.API.BaseURLKey)
        self.toggleEnvironmentButton.setTitle(KTConfiguration.sharedInstance.environment ?? "STAGE", for: .normal)
    }
  
  @IBAction func countrySelectorTapped(_ sender: Any) {
    let navController = UINavigationController(rootViewController: countryList)
    self.present(navController, animated: true, completion: nil)
  }
  
  func selectedCountry(country: Country) {
    (viewModel as! KTLoginViewModel).setSelectedCountry(country: country)
    setCountry(country: country)
  }
  
  func setCountry(country: Country) {
    lblCountryCode.text = country.flag! + " " + country.countryCode + " +" + country.phoneExtension
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
  }
  
  // MARK: - Navigation
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    if segue.identifier == "segueLoginToForgotPass" {
      let forgotPassNav : UINavigationController  = segue.destination as! UINavigationController
      let forgotPassViewController = forgotPassNav.topViewController as! KTForgotPassViewController
      forgotPassViewController.previousView = self
    }
    else if  segue.identifier == "segueLoginToOTP"
    {
      
      let otpViewNav : UINavigationController  = segue.destination as! UINavigationController
      let otpView = otpViewNav.topViewController as! KTOTPViewController
      otpView.previousView = self
      
      otpView.countryCode = "+" + (viewModel as! KTLoginViewModel).country.phoneExtension
    }
  }
  
  //MARK: UI Events
  
  @IBAction func loginbtnTouchDown(_ sender: SpringButton)
  {
    springAnimateButtonTapIn(button: loginButton)
  }
  
  @IBAction func loginbtnTouchUpOutside(_ sender: SpringButton)
  {
    springAnimateButtonTapOut(button: loginButton)
  }
  
  @IBAction func loginBtnTapped(_ sender: Any)
  {
    springAnimateButtonTapOut(button: loginButton)
    (viewModel as! KTLoginViewModel).loginBtnTapped()
  }
  
  @IBAction func btnBackTapped(_ sender:Any)
  {
    self.navigationController?.popViewController(animated: true)
  }
  
  //Mark: - View Model Delegate
  func phoneNumber() -> String {
    guard let _ =  passwordTextField.text else {
      return ""
    }

    return phoneNumberTextField.text!.convertToNumbersIfNeeded()
  }
  
  func password() -> String {
    guard let _ = passwordTextField.text else {

      return ""
    }
    return passwordTextField.text!
  }
  
    func navigateToBooking()
    {
      self.tabBarController?.tabBar.alpha = 0
      self.tabBarController?.tabBar.isHidden = false
      self.performSegue(withIdentifier: "segueToBooking", sender: self)
    }
      
    func navigateToOTP() {
      self.tabBarController?.tabBar.alpha = 1
      self.performSegue(withIdentifier: "segueLoginToOTP", sender: self)
    }
  
  //MARK:- TextField Delegate
  //Bug 2567 Fixed.
//  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//
    //        if textField == txtPhoneNumber {
    //
    //            let currentText = textField.text ?? ""
    //
    //            guard let stringRange = Range(range, in: currentText) else { return false }
    //
    //            let changedText = currentText.replacingCharacters(in: stringRange, with: string)
    //
    //            return changedText.count <= ALLOWED_NUM_PHONE_CHAR
    //        }
//    return true
//  }
//
//  func textFieldShouldReturn(_ textField: UITextField) -> Bool
//  {
//    if textField == passwordTextField.textField
//    {
//      textField.resignFirstResponder()
//      (viewModel as! KTLoginViewModel).loginBtnTapped()
//    }
//    return true
//  }
//
//  @objc func textFieldDidChange(_ textField: UITextField)
//  {
//    phoneNumberTextField.text = textField.text?.replacingOccurrences(of: "+974", with: "")
//    phoneNumberTextField.text = textField.text?.replacingOccurrences(of: " ", with: "")
//
//    if(phoneNumberTextField.text?.count == ALLOWED_NUM_PHONE_CHAR)
//    {
//      phoneNumberTextField.resignFirstResponder()
//      passwordTextField.becomeFirstResponder()
//    }
//  }
  
//  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
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
  
//  func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
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
