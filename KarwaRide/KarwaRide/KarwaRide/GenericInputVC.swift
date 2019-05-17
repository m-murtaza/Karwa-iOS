//
//  GenericInputVC
//  KarwaRide
//
//  Created by Sam Ash on 1/7/19.
//  Copyright © 2019 Karwa. All rights reserved.
//

import Foundation

import UIKit
import QuartzCore

let ALLOWED_INPUT_LENGTH : Int = 50

class GenericInputVC: PopupVC, UITextFieldDelegate {
    
    @IBOutlet weak var txtPickupHint: UITextField!
    @IBOutlet weak var btnClose : UIButton!
    @IBOutlet weak var btnConfirm : UIButton!
    @IBOutlet weak var header: UILabel!
    
    public var inputType = ""

    public weak var previousView : KTEditAccountViewController?
    public weak var paymentVC : KTPaymentViewController?
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(BookingConfermationPopupVC.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(BookingConfermationPopupVC.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        viewPopupUI.layer.cornerRadius = 18;
        viewPopupUI.layer.masksToBounds = true;
        //TODO: limit the input of hint
        btnClose.layer.borderWidth = 0.5
        btnClose.layer.borderColor = UIColor.lightGray.cgColor
        btnConfirm.layer.borderWidth = 0.5
        btnConfirm.layer.borderColor = UIColor.lightGray.cgColor
        
        txtPickupHint.becomeFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    @IBAction func btnBookedTapped(_ sender: Any)
    {
        if txtPickupHint.text != nil
        {
            if((txtPickupHint.text?.length)! > 1)
            {
                saveDataWithType(inputText: txtPickupHint.text!)
                hidePromoCodeDialog()
            }
            else
            {
                showMessage(header: "Error", message: "Please enter valid Email")
            }
        }
    }
    
    func saveDataWithType(inputText: String)
    {
        switch inputType {
        case "name":
            previousView?.saveName(inputText: inputText)
            break
        case "email":
            let trimmedEmail = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
            if(paymentVC != nil)
            {
                paymentVC?.saveEmail(inputText: trimmedEmail)
            }
            else if(previousView != nil)
            {
                previousView?.saveEmail(inputText: trimmedEmail)
            }
            break
        default:
            break;
        }
    }
    
    @IBAction func btnCancelTapped(_ sender: Any)
    {
        hidePromoCodeDialog()
    }
    
    func hidePromoCodeDialog()
    {
        self.hideViewWithAnimation()
    }
    
    //MARK:- TextField Delegate
    //Bug 2567 Fixed.
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == txtPickupHint {
            
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            
            let changedText = currentText.replacingCharacters(in: stringRange, with: string)
            
            return changedText.count <= ALLOWED_INPUT_LENGTH
        }
        return true
    }
}
