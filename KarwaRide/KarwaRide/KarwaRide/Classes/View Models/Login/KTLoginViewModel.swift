//
//  KSLoginViewModel.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 7/3/17.
//  Copyright © 2017 Karwa. All rights reserved.
//

import UIKit

class KTLoginViewModel: KTBaseViewModel, KTViewModelDelegate {

    func loginBtnTapped()
    {
        KTDALManager.init().login(phone: "50569963", password: "d97efba289c7b62681731b0bd1ce4ae9") { (status, response) in
            print("Success")
        }
    }
    
    func viewDidLoad(completion:(Bool) -> Void)  {
        
        completion(KTUserManager.init().isUserLogin())
        
    }
    
}
