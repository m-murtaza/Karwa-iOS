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
        delegate?.userIntraction(enable: true)
    }
    
    func fetchLocations()  {
        
        delegate?.userIntraction(enable: false)
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
       
        delegate?.userIntraction(enable: false)
        KTBookingManager().address(forSearch: query) { (status, response) in
        
            self.locations = response[Constants.ResponseAPIKey.Data] as! [KTGeoLocation]
            (self.delegate as! KTAddressPickerViewModelDelegate).loadData()
            self.delegate?.userIntraction(enable: true)
        }
    }
    
    func numberOfRow() -> Int {
        print(locations.count)
        return locations.count
    }
    func addressTitle(forRow row: Int) -> String
    {
        return locations[row].name!
    }
}
