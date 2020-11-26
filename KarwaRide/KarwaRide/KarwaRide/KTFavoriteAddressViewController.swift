//
//  KTFavoriteAddressViewController.swift
//  KarwaRide
//
//  Created by Umer Afzal on 02/11/2020.
//  Copyright © 2020 Karwa. All rights reserved.
//

import UIKit

class KTFavoriteAddressViewController: KTBaseViewController {
  
  @IBOutlet weak var navigationBar: UIView!
  @IBOutlet weak var locationNameTextField: KTTextField!
  @IBOutlet weak var locationTextField: KTTextField!
  
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
    locationNameTextField.placeHolder = "txt_loc_name".localized()
    locationTextField.placeHolder = "txt_location_head".localized()
    
    locationTextField.textField.delegate = self
    locationNameTextField.textField.delegate = self
    
    if let loc = favoritelocation {
      locationTextField.textField.text = loc.name
    }
    if let name = favoritelocation?.favoriteName {
      locationNameTextField.text = name
    }
    locationTextField.isUserInteractionEnabled = false
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
      self.locationNameTextField.textField.becomeFirstResponder()
    }
    locationTextField.textField.titleColor = #colorLiteral(red: 0, green: 0.3803921569, blue: 0.4392156863, alpha: 0.5)
    locationTextField.textField.textColor = #colorLiteral(red: 0, green: 0.3803921569, blue: 0.4392156863, alpha: 0.5)
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

extension KTFavoriteAddressViewController: UITextFieldDelegate {
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    if textField == locationTextField.textField {
      locationTextField.textFieldState = .focused
    }
    if textField == locationNameTextField.textField {
      locationNameTextField.textFieldState = .focused
    }
    return true
  }
  
  func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
    if textField == locationTextField.textField {
      locationTextField.textFieldState = .normal
    }
    if textField == locationNameTextField.textField {
      locationNameTextField.textFieldState = .normal
    }
    return true
  }
}
