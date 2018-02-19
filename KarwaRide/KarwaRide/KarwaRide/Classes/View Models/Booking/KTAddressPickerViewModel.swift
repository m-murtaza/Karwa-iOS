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
    func pickUpTxt() -> String
    func dropOffTxt() -> String
    func setPickUp(pick: String)
    func setDropOff(drop: String)
    func navigateToPreviousView(pickup: KTGeoLocation?, dropOff:KTGeoLocation?)
}


class KTAddressPickerViewModel: KTBaseViewModel {
    
    public var pickUpAddress : KTGeoLocation?
    public var dropOffAddress : KTGeoLocation?
    
    private var locations : [KTGeoLocation] = []
    
    //MARK: - View Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        fetchLocations()
    }
    override func viewWillAppear() {
        (delegate as! KTAddressPickerViewModelDelegate).setPickUp(pick: (pickUpAddress?.name)!)
    }
    
    //MARK: - Locations
    func currentLatitude() -> Double {
        return KTLocationManager.sharedInstance.currentLocation.coordinate.latitude
    }
    
    func currentLongitude() -> Double {
        return KTLocationManager.sharedInstance.currentLocation.coordinate.longitude
    }
    
    func getAllLocations() {
        
        locations  = KTBookingManager().allGeoLocations()!
        (delegate as! KTAddressPickerViewModelDelegate).loadData()
        delegate?.userIntraction(enable: true)
    }
    
    func fetchLocations()  {
        
        delegate?.userIntraction(enable: false)
        KTBookingManager().address(forLocation: KTLocationManager.sharedInstance.currentLocation.coordinate) { (status, response) in
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
    func addressTitle(forRow row: Int) -> String {
        var title : String = ""
        if row < locations.count-1 && locations[row].name != nil {
            title = locations[row].name!
        }
        return title
    }
    
    func addressArea(forRow row: Int) -> String {
        
        var area : String = ""
        if row < locations.count-1 && locations[row].area != nil {
            area = locations[row].area!
        }
        return area
    }
    
    func didSelectRow(at idx:Int, type:SelectedTextField) {
        if type == SelectedTextField.PickupAddress {
            
            pickUpAddress = locations[idx]
            (delegate as! KTAddressPickerViewModelDelegate).setPickUp(pick: (pickUpAddress?.name)!)
        }
        else {
            
            dropOffAddress = locations[idx]
            (delegate as! KTAddressPickerViewModelDelegate).setDropOff(drop: (dropOffAddress?.name)!)
        }
        
        moveBackIfNeeded(skipDestination: false)
    }
    
//    private func moveBackIfNeeded() {
//        if pickUpAddress != nil && dropOffAddress != nil {
//
//            if pickUpAddress?.name == (delegate as! KTAddressPickerViewModelDelegate).pickUpTxt() && dropOffAddress?.name == (delegate as! KTAddressPickerViewModelDelegate).dropOffTxt() {
//
//                (delegate as! KTAddressPickerViewModelDelegate).navigateToPreviousView(pickup: pickUpAddress, dropOff: dropOffAddress)
//            }
//        }
//    }
    
    private func moveBackIfNeeded(skipDestination : Bool) {
        if pickUpAddress != nil && (skipDestination || dropOffAddress != nil) {
            
            if pickUpAddress?.name == (delegate as! KTAddressPickerViewModelDelegate).pickUpTxt() && (skipDestination || dropOffAddress?.name == (delegate as! KTAddressPickerViewModelDelegate).dropOffTxt()) {
                    (delegate as! KTAddressPickerViewModelDelegate).navigateToPreviousView(pickup: pickUpAddress, dropOff: dropOffAddress)
                
            }
        }
    }
    
    func skipDestination() {
        
        moveBackIfNeeded(skipDestination:true)
    }
}
