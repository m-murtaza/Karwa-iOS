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
            completion(login)
        }
        
       
        
    }
}
