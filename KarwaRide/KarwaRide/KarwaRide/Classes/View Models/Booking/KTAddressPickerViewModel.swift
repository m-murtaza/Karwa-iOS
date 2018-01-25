//
//  KTPickDropSelectionViewModel.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 1/24/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

protocol KTAddressPickerViewModelDelegate : KTViewModelDelegate {
    func loadData()
}


class KTAddressPickerViewModel: KTBaseViewModel {
    
    var locations : [KTGeoLocation] = []
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        KTBookingManager().addressForLocation(location: (KTLocationManager.sharedInstance.currentLocation?.coordinate)!) { (status, response) in
            if status == Constants.APIResponseStatus.SUCCESS {
                //Success
                self.getAllLocations()
            }
        }
    }
    
    func getAllLocations() {
        locations  = KTBookingManager().allGeoLocations()!
        (delegate as! KTAddressPickerViewModelDelegate).loadData()
    }
    
    func numberOfRow() -> Int {
        return locations.count
    }
    func addressTitle(forRow row: Int) -> String
    {
        return locations[row].name!
    }
}
