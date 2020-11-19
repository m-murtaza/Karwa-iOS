//
//  KTTextField.swift
//  KarwaRide
//
//  Created by Umer Afzal on 26/10/2020.
//  Copyright © 2020 Karwa. All rights reserved.
//

import Foundation
import SkyFloatingLabelTextField

class KTTextField: UIView {
  
  let textField: SkyFloatingLabelTextField = {
    let textField = SkyFloatingLabelTextField()
    textField.lineColor = UIColor.clear
    textField.selectedLineColor = UIColor.clear
    textField.titleFormatter = { text in
      return text
    }
    textField.disabledColor = #colorLiteral(red: 0, green: 0.3450980392, blue: 0.4, alpha: 1)
    textField.titleColor = #colorLiteral(red: 0, green: 0.3450980392, blue: 0.4, alpha: 1)
    textField.titleFont = UIFont(name: "MuseoSans-500", size: 11.0)!
    
    textField.placeholderColor = #colorLiteral(red: 0, green: 0.3450980392, blue: 0.4, alpha: 1)
    textField.placeholderFont = UIFont(name: "MuseoSans-700", size: 15.0)!
    textField.tintColor = #colorLiteral(red: 0, green: 0.3450980392, blue: 0.4, alpha: 1)
    textField.textColor = UIColor.primary
    textField.selectedTitleColor = #colorLiteral(red: 0, green: 0.3450980392, blue: 0.4, alpha: 1)
    textField.font = UIFont(name: "MuseoSans-700", size: 15.0)!
    textField.autocorrectionType = .no
    return textField
  }()
  
  let accessoryButton: UIButton = {
    let button = UIButton()
    button.setImage(UIImage(named: "cross_icon_new"), for: .normal)
    return button
  }()
  
  var onValueChange: ((_ sender: KTTextField) -> Void)?
  
  var text: String? {
    get{
      textField.text
    }
    set{
      textField.text = newValue
    }
  }
  
  var placeHolder: String? {
    get{
      textField.placeholder
    }
    set{
      textField.placeholder = newValue
    }
  }
  
  var passwordEntry: Bool = false {
    didSet {
      textField.isSecureTextEntry = passwordEntry
      if passwordEntry {
        accessoryButton.isHidden = false
      }
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    setupUI()
    accessoryButton.addTarget(self, action: #selector(accessoryButtonPressed), for: .touchUpInside)
    textField.addTarget(self, action: #selector(textFieldValueChanged(_:)), for: .editingChanged)
    textField.addTarget(self, action: #selector(textFieldDidEnd(_:)), for: .editingDidEnd)
    textField.addTarget(self, action: #selector(textFieldDidBegin(_:)), for: .editingDidBegin)
  }
  
  private func setupUI(){
    
    addSubview(textField)
    addSubview(accessoryButton)
    
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
    textField.trailingAnchor.constraint(equalTo: accessoryButton.leadingAnchor).isActive = true
    textField.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
    textField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -3).isActive = true
    
    accessoryButton.translatesAutoresizingMaskIntoConstraints = false
    accessoryButton.widthAnchor.constraint(equalToConstant: 40.0).isActive = true
    accessoryButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -8).isActive = true
    accessoryButton.topAnchor.constraint(equalTo: topAnchor).isActive = true
    accessoryButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    
    accessoryButton.isHidden = true
    backgroundColor = .clear
    textFieldState = .normal
  }
  
  @objc private func textFieldDidEnd(_ textField: UITextField){
    if passwordEntry {
      
    }
    else {
      self.accessoryButton.isHidden = true
    }
  }
  
  @objc private func textFieldDidBegin(_ textField: UITextField){
    if passwordEntry {
      
    }
    else {
      self.accessoryButton.isHidden = textField.text!.isEmpty
    }
  }
  
  @objc private func textFieldValueChanged(_ textField: UITextField){
    //onValueChange?(self)
    if passwordEntry {
      accessoryButton.isHidden = false
    } else {
     accessoryButton.isHidden = textField.text!.isEmpty
    }
  }
  
  @objc private func accessoryButtonPressed() {
    if passwordEntry {
      textField.isSecureTextEntry.toggle()
    } else {
     textField.text = ""
    }
  }
  
  enum State {
    case normal
    case focused
  }
  
  var textFieldState: State = .normal {
    didSet {
      switch textFieldState {
      case .normal:
        removeExternalBorders()
      case .focused:
        addExternalBorder(borderWidth: 2, borderColor: #colorLiteral(red: 0, green: 0.3450980392, blue: 0.4, alpha: 1))
      }
    }
  }
  
  
  
}

//extension KTTextField: UITextFieldDelegate {
//
//  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//    textFieldState = .focused
//     return delegate?.kTTextFieldShouldBeginEditing(textField) ??  true
//  }
//
//  func textFieldDidBeginEditing(_ textField: UITextField) {
//    textFieldState = .focused
//    delegate?.kTTextFieldDidBeginEditing(textField)
//  }
//
//  func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
//    textFieldState = .normal
//     return delegate?.kTTextFieldShouldEndEditing(textField) ?? true
//  }
//
//  func textFieldDidEndEditing(_ textField: UITextField) {
//    textFieldState = .normal
//    delegate?.kTTextFieldDidEndEditing(textField)
//  }
//
//  func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
//    delegate?.kTTextFieldDidEndEditing(textField, reason: reason)
//  }
//
//  func textField(_ textField: UITextField,
//                 shouldChangeCharactersIn range: NSRange,
//                 replacementString string: String) -> Bool {
//
//    delegate?.kTTextField(textField, shouldChangeCharactersIn: range, replacementString: string) ?? true
//  }
//
//
//  func textFieldDidChangeSelection(_ textField: UITextField) {
//    delegate?.kTTextFieldDidChangeSelection(textField)
//  }
//
//  func textFieldShouldClear(_ textField: UITextField) -> Bool {
//     delegate?.kTTextFieldShouldClear(textField) ?? true
//  }
//
//  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//    delegate?.kTTextFieldShouldReturn(textField) ?? true
//  }
//
//}
