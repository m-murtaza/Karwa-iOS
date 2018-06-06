//
//  KTFirstViewModel.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 5/13/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

protocol KTFirstViewModelDelegate: KTViewModelDelegate {
    
    func userLogin(isLogin: Bool)
}

class KTFirstViewModel: KTBaseViewModel {
    
    var del : KTFirstViewModelDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        del = self.delegate as? KTFirstViewModelDelegate
        KTUserManager.init().isUserLogin { (login:Bool) in
            
            if login == true {
                //User is login throw a notification so that others can update thenself. like side menu.
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.Notification.UserLogin), object: nil)
            }
            self.del?.userLogin(isLogin: login)
        }
    }
}
