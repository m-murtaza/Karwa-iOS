//
//  LoginViewController.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 7/3/17.
//  Copyright © 2017 Karwa. All rights reserved.
//

import UIKit
import MagicalRecord

class KTLoginViewController: KTBaseViewController {

    //MARK: - Properties
    
    @IBOutlet weak var lblDeviceToken: UILabel!
    
    
    let viewModel : KTLoginViewModel = KTLoginViewModel(del: self)
    
    //MARK: -View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        viewModel.viewDidLoad { (navigate:Bool) in
            if navigate {
                print("naigate")
            }
            else
            {
                print("")
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
    
    @IBAction func dismissView(_ sender: UIBarButtonItem) {
        navigationController?.dismiss(animated: true)
    }
    
    
    @IBAction func Insert(_ sender: Any) {
        
        let user : KTUser = KTUser.mr_createEntity()!
        user.customerType = 1
        user.name = "Usman"
        user.phone = "+974 50569963"
        user.email = "ualeem@faad.com"
        
        //let ctx : NSManagedObjectContext = NSManagedObjectContext.mr_default()
        
        MagicalRecord.save({ (localContext : NSManagedObjectContext!) in
            // This block runs in background thread
            print("SAVED")
        })
    }
    
    @IBAction func loginBtnTapped(_ sender: Any)
    {
        
        let user : KTUser = KTUser.mr_createEntity()!
        user.customerType = 1
        user.name = "Usman"
        user.phone = "+974 50569963"
        user.email = "ualeem@faad.com"
        
        //let ctx : NSManagedObjectContext = NSManagedObjectContext.mr_default()
        
        MagicalRecord.save({ (localContext : NSManagedObjectContext!) in
            // This block runs in background thread
            print("SAVED")
        })
        //self.viewModel.loginBtnTapped()
        //let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //lblDeviceToken.text = appDelegate.token
    }
    
    @IBAction func Fetch(_ sender: Any) {
        
        var users: [NSManagedObject]!
        users = KTUser.mr_findAll()
        let user = users[0] as! KTUser
        
        print(user.name!)
        
    }
    

}
