//
//  KTMainViewModel.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 11/29/17.
//  Copyright © 2017 Karwa. All rights reserved.
//

import UIKit

class KTMainViewModel: KTBaseViewModel {
    
    func viewDidLoad(completion: @escaping (Bool) -> Void)  {
        
        KTUserManager.init().isUserLogin { (login:Bool) in
            
            if login == true {
                //User is login throw a notification so that others can update thenself. like side menu.
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.Notification.UserLogin), object: nil)
            }
            completion(login)
        }
        
       
        
    }
}
