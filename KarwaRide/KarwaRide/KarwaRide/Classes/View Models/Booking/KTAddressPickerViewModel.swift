//
//  KTPickDropSelectionViewModel.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 1/24/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
import CoreLocation

struct KTAddress {
    var name : String
    var address : String
    var location : CLLocationCoordinate2D
}

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
    private var bookmarks : [KTGeoLocation] = []
    private var nearBy : [KTGeoLocation] = []
    private var recent : [KTGeoLocation] = []
    private var popular : [KTGeoLocation] = []
    
    private var del : KTAddressPickerViewModelDelegate?
    
    
    //MARK: - View Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        del = (delegate as! KTAddressPickerViewModelDelegate)
        
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
                self.sortDataForDisplay(serverResponse: response[Constants.ResponseAPIKey.Data] as! [KTGeoLocation])
                self.loadDataInView()
            }
            else {
                
                self.delegate?.showError!(title: response[Constants.ResponseAPIKey.Title] as! String, message: response[Constants.ResponseAPIKey.Message] as! String)
                //self.delegate?.userIntraction(enable: true)
            }
            self.delegate?.hideProgressHud()
        }
    }
    
    //MARK:-  Sort and Manage data for Dispaly
    func sortDataForDisplay(serverResponse locs: [KTGeoLocation]){
        updateHomeAndWorkIfAvailable()
        nearBy = filterArray(ForLocationType: geoLocationType.Nearby , serverResponse: locs)
        recent = filterArray(ForLocationType: geoLocationType.Recent , serverResponse: locs)
        popular = filterArray(ForLocationType: geoLocationType.Popular , serverResponse: locs)
    }
    
    func updateHomeAndWorkIfAvailable() {
        let bookmarkManager : KTBookmarkManager = KTBookmarkManager()
        let home : KTBookmark? = bookmarkManager.getHome()
        let work : KTBookmark?  = bookmarkManager.getWork()
        
        if home != nil {
            bookmarks.append(home!.bookmarkToGeoLocation!)
        }
        if work != nil {
            bookmarks.append(work!.bookmarkToGeoLocation!)
        }
    }
    
    func filterArray(ForLocationType type : geoLocationType , serverResponse locs: [KTGeoLocation]) -> [KTGeoLocation]{
        
        let n : [KTGeoLocation]? = locs.filter  { (loc) -> Bool in
            return loc.type == type.rawValue
        }
        
        guard n != nil else {
            return []
        }
        return n!
    }
    
    func loadDataInView() {
        if del?.inFocusTextField() == SelectedTextField.PickupAddress {
            locations = bookmarks + nearBy
            del?.loadData()
        }
        else {
            locations = bookmarks + recent + popular
            del?.loadData()
        }
    }
    
    func txtFieldSelectionChanged()  {
        loadDataInView()
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
    
    //MARK: - Map
    
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
    
    //MARK: - TableView
    
    func numberOfRow(section : Int) -> Int {
        
        return locations.count
    }
    
    func addressTitle(forIndex idx: IndexPath) -> String {
        
        var title : String = ""
        if idx.row < locations.count && locations[idx.row].name != nil {
            title = locations[idx.row].name!
        }
        return title
    }
    
    func addressArea(forIndex idx: IndexPath) -> String {
        
        var area : String = ""
        //        if idx.section == 0 && bookmarks.count > 0 {
        //            if bookmarks[idx.row].bookmarkToGeoLocation != nil {
        //                area = (bookmarks[idx.row].bookmarkToGeoLocation?.area!)!
        //            }
        //            else {
        //                area = bookmarks[idx.row].address!
        //            }
        //        }
        //
        //        else {
        if idx.row < locations.count && locations[idx.row].area != nil {
            area = locations[idx.row].area!
        }
        //        }
        return area
    }
    
    func addressTypeIcon(forIndex idx: IndexPath) -> UIImage {
        var img : UIImage?
        
        if idx.row < locations.count  {
            switch locations[idx.row].type {
            case geoLocationType.Home.rawValue:
                img = UIImage(named: "APICHome")
                break
            case geoLocationType.Work.rawValue:
                img = UIImage(named: "APICWork")
                break
            case geoLocationType.Nearby.rawValue:
                img = UIImage(named: "ic_landmark")
                break
            case geoLocationType.Popular.rawValue:
                img = UIImage(named: "ic_landmark")
                break
            case geoLocationType.Recent.rawValue:
                img = UIImage(named: "ic_recent")
                break
            default:
                img = UIImage(named: "ic_landmark")
            }
        }

        return img!
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
        if pickUpAddress != nil  &&  !((delegate as! KTAddressPickerViewModelDelegate).pickUpTxt().isEmpty){
            if  (skipDestination || dropOffAddress != nil) {
                
                if pickUpAddress?.name == (delegate as! KTAddressPickerViewModelDelegate).pickUpTxt() && (skipDestination || dropOffAddress?.name == (delegate as! KTAddressPickerViewModelDelegate).dropOffTxt()) {
                    if skipDestination {
                        dropOffAddress = nil
                    }
                    (delegate as! KTAddressPickerViewModelDelegate).navigateToPreviousView(pickup: pickUpAddress, dropOff: dropOffAddress)
                }
            }
            else {
                self.delegate?.showError!(title: "Error", message: "Dropoff address cann't be empty")
            }
        }
        else {
            self.delegate?.showError!(title: "Error", message: "Pickup address cann't be empty")
        }
    }
    
    public func skipDestination() {
        
        moveBackIfNeeded(skipDestination:true)
    }
    public func confimMapSelection() {
        
        moveBackIfNeeded(skipDestination:false)
    }
}
