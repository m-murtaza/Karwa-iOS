//
//  LoginViewController.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 7/3/17.
//  Copyright © 2017 Karwa. All rights reserved.
//

import UIKit

class KSLoginViewController: KSBaseViewController {

    //MARK: - Properties
    
    @IBOutlet weak var lblDeviceToken: UILabel!
    
    
    let viewModel : KSLoginViewModel = KSLoginViewModel(del: self)
    
    //MARK: -View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //var abc : UITableView
        //viewModel.delegate = self
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
    
    @IBAction func dismissView(_ sender: UIBarButtonItem) {
        navigationController?.dismiss(animated: true)
    }
    
    
    @IBAction func loginBtnTapped(_ sender: Any)
    {
        //self.viewModel.loginBtnTapped()
        //let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //lblDeviceToken.text = appDelegate.token
    }

}
