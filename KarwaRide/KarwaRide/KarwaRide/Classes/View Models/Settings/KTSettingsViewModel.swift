//
//  KTSettingsViewModel.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 2/27/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
protocol KTSettingsViewModelDelegate {
    func showLogoutConfirmAlt()
}
class KTSettingsViewModel: KTBaseViewModel {

    private var userInfo : KTUser?
    override func viewDidLoad() {
        userInfo = KTUserManager().fetchUser()
    }
    
    func userName() -> String {
        var name = ""
        if userInfo != nil && userInfo?.name != nil {
            name = (userInfo?.name)!
        }
        return name
    }
    
    func userPhone() -> String {
        var phone = ""
        if userInfo != nil && userInfo?.phone != nil {
            phone = (userInfo?.phone)!
        }
        return phone
    }
    
    func appVersion() -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        
        return "app version " + version! + " (" + build! + ")"
    }
    
    // Mark: - Logout
    func startLogoutProcess()  {
        (delegate as! KTSettingsViewModelDelegate).showLogoutConfirmAlt()
    }
    
    func logout() {
        KTUserManager().logout { (status, response) in
            print("Logout on server " + status)
            KTUserManager().removeUserData()
            self.showLogin()
            
        }
    }
    func showLogin()  {
        
        (UIApplication.shared.delegate as! AppDelegate).showLogin()
        /*var window : UIWindow = (UIApplication.shared.delegate as! AppDelegate).window!
        window = UIWindow(frame: UIScreen.main.bounds)
        
        
        let sBoard = UIStoryboard(name: "Main", bundle: nil)
        let contentView : UIViewController = sBoard.instantiateViewController(withIdentifier: "FirstViewController")
        let leftView : UIViewController = sBoard.instantiateViewController(withIdentifier: "LeftMenuViewController")
        
        let sideMeun : SSASideMenu = SSASideMenu(contentViewController: contentView, leftMenuViewController: leftView)
        
        
        
        
        
        window.rootViewController = sideMeun
        window.makeKeyAndVisible()*/
    }
}
