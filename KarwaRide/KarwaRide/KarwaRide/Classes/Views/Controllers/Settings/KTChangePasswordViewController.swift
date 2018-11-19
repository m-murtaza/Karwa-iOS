//
//  KTChangePasswordViewController.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 3/6/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
import Spring

class KTChangePasswordViewController: KTBaseViewController,KTChangePasswordViewModelDelegate, UITextFieldDelegate {

    @IBOutlet weak var txtOldPassword: UITextField!
    @IBOutlet weak var txtNewPassword: UITextField!
    @IBOutlet weak var txtReNewPassword: UITextField!
    @IBOutlet weak var btnSave: ButtonWithShadow!
    

    override func viewDidLoad() {
        viewModel = KTChangePasswordViewModel(del: self)
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        txtOldPassword.becomeFirstResponder()

        btnSave.isHidden = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(btnChangeTapped))
        
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
    @IBAction func btnChangeTapped(_ sender: Any) {
        (viewModel as! KTChangePasswordViewModel).btnChangePasswordTapped(oldPassword: txtOldPassword.text, password: txtNewPassword.text, rePassword: txtReNewPassword.text)
    }
    
    func showSuccessAltAndMoveBack() {
        let alertController = UIAlertController(title: "Password Updated", message: "Your Password is updated", preferredStyle: .alert)
        
        //let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
            self.navigationController?.popViewController(animated: true)
        }
        
        //alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        // Try to find next responder
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
        }
        // Do not add a line break
        return false
    }
    
}
