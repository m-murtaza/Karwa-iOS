//
//  KTChangePhoneNumberViewController.swift
//  KarwaRide
//
//  Created by Apple on 22/12/21.
//  Copyright © 2021 Karwa. All rights reserved.
//

import UIKit
import Spring
import MaterialComponents

class KTChangePhoneNumberViewController: KTBaseViewController, KTForgotPassViewModelDelegate, UITextFieldDelegate, CountryListDelegate  {
  
  @IBOutlet weak var txtPhoneNumber : MDCFilledTextField!
  @IBOutlet weak var phoneNumberTextFieldBGView: UIView!
  @IBOutlet weak var btnSubmitt: SpringButton!
  @IBOutlet weak var lblCountryCode: UILabel!
  @IBOutlet weak var scrollView: UIScrollView!
  
  var countryList = CountryList()
  
  var previousView : KTChangePhoneNumberViewController?
  
  var maskedEmail: String = ""
    
  var userCountryCode = ""
  var userPhoneNumber = ""

  var userProfile: KTUser?
  
  //MARK: -View LifeCycle
  override func viewDidLoad() {
    viewModel = KTForgotPassViewModel(del:self)
    super.viewDidLoad()
    countryList.delegate = self
      
      let prefixCodes = ["AF": "93", "AE": "971", "AL": "355", "AN": "599", "AS":"1", "AD": "376", "AO": "244", "AI": "1", "AG":"1", "AR": "54","AM": "374", "AW": "297", "AU":"61", "AT": "43","AZ": "994", "BS": "1", "BH":"973", "BF": "226","BI": "257", "BD": "880", "BB": "1", "BY": "375", "BE":"32","BZ": "501", "BJ": "229", "BM": "1", "BT":"975", "BA": "387", "BW": "267", "BR": "55", "BG": "359", "BO": "591", "BL": "590", "BN": "673", "CC": "61", "CD":"243","CI": "225", "KH":"855", "CM": "237", "CA": "1", "CV": "238", "KY":"345", "CF":"236", "CH": "41", "CL": "56", "CN":"86","CX": "61", "CO": "57", "KM": "269", "CG":"242", "CK": "682", "CR": "506", "CU":"53", "CY":"537","CZ": "420", "DE": "49", "DK": "45", "DJ":"253", "DM": "1", "DO": "1", "DZ": "213", "EC": "593", "EG":"20", "ER": "291", "EE":"372","ES": "34", "ET": "251", "FM": "691", "FK": "500", "FO": "298", "FJ": "679", "FI":"358", "FR": "33", "GB":"44", "GF": "594", "GA":"241", "GS": "500", "GM":"220", "GE":"995","GH":"233", "GI": "350", "GQ": "240", "GR": "30", "GG": "44", "GL": "299", "GD":"1", "GP": "590", "GU": "1", "GT": "502", "GN":"224","GW": "245", "GY": "595", "HT": "509", "HR": "385", "HN":"504", "HU": "36", "HK": "852", "IR": "98", "IM": "44", "IL": "972", "IO":"246", "IS": "354", "IN": "91", "ID":"62", "IQ":"964", "IE": "353","IT":"39", "JM":"1", "JP": "81", "JO": "962", "JE":"44", "KP": "850", "KR": "82","KZ":"77", "KE": "254", "KI": "686", "KW": "965", "KG":"996","KN":"1", "LC": "1", "LV": "371", "LB": "961", "LK":"94", "LS": "266", "LR":"231", "LI": "423", "LT": "370", "LU": "352", "LA": "856", "LY":"218", "MO": "853", "MK": "389", "MG":"261", "MW": "265", "MY": "60","MV": "960", "ML":"223", "MT": "356", "MH": "692", "MQ": "596", "MR":"222", "MU": "230", "MX": "52","MC": "377", "MN": "976", "ME": "382", "MP": "1", "MS": "1", "MA":"212", "MM": "95", "MF": "590", "MD":"373", "MZ": "258", "NA":"264", "NR":"674", "NP":"977", "NL": "31","NC": "687", "NZ":"64", "NI": "505", "NE": "227", "NG": "234", "NU":"683", "NF": "672", "NO": "47","OM": "968", "PK": "92", "PM": "508", "PW": "680", "PF": "689", "PA": "507", "PG":"675", "PY": "595", "PE": "51", "PH": "63", "PL":"48", "PN": "872","PT": "351", "PR": "1","PS": "970", "QA": "974", "RO":"40", "RE":"262", "RS": "381", "RU": "7", "RW": "250", "SM": "378", "SA":"966", "SN": "221", "SC": "248", "SL":"232","SG": "65", "SK": "421", "SI": "386", "SB":"677", "SH": "290", "SD": "249", "SR": "597","SZ": "268", "SE":"46", "SV": "503", "ST": "239","SO": "252", "SJ": "47", "SY":"963", "TW": "886", "TZ": "255", "TL": "670", "TD": "235", "TJ": "992", "TH": "66", "TG":"228", "TK": "690", "TO": "676", "TT": "1", "TN":"216","TR": "90", "TM": "993", "TC": "1", "TV":"688", "UG": "256", "UA": "380", "US": "1", "UY": "598","UZ": "998", "VA":"379", "VE":"58", "VN": "84", "VG": "1", "VI": "1","VC":"1", "VU":"678", "WS": "685", "WF": "681", "YE": "967", "YT": "262","ZA": "27" , "ZM": "260", "ZW":"263"]
      
      if let countryCode = userProfile?.countryCode?.replacingOccurrences(of: "+", with: "") {
          if let key = prefixCodes.someKey(forValue: countryCode) {
              print("key", key)
              setCountry(country: Country(countryCode: key, phoneExtension: countryCode))
              (viewModel as! KTForgotPassViewModel).setSelectedCountry(country: Country(countryCode: key, phoneExtension: countryCode))
          }
      }
      
    txtPhoneNumber.delegate = self
    txtPhoneNumber.label.text = "str_phone".localized()
    btnSubmitt.setTitle("txt_continue".localized(), for: .normal)

    InputFieldUtil.applyTheme(txtPhoneNumber, false)
    
    txtPhoneNumber.keyboardType = .numberPad
    tapToDismissKeyboard()
      
      txtPhoneNumber.becomeFirstResponder()
      txtPhoneNumber.text = userProfile?.phone ?? ""
      txtPhoneNumber.setUnderlineColor(UIColor.clear, for: .editing)
      txtPhoneNumber.setUnderlineColor(UIColor.clear, for: .normal)
      txtPhoneNumber.backgroundColor = .white
      phoneNumberTextFieldBGView.clipsToBounds = true
      phoneNumberTextFieldBGView.customBorderWidth = 0

    NotificationCenter.default.addObserver(self, selector: #selector(handlerKeyboard), name: Notification.Name.UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(handlerKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
  }
    func countryName(countryCode: String) -> String? {
        let current = Locale(identifier: "en_US")
        print(current.localizedString(forRegionCode: countryCode))
        return current.localizedString(forRegionCode: countryCode)
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
     let number = txtPhoneNumber.text, !number.isEmpty else {
     self.btnSubmitt.isEnabled = false
     return
   }
   // enable okButton if all conditions are met
    self.btnSubmitt.isEnabled = true
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.isNavigationBarHidden = true
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.isNavigationBarHidden = false
  }
    
    @IBAction func goBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
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
    if segue.identifier == "SegueChangePasswordToOTP"
    {
      
      let otpView : KTOTPViewController = segue.destination as! KTOTPViewController
//      otpView.previousView = previousView
      otpView.otpType = "CHANGE_NUMBER_CHALLENGE"
      otpView.countryCode = KTUserManager().loginUserInfo()?.countryCode ?? ""
      otpView.phone = KTUserManager().loginUserInfo()?.phone ?? ""
    }

  }
  
  @IBAction func btnSubmitTapped(_ sender: Any)
  {
    (viewModel as! KTForgotPassViewModel).btnChangePhonenumberTapped()
  }
  
  func phoneNumber() -> String? {
    return txtPhoneNumber.text?.convertToNumbersIfNeeded()
  }
  
  func countryCode() -> String? {
    return "+" + (viewModel as! KTForgotPassViewModel).country.phoneExtension
  }
  
  func password() -> String? {
    return ""
  }
  
  func rePassword() -> String? {
    return ""
  }
  
  func navigateToOTP() {
    self.performSegue(withIdentifier: "SegueChangePasswordToOTP", sender: self)
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
                
        switch textField.tag {
        case 11:
            phoneNumberTextFieldBGView.customBorderWidth = 3
        case 12:
            phoneNumberTextFieldBGView.customBorderWidth = 0
        case 13:
            phoneNumberTextFieldBGView.customBorderWidth = 0
        default:
            return true
        }
        
        return true
        
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 11:
            phoneNumberTextFieldBGView.customBorderWidth = 0
        case 12:
            return true
        case 13:
            return true
        default:
            return true
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField.tag {
        case 11:
            phoneNumberTextFieldBGView.customBorderWidth = 0
        default:
            break
        }
    }
    
  
//  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//    if txtPassword == textField {
//      txtPassword = .focused
//    }
//
//    if txtConfirmPass == textField {
//      txtConfirmPass = .focused
//    }
//
//    if txtPhoneNumber == textField {
//      txtPhoneNumber = .focused
//    }
//
//    return true
//  }
//
//  func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
//
//    if txtPassword == textField {
//        txtPassword.text. = .normal
//    }
//
//    if txtConfirmPass == textField {
//        txtConfirmPass.state = .normal
//    }
//
//    if txtPhoneNumber == textField {
//        txtPhoneNumber.state = .normal
//    }
//    return true
//  }
}


extension Dictionary where Value: Equatable {
    func someKey(forValue val: Value) -> Key? {
        return first(where: { $1 == val })?.key
    }
}
