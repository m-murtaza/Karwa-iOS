//
//  KTPickDropSelectionViewModel.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 1/24/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit



class KTAddressPickerViewModel: KTBaseViewModel {
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        KTBookingManager().addressForLocation(location: (KTLocationManager.sharedInstance.currentLocation?.coordinate)!) { (status, response) in
            print(response)
        }
    }
}
