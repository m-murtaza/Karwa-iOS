//
//  KTXpressAddressPickerViewModel.swift
//  KarwaRide
//
//  Created by Apple on 28/06/21.
//  Copyright © 2021 Karwa. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

protocol KTXpressFavoriteDelegate {
    func savedFavorite()
}

protocol KTXpressAddressDelegate {
    func setLocation(location: Any)
    func setLocation(picklocation: Any?, dropLocation: Any?, destinationForPickUp: [Area]?)
}

extension KTXpressAddressDelegate {
    func setLocation(picklocation: Any?, dropLocation: Any?, destinationForPickUp: [Area]?) {

    }
}

protocol  KTXpressAddressPickerViewModelDelegate : KTViewModelDelegate {
  func loadData()
  func pickUpTxt() -> String
  func dropOffTxt() -> String
  func setPickUp(pick: String)
  func setDropOff(drop: String)
  func navigateToPreviousView(pickup: KTGeoLocation?, dropOff:KTGeoLocation?)
  func inFocusTextField() -> SelectedTextField
  func moveFocusToDestination()
  func moveFocusToPickUp()
  func getConfirmPickupFlowDone() -> Bool
  func setConfirmPickupFlowDone(isConfirmPickupFlowDone : Bool)
  func startConfirmPickupFlow()
  func toggleConfirmBtn(enableBtn enable : Bool)
  func navigateToFavoriteScreen(location: KTGeoLocation?)
}

class KTXpressAddressPickerViewModel: KTBaseViewModel {
  
  public var pickUpAddress : KTGeoLocation?
  public var dropOffAddress : KTGeoLocation?
  private var locations : [KTGeoLocation] = []
  var bookmarks : [KTGeoLocation] = []
  private var favorites : [KTGeoLocation] = []
  private var nearBy : [KTGeoLocation] = []
  private var recent : [KTGeoLocation] = []
  private var popular : [KTGeoLocation] = []
  
  private var isSkippedPressed : Bool = false
  private var isLoadingAddress : Bool = false
  
  private var del : KTXpressAddressPickerViewModelDelegate?
    
  var metroStations = [Area]()
  var favoriteMetroStation = [Area]()

  //MARK: - View Lifecycle
  
  override func viewDidLoad() {
    
    super.viewDidLoad()
        
    fetchLocations()
  }
  override func viewWillAppear() {
    if pickUpAddress != nil {
        (delegate as! KTXpressAddressPickerViewModelDelegate).setPickUp(pick: (pickUpAddress?.name) ?? "btn_favorites_title".localized())
    }
    
    if dropOffAddress != nil{
      (delegate as! KTXpressAddressPickerViewModelDelegate).setDropOff(drop: (dropOffAddress?.name) ?? "")
    }
    fetchLocations()
  }
  
  func pickupAddressClearedAction() {
    pickUpAddress = nil
  }
  
  func dropoffAddressClearedAction(){
    dropOffAddress = nil
  }
  
  func swapPickupAndDestination() -> Bool {
    let temporary = pickUpAddress
    pickUpAddress = dropOffAddress
    dropOffAddress = temporary
    return true
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
  
  func locationAtIndex(idx: Int) -> KTGeoLocation {
    locations[idx]
  }
    
  func locationAtIndexPath(indexPath: IndexPath) -> Any {
    if indexPath.section == 1 {
        if indexPath.row >= bookmarks.count && ((indexPath.row - bookmarks.count) >=  0) && ((indexPath.row - bookmarks.count) < favoriteMetroStation.count)  {
            return favoriteMetroStation[indexPath.row - bookmarks.count]
        } else {
            return bookmarks[indexPath.row]
        }
    } else if indexPath.section == 0 {
        return locations[indexPath.row]
    } else {
        return metroStations[indexPath.row]
    }
 }
  
  func getAllLocations() {
    
    locations  = KTBookingManager().allGeoLocations()!
    (delegate as! KTXpressAddressPickerViewModelDelegate).loadData()
    //delegate?.userIntraction(enable: true)
  }
  
  func fetchLocations()  {
    
    //delegate?.userIntraction(enable: false)
    delegate?.showProgressHud(show: true, status: "str_loading".localized())
    KTBookingManager().address(forLocation: KTLocationManager.sharedInstance.currentLocation.coordinate) { (status, response) in
      if status == Constants.APIResponseStatus.SUCCESS {
        //Success
        self.sortDataForDisplay(serverResponse: response[Constants.ResponseAPIKey.Data] as! [KTGeoLocation])
        self.loadDataInView()
      }
      else {
        let title = (response[Constants.ResponseAPIKey.Title] as? String) ?? "error_sr".localized()
        let message = (response[Constants.ResponseAPIKey.Message] as? String) ?? "please_dialog_msg_went_wrong".localized()
        self.delegate?.showError!(title: title, message: message)
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
    bookmarks.removeAll()
    let bookmarkManager : KTBookmarkManager = KTBookmarkManager()
    let home : KTBookmark? = bookmarkManager.getHome()
    let work : KTBookmark?  = bookmarkManager.getWork()
    
    if home != nil && home!.bookmarkToGeoLocation != nil {
      bookmarks.append(home!.bookmarkToGeoLocation!)
    }
    if work != nil && work!.bookmarkToGeoLocation != nil{
      bookmarks.append(work!.bookmarkToGeoLocation!)
    }
        
    if let favorites = KTBookmarkManager().fetchAllFavorites() {
        favorites.forEach( { bookmarks.append( $0.toGeolocation() )})
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
  
  func loadFavoritesDataInView() {
    if let favorites = KTBookmarkManager().fetchAllFavorites() {
      locations.removeAll()
      favorites.forEach( { locations.append( $0.toGeolocation() )})
      (delegate as! KTXpressAddressPickerViewModelDelegate).loadData()
    }
  }
    
    
  func loadDataInView() {
    if (delegate as! KTXpressAddressPickerViewModelDelegate).inFocusTextField() == SelectedTextField.PickupAddress {
      locations =  recent + nearBy + popular
        (delegate as! KTXpressAddressPickerViewModelDelegate).loadData()
    }
    else {
      locations =  recent + popular + nearBy
        (delegate as! KTXpressAddressPickerViewModelDelegate).loadData()
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
    delegate?.showProgressHud(show: true, status: "str_searching".localized())
    KTBookingManager().address(forSearch: query) { (status, response) in
      
      if status == Constants.APIResponseStatus.SUCCESS {
        self.locations = response[Constants.ResponseAPIKey.Data] as! [KTGeoLocation]
        (self.delegate as! KTXpressAddressPickerViewModelDelegate).loadData()
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
    (self.delegate as! KTXpressAddressPickerViewModelDelegate).toggleConfirmBtn(enableBtn: false)
    setNameToSelectedField(name: "str_loading".localized())
    
    fetchLocation(forGeoCoordinate: location , completion: {
      (reverseLocation) -> Void in
      
      if (self.delegate as! KTXpressAddressPickerViewModelDelegate).inFocusTextField() == SelectedTextField.DropoffAddress
      {
        self.dropOffAddress  = reverseLocation
        self.setNameToSelectedField(name: reverseLocation.name!)
      }
      else
      {
        self.pickUpAddress = reverseLocation
        self.setNameToSelectedField(name: reverseLocation.name!)
      }
      
      (self.delegate as! KTXpressAddressPickerViewModelDelegate).toggleConfirmBtn(enableBtn: true)
    })
  }
  
  func setNameToSelectedField(name nameStr: String)
  {
    if (self.delegate as! KTXpressAddressPickerViewModelDelegate).inFocusTextField() == SelectedTextField.DropoffAddress
    {
      (self.delegate as! KTXpressAddressPickerViewModelDelegate).setDropOff(drop: nameStr)
    }
    else
    {
      (self.delegate as! KTXpressAddressPickerViewModelDelegate).setPickUp(pick: nameStr)
    }
  }
  
  //MARK: - TableView
  func numberOfRow(section : Int) -> Int {
    if section == 1 {
        return bookmarks.count + favoriteMetroStation.count
    } else if section == 0 {
        return locations.count
    } else {
        return metroStations.count
    }
  }
    
    func moreButtonIcon(forIndex idx: IndexPath) -> UIImage {
        if idx.section == 0 || idx.section == 1 {
            return #imageLiteral(resourceName: "APICMore") //UIImage(named: "APICMore")!
        } else {
            let addedFav = KTBookmarkManager().getXpressFavorite(code: metroStations[idx.row].code ?? 0)
            return addedFav ? #imageLiteral(resourceName: "Star_ico") : #imageLiteral(resourceName: "favorite_map_ico")
        }
    }
    
    func saveFavoriteMetroStations(metro: Area) {
        KTBookmarkManager().saveXpressFavorite(location: metro)
    }
    
    func deleteFavoriteStations(metro: Area) {
        KTBookmarkManager().deleteXpressFavorite(code: metro.code ?? -1)
    }
  
  func addressTitle(forIndex idx: IndexPath) -> String {
    
    if idx.section == 0 {
        var title : String = ""
        if idx.row < locations.count  {
          if locations[idx.row].geolocationToBookmark != nil && locations[idx.row].geolocationToBookmark?.name != nil {
            title = (locations[idx.row].geolocationToBookmark?.name)!
          }
          else if !locations[idx.row].favoriteName.isEmpty {
            title = locations[idx.row].favoriteName
          }
          else if locations[idx.row].name != nil {
            title = locations[idx.row].name!
          }
          //title = locations[idx.row].name!
        }
        return title.capitalizingFirstLetter()
    } else if idx.section == 1 {
        var title : String = ""
        if idx.row < bookmarks.count  {
          if bookmarks[idx.row].geolocationToBookmark != nil && bookmarks[idx.row].geolocationToBookmark?.name != nil {
            title = (bookmarks[idx.row].geolocationToBookmark?.name)!
          }
          else if !bookmarks[idx.row].favoriteName.isEmpty {
            title = bookmarks[idx.row].favoriteName
          }
          else if bookmarks[idx.row].name != nil {
            title = bookmarks[idx.row].name!
          }
        } else {
            if idx.row >= bookmarks.count && ((idx.row - bookmarks.count) >=  0) && ((idx.row - bookmarks.count) < favoriteMetroStation.count)  {
                title = favoriteMetroStation[idx.row - bookmarks.count].name ?? ""
            }
        }
        return title.capitalizingFirstLetter()
    }
    else  {
        var title : String = ""
        title = metroStations[idx.row].name ?? ""
        return title.capitalizingFirstLetter()
    }
    
  }
  
  func addressArea(forIndex idx: IndexPath) -> String {
    
    if idx.section == 0 {
        var area : String = ""
        
        if locations[idx.row].geolocationToBookmark != nil && locations[idx.row].name != nil {
          area = locations[idx.row].name!
        }
        else if locations[idx.row].area != nil {
          area = locations[idx.row].area!
        }
        
        return area.capitalizingFirstLetter()
    } else if idx.section == 1 {
        var area : String = ""
        
        if idx.row < bookmarks.count  {
            if bookmarks[idx.row].geolocationToBookmark != nil && bookmarks[idx.row].name != nil {
              area = bookmarks[idx.row].name!
            }
            else if bookmarks[idx.row].area != nil {
              area = bookmarks[idx.row].area!
            }
        } else {
            area = ""
        }
                
        return area.capitalizingFirstLetter()
    } else {
        return ""
    }
    
  }
  
  func addressTypeIcon(forIndex idx: IndexPath) -> UIImage {
    var img : UIImage?
    
    if idx.section == 0 {
        
        if idx.row < locations.count  {
          switch locations[idx.row].type {
          case geoLocationType.Home.rawValue:
            img = UIImage(named: "fav_home_ico")
            break
          case geoLocationType.Work.rawValue:
            img = UIImage(named: "fav_work_ico")
            break
          case geoLocationType.Nearby.rawValue:
            img = UIImage(named: "ic_recent")
            break
          case geoLocationType.Popular.rawValue:
            img = UIImage(named: "loc_ico")
            break
          case geoLocationType.Recent.rawValue:
            img = UIImage(named: "ic_recent")
            break
          case geoLocationType.favorite.rawValue:
            img = UIImage(named: "fav_star_ico")
            break
          default:
              img = UIImage(named: "loc_ico")
          }
        }
        return img!

    } else if idx.section == 1 {
        
        if idx.row < bookmarks.count  {
          switch bookmarks[idx.row].type {
          case geoLocationType.Home.rawValue:
            img = UIImage(named: "fav_home_ico")
            break
          case geoLocationType.Work.rawValue:
            img = UIImage(named: "fav_work_ico")
            break
          default:
            img = UIImage(named: "favorite_ico_xpress")
          }
        } else {
            img = UIImage(named: "metro_ico")
        }
        return img!

    } else {
        return #imageLiteral(resourceName: "metro_ico")
    }
    

    
  }
  
  func didSelectRow(at idx:Int, type:SelectedTextField) {
    if type == SelectedTextField.PickupAddress {
      pickUpAddress = locations[idx]
    
        if !locations[idx].favoriteName.isEmpty {
          let title = locations[idx].favoriteName
            (delegate as! KTXpressAddressPickerViewModelDelegate).setPickUp(pick: title)
        } else {
            let title = locations[idx].name!
              (delegate as! KTXpressAddressPickerViewModelDelegate).setPickUp(pick: title)
        }
        
    }
    else {
      dropOffAddress = locations[idx]
        
        if !locations[idx].favoriteName.isEmpty {
          let title = locations[idx].favoriteName
            (delegate as! KTXpressAddressPickerViewModelDelegate).setDropOff(drop: title)
        } else {
            let title = locations[idx].name!
            (delegate as! KTXpressAddressPickerViewModelDelegate).setDropOff(drop: title)
        }
        
    }
    
    moveBackIfNeeded(skipDestination: false)
  }
  
  private func moveBackIfNeeded(skipDestination : Bool)
  {
    //        if((delegate as! KTXpressAddressPickerViewModelDelegate).getConfirmPickupFlowDone())
    //        {
    //            moveBackScreen(skipDestination: skipDestination)
    //        }
    //        else
    //        {
    //            // start pickup confirmation from map flow
    //            (self.delegate as! KTXpressAddressPickerViewModelDelegate).startConfirmPickupFlow()
    //        }
    moveBackScreen(skipDestination: skipDestination)
  }
  
  private func moveBackScreen(skipDestination : Bool)
  {
    if pickUpAddress != nil  &&  !((delegate as! KTXpressAddressPickerViewModelDelegate).pickUpTxt().isEmpty)
    {
      if  (skipDestination || dropOffAddress != nil || isSkippedPressed)
      {
        if (pickUpAddress?.name == (delegate as! KTXpressAddressPickerViewModelDelegate).pickUpTxt() || pickUpAddress?.favoriteName == (delegate as! KTXpressAddressPickerViewModelDelegate).pickUpTxt()) && (isSkippedPressed || dropOffAddress?.name == (delegate as! KTXpressAddressPickerViewModelDelegate).dropOffTxt() || dropOffAddress?.favoriteName == (delegate as! KTXpressAddressPickerViewModelDelegate).dropOffTxt()  )
        {
          if isSkippedPressed
          {
            dropOffAddress = nil
          }
          (delegate as! KTXpressAddressPickerViewModelDelegate).navigateToPreviousView(pickup: pickUpAddress, dropOff: dropOffAddress)
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
        self.delegate?.showError!(title: "error_sr".localized(), message: "txt_pick_up".localized())
        self.del?.moveFocusToPickUp()
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
    
    func setHome(forIndex idxPath: IndexPath) {
        if idxPath.section == 0{
            let location : KTGeoLocation = locations[idxPath.row]
            saveBookmark(bookmarkType: BookmarkType.home, location: location)
        }
        if idxPath.section == 1{
            let location : KTGeoLocation = bookmarks[idxPath.row]
            saveBookmark(bookmarkType: BookmarkType.home, location: location)
        }
    }
    
    func setWork(forIndex idxPath: IndexPath) {
        if idxPath.section == 0{
            let location : KTGeoLocation = locations[idxPath.row]
            saveBookmark(bookmarkType: BookmarkType.work, location: location)
        }
        if idxPath.section == 1{
            let location : KTGeoLocation = bookmarks[idxPath.row]
            saveBookmark(bookmarkType: BookmarkType.work, location: location)
        }
    }
    
    func setFavorite(forIndex idxPath: IndexPath) {
        if idxPath.section == 0{
            let location : KTGeoLocation = locations[idxPath.row]
            (delegate as! KTXpressAddressPickerViewModelDelegate).navigateToFavoriteScreen(location: location)
        }
        if idxPath.section == 1{
            let location : KTGeoLocation = bookmarks[idxPath.row]
            (delegate as! KTXpressAddressPickerViewModelDelegate).navigateToFavoriteScreen(location: location)
        }
      
    }
    
//  func setHome(forIndex idx: Int) {
//    let location : KTGeoLocation = locations[idx]
//    saveBookmark(bookmarkType: BookmarkType.home, location: location)
//
//  }
//
//  func setWork(forIndex idx: Int) {
//    let location : KTGeoLocation = locations[idx]
//    saveBookmark(bookmarkType: BookmarkType.work, location: location)
//
//  }
  
  func setFavorite(forIndex idx: Int) {
    let location : KTGeoLocation = locations[idx]
    (delegate as! KTXpressAddressPickerViewModelDelegate).navigateToFavoriteScreen(location: location)
  }
  
  func editFavorite(forIndex idx: Int) {
    let location : KTGeoLocation = locations[idx]
    del?.navigateToFavoriteScreen(location: location)
  }
  
  func removeFavorite(forIndex idx: Int) {
    let location : KTGeoLocation = locations[idx]
    let predicate = NSPredicate(format: "locationId == %d", location.locationId)
    KTFavorites.mr_deleteAll(matching: predicate, in: NSManagedObjectContext.mr_default())
    loadFavoritesDataInView()
    NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
    delegate?.showToast(message: "txt_location_fav_removed".localized())
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
  
  func btnFavoriteTapped() {
    var location : KTGeoLocation? = dropOffAddress
    if del?.inFocusTextField() == SelectedTextField.PickupAddress {
      location = pickUpAddress
    }
    
    del?.navigateToFavoriteScreen(location: location)
  }
  
  func saveBookmark(bookmarkType: BookmarkType, location: KTGeoLocation) {
    
    if location.locationId != -1 {
      
      let error : String? = checkLocationIfAlreadyBookmark(location : location)
      if error != nil {
        
        delegate?.showError!(title: "error_sr".localized(), message: error!)
      }
      else
      {
        if bookmarkType == BookmarkType.home {
          delegate?.showProgressHud(show: true, status: "")
          KTBookmarkManager().updateHome(withLocation: location) { (status, response) in
            
            self.handleUpdateResponse(status: status,response: response)
          }
        }
        else {
          delegate?.showProgressHud(show: true, status: "")
          KTBookmarkManager().updateWork(withLocation: location) { (status, response) in
            
            self.handleUpdateResponse(status: status,response: response)
          }
        }
      }
    }
    else {
      if bookmarkType == BookmarkType.home {
        delegate?.showProgressHud(show: true, status: "")
        KTBookmarkManager().updateHome(withCoordinate: CLLocationCoordinate2D(latitude: location.longitude,longitude: location.longitude), completion: { (status, response) in
          self.handleUpdateResponse(status: status,response: response)
          
        })
      }
      else {
        delegate?.showProgressHud(show: true, status: "")
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
        delegate?.showTaskCompleted(withMessage: "address_saved_success".localized())
      updateHomeAndWorkIfAvailable()
      removeHomeWorkFromRestOfTheList()
      loadDataInView()
        self.fetchLocations()
    }
    else {
      self.delegate?.showError!(title: response[Constants.ResponseAPIKey.Title] as! String, message: response[Constants.ResponseAPIKey.Message] as! String)
    }
  }
}
