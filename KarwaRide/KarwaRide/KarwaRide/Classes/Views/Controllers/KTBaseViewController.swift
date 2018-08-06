//
//  KSBaseViewController.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 7/3/17.
//  Copyright © 2017 Karwa. All rights reserved.
//

import UIKit
import SVProgressHUD
import Spring
class KTBaseViewController: UIViewController,KTViewModelDelegate {
    
    var viewModel : KTBaseViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        viewModel?.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        viewModel?.viewWillAppear()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel?.viewDidAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        viewModel?.viewWillDisappear()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func showError(title:String, message:String)
    {
        let altError = UIAlertController(title: title,message: message,preferredStyle:UIAlertControllerStyle.alert)
        
        altError.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler:nil ))
        self.present(altError,animated: true, completion: nil)
    }
    
    func showProgressHud(show : Bool, status:String){
        if show {
            SVProgressHUD.show(withStatus: status)
            userIntraction(enable: false)
        }
        else {
            SVProgressHUD.dismiss()
            userIntraction(enable: true)
        }
        
    }
    func hideProgressHud() {
        
        showProgressHud(show: false)
    }
    
    func showProgressHud(show: Bool) {
        if show {
            SVProgressHUD.show();
            userIntraction(enable: false)
        }
        else {
            SVProgressHUD.dismiss()
            userIntraction(enable: true)
        }
    }
    
    func showTaskCompleted(withMessage msg: String) {
        SVProgressHUD.show(UIImage(named: "light-check-mark")!, status: msg)
        SVProgressHUD.dismiss(withDelay: 1.0)
    }
    
    func userIntraction(enable: Bool) {
        
        if enable {
            
            UIApplication.shared.endIgnoringInteractionEvents()
        }
        else {
            
            UIApplication.shared.beginIgnoringInteractionEvents()
        
        }
    }
    
    func viewStoryboard() -> UIStoryboard {
        return self.storyboard!
        
    }
    
    func dismiss()  {
        self.dismiss(animated: true, completion: nil)
    }
    
    func performSegue(name:String) {
        
        self.performSegue(withIdentifier: name, sender: self)
    }
    

    func isLargeScreen() -> Bool {
        var large : Bool = false
        let horizontalClass : UIUserInterfaceSizeClass = self.traitCollection.horizontalSizeClass
        let verticalCass : UIUserInterfaceSizeClass  = self.traitCollection.verticalSizeClass;
        
        if horizontalClass == .regular && verticalCass == .regular {
            large = true
        }
        return large
    }
    
    func springAnimateButtonTapIn(button btn : SpringButton)
    {
        UIView.animate(withDuration: 0.35,
                       animations: {
                        btn.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        })
    }
    
    func springAnimateButtonTapOut(button btn : SpringButton)
    {
        UIView.animate(withDuration: 0.35) {
            btn.transform = CGAffineTransform.identity
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

}
