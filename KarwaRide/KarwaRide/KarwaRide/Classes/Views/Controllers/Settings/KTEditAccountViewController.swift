//
//  KTEditAccountViewController.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 3/6/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

class KTEditAccountViewController: KTBaseViewController, KTEditUserViewModelDelegate,UITextFieldDelegate {

    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPhone: UITextField!
    override func viewDidLoad() {
        viewModel = KTEditUserViewModel(del: self)
        
        super.viewDidLoad()
        txtName.becomeFirstResponder()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateFormWithUserInfo()
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

    @IBAction func btnSaveTapped(_ sender: Any) {
        
        txtName.resignFirstResponder()
        txtEmail.resignFirstResponder()
        (viewModel as! KTEditUserViewModel).btnSaveTapped(userName: txtName.text, userEmail: txtEmail.text)
    }
    
    private func updateFormWithUserInfo() {
    
        txtName.text = (viewModel as! KTEditUserViewModel).userName()
        txtEmail.text = (viewModel as! KTEditUserViewModel).userEmail()
        txtPhone.text = (viewModel as! KTEditUserViewModel).userPhone()
        txtPhone.isEnabled = false
    }
    
    func showSuccessAltAndMoveBack() {
        let alertController = UIAlertController(title: "Account Updated", message: "Your account information is updated", preferredStyle: .alert)
        
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
