//
//  KTMainViewController.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 11/29/17.
//  Copyright © 2017 Karwa. All rights reserved.
//

import UIKit
import MagicalRecord

class KTMainViewController: KTBaseViewController {

    let viewModel : KTMainViewModel = KTMainViewModel(del: self)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        viewModel.viewDidLoad { (navigate:Bool) in
            if navigate {
                self.performSegue(withIdentifier: "segueMainToBooking", sender: self)
            }
        }
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
    /*@IBAction func Fetch(_ sender: Any) {
        
        var users: [NSManagedObject]!
        users = KTUser.mr_findAll()
        let user = users[0] as! KTUser
        
        print(user.name!)
    }
    @IBAction func Delete(_ sender: Any) {
        MagicalRecord.save({(_ localContext: NSManagedObjectContext) -> Void in
            _ = KTUser.mr_truncateAll(in: localContext)
            
        })
    }*/
    
}
