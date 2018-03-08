//
//  KTPickDropSelectionViewModel.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 1/24/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
import CoreLocation

protocol KTAddressPickerViewModelDelegate : KTViewModelDelegate {
    func loadData()
    func pickUpTxt() -> String
    func dropOffTxt() -> String
    func setPickUp(pick: String)
    func setDropOff(drop: String)
    func navigateToPreviousView(pickup: KTGeoLocation?, dropOff:KTGeoLocation?)
    func inFocusTextField() -> SelectedTextField 
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
        if pickUpAddress != nil {
            (delegate as! KTAddressPickerViewModelDelegate).setPickUp(pick: (pickUpAddress?.name)!)
        }
        
        if dropOffAddress != nil{
            (delegate as! KTAddressPickerViewModelDelegate).setDropOff(drop: (dropOffAddress?.name)!)
        }
    }
    
    //MARK: - Locations
    func currentLatitude() -> Double {
        return KTLocationManager.sharedInstance.currentLocation.coordinate.latitude
    }
    
    func currentLongitude() -> Double {
        return KTLocationManager.sharedInstance.currentLocation.coordinate.longitude
    }
    
    func currentLocation() -> CLLocationCoordinate2D {
        return KTLocationManager.sharedInstance.currentLocation.coordinate
    }
    
    func getAllLocations() {
        
        locations  = KTBookingManager().allGeoLocations()!
        (delegate as! KTAddressPickerViewModelDelegate).loadData()
        //delegate?.userIntraction(enable: true)
    }
    
    func fetchLocations()  {
        
        //delegate?.userIntraction(enable: false)
        delegate?.showProgressHud(show: true, status: "Fetching Locations")
        KTBookingManager().address(forLocation: KTLocationManager.sharedInstance.currentLocation.coordinate) { (status, response) in
            if status == Constants.APIResponseStatus.SUCCESS {
                //Success
                self.getAllLocations()
            }
            else {
                
                self.delegate?.showError!(title: response[Constants.ResponseAPIKey.Title] as! String, message: response[Constants.ResponseAPIKey.Message] as! String)
                //self.delegate?.userIntraction(enable: true)
            }
            self.delegate?.hideProgressHud()
        }
    }
    
    //Fetch single location
    private func fetchLocation(forGeoCoordinate coordinate: CLLocationCoordinate2D, completion: @escaping (_ location:KTGeoLocation) -> Void) {
        
        KTBookingManager().address(forLocation: coordinate, Limit: 1) { (status, response) in
            if status == Constants.APIResponseStatus.SUCCESS && response[Constants.ResponseAPIKey.Data] != nil && (response[Constants.ResponseAPIKey.Data] as! [KTGeoLocation]).count > 0{
                
                   completion((response[Constants.ResponseAPIKey.Data] as! [KTGeoLocation])[0])
            }
        }
    }
    
    func fetchLocations(forSearch query:String) {
       
        //delegate?.userIntraction(enable: false)
        delegate?.showProgressHud(show: true, status: "Searching Location")
        KTBookingManager().address(forSearch: query) { (status, response) in
        
            if status == Constants.APIResponseStatus.SUCCESS {
                self.locations = response[Constants.ResponseAPIKey.Data] as! [KTGeoLocation]
                (self.delegate as! KTAddressPickerViewModelDelegate).loadData()
                //self.delegate?.userIntraction(enable: true)
                self.delegate?.hideProgressHud()
            }
        
            else {
                
                self.delegate?.showError!(title: response[Constants.ResponseAPIKey.Title] as! String, message: response[Constants.ResponseAPIKey.Message] as! String)
                self.delegate?.hideProgressHud()
            }
        }
    }
    
    //MARK: - Map realted
    
    func MapStopMoving(location : CLLocationCoordinate2D) {
        fetchLocation(forGeoCoordinate: location , completion: {
            (reverseLocation) -> Void in
            
            if (self.delegate as! KTAddressPickerViewModelDelegate).inFocusTextField() == SelectedTextField.DropoffAddress {
                self.dropOffAddress  = reverseLocation
                (self.delegate as! KTAddressPickerViewModelDelegate).setDropOff(drop: reverseLocation.name!)
            }
            else {
                self.pickUpAddress = reverseLocation
                (self.delegate as! KTAddressPickerViewModelDelegate).setPickUp(pick: reverseLocation.name!)
            }
        })
    }
    
    //MARK: - TableView Related
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
    
    private func moveBackIfNeeded(skipDestination : Bool) {
        if pickUpAddress != nil && (skipDestination || dropOffAddress != nil) {
            
            if pickUpAddress?.name == (delegate as! KTAddressPickerViewModelDelegate).pickUpTxt() && (skipDestination || dropOffAddress?.name == (delegate as! KTAddressPickerViewModelDelegate).dropOffTxt()) {
                if skipDestination {
                    dropOffAddress = nil
                }
                (delegate as! KTAddressPickerViewModelDelegate).navigateToPreviousView(pickup: pickUpAddress, dropOff: dropOffAddress)
                
            }
        }
    }
    
    public func skipDestination() {
        
        moveBackIfNeeded(skipDestination:true)
    }
    public func confimMapSelection() {
        
        moveBackIfNeeded(skipDestination:false)
    }
}
