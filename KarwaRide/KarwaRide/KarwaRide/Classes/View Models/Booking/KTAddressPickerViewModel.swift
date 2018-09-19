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
    func moveFocusToDestination()
    func getConfirmPickupFlowDone() -> Bool
    func setConfirmPickupFlowDone(isConfirmPickupFlowDone : Bool)
    func startConfirmPickupFlow()
    func toggleConfirmBtn(enableBtn enable : Bool)
}

class KTAddressPickerViewModel: KTBaseViewModel {
    
    public var pickUpAddress : KTGeoLocation?
    public var dropOffAddress : KTGeoLocation?
    private var locations : [KTGeoLocation] = []
    private var bookmarks : [KTGeoLocation] = []
    private var nearBy : [KTGeoLocation] = []
    private var recent : [KTGeoLocation] = []
    private var popular : [KTGeoLocation] = []
    
    private var isSkippedPressed : Bool = false
    private var isLoadingAddress : Bool = false
    
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
        bookmarks = []
        let bookmarkManager : KTBookmarkManager = KTBookmarkManager()
        let home : KTBookmark? = bookmarkManager.getHome()
        let work : KTBookmark?  = bookmarkManager.getWork()
    
        if home != nil && home!.bookmarkToGeoLocation != nil {
            bookmarks.append(home!.bookmarkToGeoLocation!)
        }
        if work != nil && work!.bookmarkToGeoLocation != nil{
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
            else {
                let loc : KTGeoLocation = KTGeoLocation.mr_createEntity()!
                loc.locationId = -1
                loc.name = "Unknown"
                loc.latitude = Double(coordinate.latitude)
                loc.longitude = Double(coordinate.longitude)
                completion(loc)
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
    
    func MapStopMoving(location : CLLocationCoordinate2D)
    {
        isLoadingAddress = true
        (self.delegate as! KTAddressPickerViewModelDelegate).toggleConfirmBtn(enableBtn: false)
        setNameToSelectedField(name: "Loading...")

        fetchLocation(forGeoCoordinate: location , completion: {
            (reverseLocation) -> Void in

            if (self.delegate as! KTAddressPickerViewModelDelegate).inFocusTextField() == SelectedTextField.DropoffAddress
            {
                self.dropOffAddress  = reverseLocation
                self.setNameToSelectedField(name: reverseLocation.name!)
            }
            else
            {
                self.pickUpAddress = reverseLocation
                self.setNameToSelectedField(name: reverseLocation.name!)
            }
            
            (self.delegate as! KTAddressPickerViewModelDelegate).toggleConfirmBtn(enableBtn: true)
        })
    }
    
    func setNameToSelectedField(name nameStr: String)
    {
        if (self.delegate as! KTAddressPickerViewModelDelegate).inFocusTextField() == SelectedTextField.DropoffAddress
        {
            (self.delegate as! KTAddressPickerViewModelDelegate).setDropOff(drop: nameStr)
        }
        else
        {
            (self.delegate as! KTAddressPickerViewModelDelegate).setPickUp(pick: nameStr)
        }
    }
    
    //MARK: - TableView
    
    func numberOfRow(section : Int) -> Int {
        
        return locations.count
    }
    
    func addressTitle(forIndex idx: IndexPath) -> String {
        
        var title : String = ""
        if idx.row < locations.count  {
            if locations[idx.row].geolocationToBookmark != nil && locations[idx.row].geolocationToBookmark?.name != nil {
                title = (locations[idx.row].geolocationToBookmark?.name)!
            }
            else if locations[idx.row].name != nil {
                title = locations[idx.row].name!
            }
            
            //title = locations[idx.row].name!
        }
        return title.capitalizingFirstLetter()
    }
    
    func addressArea(forIndex idx: IndexPath) -> String {
        
        var area : String = ""
        
        if locations[idx.row].geolocationToBookmark != nil && locations[idx.row].name != nil {
            area = locations[idx.row].name!
        }
        else if locations[idx.row].area != nil {
            area = locations[idx.row].area!
        }
        
        return area.capitalizingFirstLetter()
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

    private func moveBackIfNeeded(skipDestination : Bool)
    {
        if((delegate as! KTAddressPickerViewModelDelegate).getConfirmPickupFlowDone())
        {
            moveBackScreen(skipDestination: skipDestination)
        }
        else
        {
            // start pickup confirmation from map flow
            (self.delegate as! KTAddressPickerViewModelDelegate).startConfirmPickupFlow()
        }
    }
    
    private func moveBackScreen(skipDestination : Bool)
    {
        if pickUpAddress != nil  &&  !((delegate as! KTAddressPickerViewModelDelegate).pickUpTxt().isEmpty)
        {
            if  (skipDestination || dropOffAddress != nil || isSkippedPressed)
            {
                if pickUpAddress?.name == (delegate as! KTAddressPickerViewModelDelegate).pickUpTxt() && (isSkippedPressed || dropOffAddress?.name == (delegate as! KTAddressPickerViewModelDelegate).dropOffTxt())
                {
                    if isSkippedPressed
                    {
                        dropOffAddress = nil
                    }
                    (delegate as! KTAddressPickerViewModelDelegate).navigateToPreviousView(pickup: pickUpAddress, dropOff: dropOffAddress)
                }
            }
            else
            {
                //self.delegate?.showError!(title: "Error", message: "Dropoff address cann't be empty")
                self.del?.moveFocusToDestination()
            }
        }
        else
        {
            self.delegate?.showError!(title: "Error", message: "Pickup address cann't be empty")
        }
    }
    
    public func skipDestination() {
        AnalyticsUtil.trackBehavior(event: "Drop-Off-Skipped")
        isSkippedPressed = true
        moveBackIfNeeded(skipDestination:true)
    }
    public func confimMapSelection()
    {
        moveBackIfNeeded(skipDestination:false)
    }
    
    
    //MARK: - Save/Update Bookmark
    func setHome(forIndex idx: Int) {
        let location : KTGeoLocation = locations[idx]
        saveBookmark(bookmarkType: BookmarkType.home, location: location)
        
    }
    
    func setWork(forIndex idx: Int) {
        let location : KTGeoLocation = locations[idx]
        saveBookmark(bookmarkType: BookmarkType.work, location: location)
        
    }
    
    func btnSetHomeTapped() {
        var location : KTGeoLocation? = dropOffAddress
        if del?.inFocusTextField() == SelectedTextField.PickupAddress {
            location = pickUpAddress
        }
        
        saveBookmark(bookmarkType: BookmarkType.home, location: location!)
    }
    
    func btnSetWorkTapped() {
        var location : KTGeoLocation? = dropOffAddress
        if del?.inFocusTextField() == SelectedTextField.PickupAddress {
            location = pickUpAddress
        }
        
        
        saveBookmark(bookmarkType: BookmarkType.work, location: location!)
    }
    
    func saveBookmark(bookmarkType: BookmarkType, location: KTGeoLocation) {
        
        if location.locationId != -1 {
            
            let error : String? = checkLocationIfAlreadyBookmark(location : location)
            if error != nil {
                
                delegate?.showError!(title: "Error", message: error!)
            }
            else
            {
                if bookmarkType == BookmarkType.home {
                    delegate?.showProgressHud(show: true, status: "Setting Home address")
                    KTBookmarkManager().updateHome(withLocation: location) { (status, response) in
                        
                        self.handleUpdateResponse(status: status,response: response)
                    }
                }
                else {
                    delegate?.showProgressHud(show: true, status: "Setting Work address")
                    KTBookmarkManager().updateWork(withLocation: location) { (status, response) in
                        
                        self.handleUpdateResponse(status: status,response: response)
                    }
                }
            }
        }
        else {
            if bookmarkType == BookmarkType.home {
                delegate?.showProgressHud(show: true, status: "Setting Home address")
                KTBookmarkManager().updateHome(withCoordinate: CLLocationCoordinate2D(latitude: location.longitude,longitude: location.longitude), completion: { (status, response) in
                    self.handleUpdateResponse(status: status,response: response)
                    
                })
            }
            else {
                delegate?.showProgressHud(show: true, status: "Setting Work address")
                KTBookmarkManager().updateWork(withCoordinate: CLLocationCoordinate2D(latitude: location.longitude,longitude: location.longitude), completion: { (status, response) in
                    self.handleUpdateResponse(status: status,response: response)
                    
                })
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
    
    func removeHomeWorkFromRestOfTheList()  {
        //a.filter { $0 != "three" }
        nearBy = nearBy.filter {$0.type != geoLocationType.Home.rawValue && $0.type != geoLocationType.Work.rawValue }
    
        recent = recent.filter {$0.type != geoLocationType.Home.rawValue && $0.type != geoLocationType.Work.rawValue }
        popular = popular.filter {$0.type != geoLocationType.Home.rawValue && $0.type != geoLocationType.Work.rawValue }
    }
    
    func handleUpdateResponse(status : String, response:[AnyHashable:Any]) {
        self.delegate?.hideProgressHud()
        
        print(status)
        print(response)
        if status == Constants.APIResponseStatus.SUCCESS {
            delegate?.showTaskCompleted(withMessage: "Address saved successfully")
            updateHomeAndWorkIfAvailable()
            removeHomeWorkFromRestOfTheList()
            loadDataInView()
        }
        else {
            self.delegate?.showError!(title: response[Constants.ResponseAPIKey.Title] as! String, message: response[Constants.ResponseAPIKey.Message] as! String)
        }
    }
}
