//
//  KTFavoriteAddressViewController.swift
//  KarwaRide
//
//  Created by Umer Afzal on 02/11/2020.
//  Copyright © 2020 Karwa. All rights reserved.
//

import UIKit
import MaterialComponents
import SkyFloatingLabelTextField

class KTXpressFavoriteAddressViewController: KTBaseViewController, UITextFieldDelegate {
    
    @IBOutlet weak var navigationBar: UIView!
    @IBOutlet weak var locationNameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var locationTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var setFavBtn: LocalisableButton!

    var xpressFavoriteDelegate: KTXpressFavoriteDelegate?
    
    var favoritelocation: KTGeoLocation?
    
    override func viewDidLoad() {
        viewModel = KTAddressFavoriteViewModel(del:self)
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupUI()
    }
    
    private func setupUI() {
        //changeStatusBarColor(color: UIColor.primaryLight)
       // navigationBar.backgroundColor = UIColor.primaryLight
        
//        setFavBtn.addShadowBottomXpress()
        locationNameTextField.placeholder = "txt_location_head".localized()
        locationNameTextField.font = UIFont(name: "MuseoSans-700", size: 14.0)!
        locationNameTextField.placeholderFont = UIFont(name: "MuseoSans-500", size: 14.0)!
        //locationNameTextField.label.textColor = UIColor(hexString: "#6CB1B7")
        locationNameTextField.tintColor = UIColor(hexString: "#6CB1B7")
        locationNameTextField.inputView?.tintColor = UIColor(hexString: "#6CB1B7")
        locationNameTextField.textColor = UIColor(hexString: "#006170")
        locationNameTextField.delegate = self
        locationNameTextField.titleColor = UIColor(hexString: "#6CB1B7")
        locationNameTextField.titleFont = UIFont(name: "MuseoSans-500", size: 9.0)!
        locationNameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        locationNameTextField.becomeFirstResponder()
        locationNameTextField.title = "txt_location_head".localized()
        
        locationTextField.font = UIFont(name: "MuseoSans-500", size: 14.0)!
        locationTextField.tintColor = UIColor(hexString: "#6CB1B7")
        locationTextField.inputView?.tintColor = UIColor(hexString: "#6CB1B7")
        locationTextField.textColor = UIColor(hexString: "#6CB1B7")
        locationTextField.delegate = self
        locationTextField.titleColor = UIColor(hexString: "#6CB1B7")
        locationTextField.titleFont = UIFont(name: "MuseoSans-500", size: 9.0)!
        locationTextField.title = "txt_loc_name".localized()

        if let loc = favoritelocation {
            locationTextField.text = loc.name
        }
        if let name = favoritelocation?.favoriteName {
            locationNameTextField.text = name
        }
        locationTextField.isUserInteractionEnabled = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.locationNameTextField.becomeFirstResponder()
        }
        
    }
    
    @IBAction func saveLocationAction(_ sender: UIButton) {
        (viewModel as! KTAddressFavoriteViewModel).saveLocation()
    }
    
    @IBAction func dismissAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @objc func textFieldDidChange(_ textfield: UITextField) {
        if let text = textfield.text {
            if let floatingLabelTextField = locationNameTextField {
                
                
            }
        }
    }
    
}

extension KTXpressFavoriteAddressViewController: KTAddressFavoriteViewModelDelegate {
    var locationName: String {
        locationNameTextField.text!
    }
    
    var location: KTGeoLocation {
        favoritelocation!
    }
    
    func locationSavedSuccessfully(location: KTGeoLocation) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            self.xpressFavoriteDelegate?.savedFavorite()
            self.dismiss(animated: true, completion: nil)
        })
        
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
