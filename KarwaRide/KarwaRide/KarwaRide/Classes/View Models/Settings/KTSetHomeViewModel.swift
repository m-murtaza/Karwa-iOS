//
//  KTSetHomeViewModel.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 3/7/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
import CoreLocation
protocol KTSetHomeWorkViewModelDelegate : KTViewModelDelegate {
    func typeOfBookmark() -> BookmarkType
    func UpdateUI(name bookmarkName:String, location: CLLocationCoordinate2D)
    func UpdateAddressText(address add:String)
    func loadData()
    //func bmarkType() -> BookmarkType
    func showSuccessAltAndMoveBack()
}

class KTSetHomeWorkViewModel: KTBaseViewModel {

    var bookmark : KTBookmark?
    private var locations : [KTGeoLocation] = []
    private var location : KTGeoLocation?
    private var nearBy : [KTGeoLocation] = []
    private var recent : [KTGeoLocation] = []
    private var popular : [KTGeoLocation] = []
    
    private var del : KTSetHomeWorkViewModelDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        del = (delegate as! KTSetHomeWorkViewModelDelegate)
        
        
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
                
                if self.bookmark != nil {
                    (self.delegate as! KTSetHomeWorkViewModelDelegate).UpdateUI(name: (self.bookmark?.address)!, location: CLLocationCoordinate2D(latitude: (self.bookmark?.latitude)!,longitude: (self.bookmark?.longitude)!))
                }
                else {
                    (self.delegate as! KTSetHomeWorkViewModelDelegate).UpdateUI(name: "Select Address", location: KTLocationManager.sharedInstance.currentLocation.coordinate)
                }
            }
            else {
                self.delegate?.showError!(title: response[Constants.ResponseAPIKey.Title] as! String, message: response[Constants.ResponseAPIKey.Message] as! String)
            }
        }
    }
    
    //MARK: - Save/Update Bookmark
    func saveBookmark(location loc:CLLocationCoordinate2D) {
        if location != nil {
            
            updateBookmark(forLocation: location!)
        }
        else {
            updateBookmark(forCoordinate: loc)
        }
    }
    func updateBookmark(forCoordinate loc:CLLocationCoordinate2D) {
        if (delegate as! KTSetHomeWorkViewModelDelegate).typeOfBookmark() == BookmarkType.home {
            delegate?.showProgressHud(show: true, status: "Setting Home address")
            KTBookmarkManager().updateHome(withCoordinate: loc) { (status, response) in
                self.delegate?.hideProgressHud()
                self.handleUpdateResponse(status: status,response: response)
            }
        }
        else {
            delegate?.showProgressHud(show: true, status: "Setting Work address")
            KTBookmarkManager().updateWork(withCoordinate: loc) { (status, response) in
                self.delegate?.hideProgressHud()
                self.handleUpdateResponse(status: status,response: response)
            }
        }
    }
    
    func updateBookmark(forLocation  loc: KTGeoLocation) {
        
        let error : String? = checkLocationIfAlreadyBookmark(location : loc)
        if error != nil {
            
            delegate?.showError!(title: "Error", message: error!)
        }
        else
        {
            if (delegate as! KTSetHomeWorkViewModelDelegate).typeOfBookmark() == BookmarkType.home {
                delegate?.showProgressHud(show: true, status: "Setting Home address")
                KTBookmarkManager().updateHome(withLocation: loc) { (status, response) in
                    self.delegate?.hideProgressHud()
                    self.handleUpdateResponse(status: status,response: response)
                }
            }
            else {
                delegate?.showProgressHud(show: true, status: "Setting Work address")
                KTBookmarkManager().updateWork(withLocation: loc) { (status, response) in
                    self.delegate?.hideProgressHud()
                    self.handleUpdateResponse(status: status,response: response)
                }
            }
        }
    }
    
    func checkLocationIfAlreadyBookmark(location : KTGeoLocation) -> String?{
        var error : String? = nil
        if location.geolocationToBookmark != nil {
            error = "This location is already saved as \((location.geolocationToBookmark?.name)!)"
            
        }
        return error
    }
    
    //MARK: - Locaitons
    
    func MapStopMoving(location loc : CLLocationCoordinate2D) {
        fetchLocation(forGeoCoordinate: loc , completion: {
            (reverseLocation) -> Void in
            
            if reverseLocation != nil {
                (self.delegate as! KTSetHomeWorkViewModelDelegate).UpdateAddressText(address: (reverseLocation?.name!)!)
                self.location = reverseLocation
                
            }
            else {
                //let str : String = String(format: "%.3f - %.3f",loc.longitude,loc.longitude)
                (self.delegate as! KTSetHomeWorkViewModelDelegate).UpdateAddressText(address: String(format: "Unknown",loc.latitude,loc.longitude))
                self.location = nil
            }
        })
    }
    
    private func fetchLocation(forGeoCoordinate coordinate: CLLocationCoordinate2D, completion: @escaping (_ location:KTGeoLocation?) -> Void) {
        
        KTBookingManager().address(forLocation: coordinate, Limit: 1) { (status, response) in
            if status == Constants.APIResponseStatus.SUCCESS && response[Constants.ResponseAPIKey.Data] != nil && (response[Constants.ResponseAPIKey.Data] as! [KTGeoLocation]).count > 0{
                
                completion((response[Constants.ResponseAPIKey.Data] as! [KTGeoLocation])[0])
            }
            else {
                
                completion(nil)
            }
        }
    }
    
    func fetchLocations(forSearch query:String) {
        
        //delegate?.userIntraction(enable: false)
        delegate?.showProgressHud(show: true, status: "Searching Location")
        KTBookingManager().address(forSearch: query) { (status, response) in
            
            if status == Constants.APIResponseStatus.SUCCESS {
                self.locations = response[Constants.ResponseAPIKey.Data] as! [KTGeoLocation]
                (self.delegate as! KTSetHomeWorkViewModelDelegate).loadData()
                //self.delegate?.userIntraction(enable: true)
                self.delegate?.hideProgressHud()
            }
                
            else {
                
                self.delegate?.showError!(title: response[Constants.ResponseAPIKey.Title] as! String, message: response[Constants.ResponseAPIKey.Message] as! String)
                self.delegate?.hideProgressHud()
            }
        }
    }
    
    func currentLocation() -> CLLocationCoordinate2D {
        return KTLocationManager.sharedInstance.currentLocation.coordinate
    }
    func getAllLocations() {
        
        locations  = KTBookingManager().allGeoLocations()!
        (delegate as! KTSetHomeWorkViewModelDelegate).loadData()
    }
    
    func fetchLocations()  {
        
        delegate?.showProgressHud(show: true, status: "str_loading".localized())
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
    
    func sortDataForDisplay(serverResponse locs: [KTGeoLocation]){
        
        nearBy = filterArray(ForLocationType: geoLocationType.Nearby , serverResponse: locs)
        recent = filterArray(ForLocationType: geoLocationType.Recent , serverResponse: locs)
        popular = filterArray(ForLocationType: geoLocationType.Popular , serverResponse: locs)
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
        
            locations =  nearBy + recent + popular
            del?.loadData()
        
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
    
    func didSelectRow(at idx:Int) {
        let loc : KTGeoLocation  = locations[idx]
        
        (delegate as! KTSetHomeWorkViewModelDelegate).UpdateAddressText(address: (loc.name)!)
        updateBookmark(forLocation: loc)
    }
    
    func handleUpdateResponse(status : String, response:[AnyHashable:Any]) {
        if status == Constants.APIResponseStatus.SUCCESS {
            (delegate as! KTSetHomeWorkViewModelDelegate).showSuccessAltAndMoveBack()
        }
        else {
            self.delegate?.showError!(title: response[Constants.ResponseAPIKey.Title] as! String, message: response[Constants.ResponseAPIKey.Message] as! String)
        }
    }
}
