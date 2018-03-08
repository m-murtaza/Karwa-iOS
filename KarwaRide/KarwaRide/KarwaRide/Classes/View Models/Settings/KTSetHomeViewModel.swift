//
//  KTSetHomeViewModel.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 3/7/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
import CoreLocation
protocol KTSetHomeWorkViewModelDelegate {
    func typeOfBookmark() -> BookmarkType
    func UpdateUI(name bookmarkName:String, location: CLLocationCoordinate2D)
    
    func loadData()
}

class KTSetHomeWorkViewModel: KTBaseViewModel {

    var bookmark : KTBookmark?
    private var locations : [KTGeoLocation] = []
    
    override func viewDidLoad() {
        fetchBookmark()
        fetchLocations()
    }
    
    //MARK: - Bookmark
    func fetchBookmark(){
        KTBookmarkManager().fetchHomeWork { (status, response) in
            if status == Constants.APIResponseStatus.SUCCESS {
                
                if (self.delegate as! KTSetHomeWorkViewModelDelegate).typeOfBookmark() == BookmarkType.home {
                    self.bookmark = KTBookmarkManager().getHome()
                }
                else{
                    self.bookmark = KTBookmarkManager().getWork()
                }
                
                (self.delegate as! KTSetHomeWorkViewModelDelegate).UpdateUI(name: (self.bookmark?.address)!, location: CLLocationCoordinate2D(latitude: (self.bookmark?.latitude)!,longitude: (self.bookmark?.longitude)!))
            }
            else {
                self.delegate?.showError!(title: response[Constants.ResponseAPIKey.Title] as! String, message: response[Constants.ResponseAPIKey.Message] as! String)
            }
        }
    }
    
    //MARK: - Locaitons
    func getAllLocations() {
        
        locations  = KTBookingManager().allGeoLocations()!
        (delegate as! KTSetHomeWorkViewModelDelegate).loadData()
    }
    
    func fetchLocations()  {
        
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
//        if type == SelectedTextField.PickupAddress {
//            
//            pickUpAddress = locations[idx]
//            (delegate as! KTAddressPickerViewModelDelegate).setPickUp(pick: (pickUpAddress?.name)!)
//        }
//        else {
//            
//            dropOffAddress = locations[idx]
//            (delegate as! KTAddressPickerViewModelDelegate).setDropOff(drop: (dropOffAddress?.name)!)
//        }
//        
//        moveBackIfNeeded(skipDestination: false)
    }
}
