//
//  KTTextField.swift
//  KarwaRide
//
//  Created by Umer Afzal on 26/10/2020.
//  Copyright © 2020 Karwa. All rights reserved.
//

import Foundation
import SkyFloatingLabelTextField


//protocol KTTextFieldDelegate : NSObjectProtocol {
//
//    func kTTextFieldShouldBeginEditing(_ textField: UITextField) -> Bool // return NO to disallow editing.
//
//    func kTTextFieldDidBeginEditing(_ textField: UITextField) // became first responder
//
//    func kTTextFieldShouldEndEditing(_ textField: UITextField) -> Bool // return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
//
//    func kTTextFieldDidEndEditing(_ textField: UITextField) // may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
//
//    func kTTextFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) // if implemented, called in place of textFieldDidEndEditing:
//
//    func kTTextField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool // return NO to not change text
//
//    func kTTextFieldDidChangeSelection(_ textField: UITextField)
//
//    func kTTextFieldShouldClear(_ textField: UITextField) -> Bool // called when clear button pressed. return NO to ignore (no notifications)
//
//    func kTTextFieldShouldReturn(_ textField: UITextField) -> Bool // called when 'return' key pressed. return NO to ignore.
//}

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
    textField.placeholderFont = UIFont(name: "MuseoSans-500", size: 15.0)!
    textField.tintColor = #colorLiteral(red: 0, green: 0.3450980392, blue: 0.4, alpha: 1)
    textField.selectedTitleColor = #colorLiteral(red: 0, green: 0.3450980392, blue: 0.4, alpha: 1)
    textField.font = UIFont(name: "MuseoSans-500", size: 15.0)!
    textField.autocorrectionType = .no
    return textField
  }()
  
//  let lineSeparator: UIView = {
//    let view = UIView()
//    view.backgroundColor = .lightGray
//    return view
//  }()
  
  //weak var delegate: KTTextFieldDelegate?
  
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
  
  override func awakeFromNib() {
    super.awakeFromNib()
    setupUI()
    textField.addTarget(self, action: #selector(textFieldValueChanged(_:)), for: .editingChanged)
  }
  
  private func setupUI(){
    
    addSubview(textField)
    //addSubview(lineSeparator)
    
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
    textField.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
    textField.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
    textField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -3).isActive = true
    
//    lineSeparator.translatesAutoresizingMaskIntoConstraints = false
//    lineSeparator.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
//    lineSeparator.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
//    lineSeparator.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
//    lineSeparator.heightAnchor.constraint(equalToConstant: 1).isActive = true
    
    backgroundColor = .clear
    textFieldState = .normal
  }
  
  @objc private func textFieldValueChanged(_ textField: UITextField){
    onValueChange?(self)
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
//        self.layer.cornerRadius = 0
//        self.layer.borderColor = UIColor.clear.cgColor
//        self.layer.borderWidth = 0
      case .focused:
        addExternalBorder(borderWidth: 4, borderColor: #colorLiteral(red: 0, green: 0.3450980392, blue: 0.4, alpha: 1))
//        self.layer.cornerRadius = 10
//        self.layer.borderColor = #colorLiteral(red: 0, green: 0.3450980392, blue: 0.4, alpha: 1)
//        self.layer.borderWidth = 4
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
