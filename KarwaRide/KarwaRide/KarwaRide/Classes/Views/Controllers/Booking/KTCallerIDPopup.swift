//
//  KTCallerIDPopup.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 5/20/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

class KTCallerIDPopup: PopupVC, UITextFieldDelegate {

    @IBOutlet weak var txtCallerId: UITextField!
    @IBOutlet weak var btnCancel : UIButton!
    @IBOutlet weak var btnOk : UIButton!
    public weak var previousView : KTCreateBookingViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(BookingConfermationPopupVC.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(BookingConfermationPopupVC.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        viewPopupUI.layer.cornerRadius = 18;
        viewPopupUI.layer.masksToBounds = true;
        btnCancel.layer.borderWidth = 0.5
        btnCancel.layer.borderColor = UIColor.lightGray.cgColor
        btnOk.layer.borderWidth = 0.5
        btnOk.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        txtCallerId.becomeFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height/2
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height/2
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func btnOkTapped(_ sender: Any) {
        
        let error = validate()
        if error != nil {
            let alertController = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "ok".localized(), style: .default) { (UIAlertAction) in
                self.txtCallerId.becomeFirstResponder()
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else {
            if txtCallerId.text != nil && txtCallerId.text != "" {
                previousView?.callerId = txtCallerId.text!
            }
            previousView?.bookRide()
            self.hideViewWithAnimation()
        }
    }
    
    @IBAction func btnCancelTapped(_ sender: Any) {
        self.hideViewWithAnimation()
    }

    func validate() -> String? {
        
        var error : String?
        if txtCallerId.text != nil && txtCallerId.text != "" && !(txtCallerId.text?.isPhoneNumber)! {
            // User can leave it empty, so no validation error for nil and ""
            error = "Please insert valid phone number"
        }
        return error
    }
    
    //MARK:- TextField Delegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == txtCallerId {
            
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            
            let changedText = currentText.replacingCharacters(in: stringRange, with: string)
            
            return changedText.count <= ALLOWED_NUM_PHONE_CHAR
        }
        return true
    }
}
