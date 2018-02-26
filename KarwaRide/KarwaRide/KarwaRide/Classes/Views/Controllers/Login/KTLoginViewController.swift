//
//  LoginViewController.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 7/3/17.
//  Copyright © 2017 Karwa. All rights reserved.
//

import UIKit

class KTLoginViewController: KTBaseViewController, KTLoginViewModelDelegate {
    
    //MARK: - Properties
    @IBOutlet weak var txtPhoneNumber: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    //MARK: -View LifeCycle
    override func viewDidLoad() {
        viewModel = KTLoginViewModel(del:self)
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
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
    
    @IBAction func loginBtnTapped(_ sender: Any)
    {
        (viewModel as! KTLoginViewModel).loginBtnTapped()
    }
    
    @IBAction func btnBackTapped(_ sender:Any)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    //Mark: - View Model Delegate
    func phoneNumber() -> String {
        guard let _ =  txtPassword.text else {
            return ""
        }
        
        return txtPhoneNumber.text!
    }
    
    func password() -> String {
        guard let _ = txtPassword.text else {
            
            return ""
        }
        return txtPassword.text!
    }
    
    func navigateToBooking()
    {
        self.performSegue(withIdentifier: "segueLoginToBooking", sender: self)
    }
    func navigateToOTP() {
        self.performSegue(withIdentifier: "segueLoginToOTP", sender: self)
    }
    
    
}
