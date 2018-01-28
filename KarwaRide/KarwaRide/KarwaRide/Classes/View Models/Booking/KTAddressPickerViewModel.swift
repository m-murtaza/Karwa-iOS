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
        fetchLocations()
    }
    
    func getAllLocations() {
        locations  = KTBookingManager().allGeoLocations()!
        (delegate as! KTAddressPickerViewModelDelegate).loadData()
    }
    
    func fetchLocations()  {
        KTBookingManager().address(forLocation: (KTLocationManager.sharedInstance.currentLocation?.coordinate)!) { (status, response) in
            if status == Constants.APIResponseStatus.SUCCESS {
                //Success
                
                self.getAllLocations()
            }
            else {
                
                self.delegate?.showError!(title: response[Constants.ResponseAPIKey.Title] as! String, message: response[Constants.ResponseAPIKey.Message] as! String)
            }
        }
    }
    
    func fetchLocations(forSearch query:String) {
        KTBookingManager().address(forSearch: query) { (status, response) in
            print(response)
        }
    }
    
    func numberOfRow() -> Int {
        return locations.count
    }
    func addressTitle(forRow row: Int) -> String
    {
        return locations[row].name!
    }
}
