//
//  KTFavoriteAddressViewController.swift
//  KarwaRide
//
//  Created by Umer Afzal on 02/11/2020.
//  Copyright © 2020 Karwa. All rights reserved.
//

import UIKit
import MaterialComponents

class KTFavoriteAddressViewController: KTBaseViewController {
  
  @IBOutlet weak var navigationBar: UIView!
  @IBOutlet weak var locationNameTextField: MDCFilledTextField!
  @IBOutlet weak var locationTextField: MDCFilledTextField!
  
  var favoritelocation: KTGeoLocation?
  
  override func viewDidLoad() {
    viewModel = KTAddressFavoriteViewModel(del:self)
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    setupUI()
  }
  
  private func setupUI() {
    changeStatusBarColor(color: UIColor.primaryLight)
    navigationBar.backgroundColor = UIColor.primaryLight

    locationNameTextField.label.text = "txt_loc_name".localized()
    locationNameTextField.label.font = UIFont(name: "MuseoSans-500", size: 11.0)!
    locationNameTextField.setUnderlineColor(UIColor(hexString: "#005866"), for: .editing)
    locationNameTextField.setUnderlineColor(UIColor(hexString: "#005866"), for: .normal)
    locationNameTextField.label.textColor = UIColor(hexString: "#6CB1B7")
    locationNameTextField.tintColor = UIColor(hexString: "#6CB1B7")
    locationNameTextField.inputView?.tintColor = UIColor(hexString: "#6CB1B7")
    locationNameTextField.label.textColor = UIColor(hexString: "#6CB1B7")
    locationNameTextField.setFilledBackgroundColor(UIColor(hexString: "#FFFFFF"), for: .normal)
    locationNameTextField.setFilledBackgroundColor(UIColor(hexString: "#FFFFFF"), for: .editing)
    
    locationTextField.label.text = "txt_loc_name".localized()
    locationTextField.label.font = UIFont(name: "MuseoSans-500", size: 11.0)!
    locationTextField.setUnderlineColor(UIColor(hexString: "#005866"), for: .editing)
    locationTextField.setUnderlineColor(UIColor(hexString: "#005866"), for: .normal)
    locationTextField.label.textColor = UIColor(hexString: "#6CB1B7")
    locationTextField.tintColor = UIColor(hexString: "#6CB1B7")
    locationTextField.inputView?.tintColor = UIColor(hexString: "#6CB1B7")
    locationTextField.label.textColor = UIColor(hexString: "#6CB1B7")
    locationTextField.setFilledBackgroundColor(UIColor(hexString: "#FFFFFF"), for: .normal)

//    locationTextField.label.text = "txt_location_head".localized()
    
//    locationTextField.textField.delegate = self
//    locationNameTextField.textField.delegate = self
    
    if let loc = favoritelocation {
      locationTextField.label.text = loc.name
    }
    if let name = favoritelocation?.favoriteName {
      locationNameTextField.text = name
    }
    locationTextField.isUserInteractionEnabled = false
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        self.locationNameTextField.becomeFirstResponder()
    }

//    locationTextField.textField.titleColor = #colorLiteral(red: 0, green: 0.3803921569, blue: 0.4392156863, alpha: 0.5)
//    locationTextField.textField.textColor = #colorLiteral(red: 0, green: 0.3803921569, blue: 0.4392156863, alpha: 0.5)
  }
  
  @IBAction func saveLocationAction(_ sender: UIButton) {
    (viewModel as! KTAddressFavoriteViewModel).saveLocation()
  }
  
  @IBAction func dismissAction(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }
  
}

extension KTFavoriteAddressViewController: KTAddressFavoriteViewModelDelegate {
  var locationName: String {
    locationNameTextField.text!
  }
  
  var location: KTGeoLocation {
    favoritelocation!
  }
  
  func locationSavedSuccessfully(location: KTGeoLocation) {
    dismissAction(self)
  }
  
}

//extension KTFavoriteAddressViewController: UITextFieldDelegate {
//  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//    if textField == locationTextField.textField {
//      locationTextField.textFieldState = .focused
//    }
//    if textField == locationNameTextField.textField {
//      locationNameTextField.textFieldState = .focused
//    }
//    return true
//  }
//
//  func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
//    if textField == locationTextField.textField {
//      locationTextField.textFieldState = .normal
//    }
//    if textField == locationNameTextField.textField {
//      locationNameTextField.textFieldState = .normal
//    }
//    return true
//  }
//}
