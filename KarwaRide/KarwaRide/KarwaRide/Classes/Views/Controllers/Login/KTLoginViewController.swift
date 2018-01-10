//
//  LoginViewController.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 7/3/17.
//  Copyright © 2017 Karwa. All rights reserved.
//

import UIKit
import MagicalRecord

class KTLoginViewController: KTBaseViewController, KTLoginViewModelDelegate {
    
    //MARK: - Properties
    @IBOutlet weak var txtPhoneNumber: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    
    let viewModel : KTLoginViewModel = KTLoginViewModel(del: self)
    
    //MARK: -View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //viewModel! = KTLoginViewModel(del:self)
        // Do any additional setup after loading the view.
        viewModel.delegate = self
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
        viewModel.loginBtnTapped()
    }
    
    //Mark: - View Model Delegate
    func phoneNumber() -> String {
        return txtPhoneNumber.text!
    }
    
    func password() -> String {
        return txtPassword.text!
    }
    
    func navigateToBooking()
    {
        self.performSegue(withIdentifier: "segueLoginToBooking", sender: self)
        
    }
    func showError(title:String, message:String)
    {
        let altError = UIAlertController(title: title,message: message,preferredStyle:UIAlertControllerStyle.alert)
        
        altError.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler:nil ))
        self.present(altError,animated: true, completion: nil)
    }
    
}
