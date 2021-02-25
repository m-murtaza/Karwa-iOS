//
//  KTMainViewController.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 11/29/17.
//  Copyright © 2017 Karwa. All rights reserved.
//

import UIKit
import MagicalRecord

class KTMainViewController: KTBaseViewController, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var btnCreatAccount : UIButton!
    @IBOutlet weak var btnAlreadyHaveAccount : UIButton!
    @IBAction func btnSignUpBottom(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        viewModel = KTMainViewModel(del:self)
        super.viewDidLoad()
      btnCreatAccount.setTitle("txt_create_account".localized().uppercased(), for: .normal)
      btnCreatAccount.layer.cornerRadius = 30
        // Do any additional setup after loading the view.
        (viewModel as! KTMainViewModel).viewDidLoad { (navigate:Bool) in
            if navigate {
                self.performSegue(withIdentifier: "segueMainToBooking", sender: self)
                
            }
            else {
                DispatchQueue.main.async {
                    self.btnCreatAccount.isHidden = false
                    self.btnAlreadyHaveAccount.isHidden = false
                }
            }
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        
//        self.btnCreatAccount.isHidden = true
//        self.btnAlreadyHaveAccount.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "popOverSegue" {
            let popoverViewController = segue.destination
            popoverViewController.modalPresentationStyle = UIModalPresentationStyle.popover
            popoverViewController.popoverPresentationController!.delegate = self
            popoverViewController.preferredContentSize = CGSize(width: 150, height: 54)
        }
    }
    
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
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
