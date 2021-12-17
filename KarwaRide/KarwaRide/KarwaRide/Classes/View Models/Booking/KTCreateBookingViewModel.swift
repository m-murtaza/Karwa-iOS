//
//  KTCreateBookingViewModel.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 1/16/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftDate
import Alamofire
import SwiftyJSON
import GoogleMaps

protocol KTCreateBookingViewModelDelegate: KTViewModelDelegate
{
    func updateLocationInMap(location:CLLocation)
    func updateLocationInMap(location: CLLocation, shouldZoomToDefault withZoom : Bool)
    func addMarkerOnMap(vTrack:[VehicleTrack])
    func addOrRemoveOrMoveMarkerOnMap(vTrack:[VehicleTrack], vehicleType: Int16)
    func addMarkerOnMap(vTrack:[VehicleTrack], vehicleType: Int16)
    func hintForPickup() -> String
    func callerPhoneNumber() -> String?
    func setPickUp(pick: String?)
    func setDropOff(drop: String?)
    func setPickDate(date: String)
    func setRequestButtonTitle(title: String)
    func showBookingConfirmation()
    func showCallerIdPopUp()
    func showRequestBookingBtn()
    func hideRequestBookingBtn()
    func hidePickDropoffParentContainer()
    func hideRideServicesContainer()
    func showCancelBookingBtn()
    func hideCancelBookingBtn()
    func pickDropBoxStep3()
    func pickDropBoxStep1()
    //func updatePickDropBox()
    func setVehicleType(idx: Int)
    func addMarkerOnMap(location: CLLocationCoordinate2D, image: UIImage)
    func addAndGetMarkerOnMap(location: CLLocationCoordinate2D, image: UIImage) -> GMSMarker
    func focusMapToShowAllMarkers(gmsMarker : Array<GMSMarker>)
    func focusOnLocation(lat: Double, lon: Double)
    func addPointsOnMap(points : String)
    func clearMap()
    func showCurrentLocationDot(show : Bool)
    func moveToDetailView()
    func showAlertForLocationServerOn()
    func showFareBreakdown(animated: Bool,kvPair : [[String: String]],title:String )
    func updateFareBreakdown(kvPair : [[String: String]] )
    func hideFareBreakdown(animated : Bool)
    func fareDetailVisible() -> Bool
    func updateVehicleTypeList()
    func allowScrollVTypeCard(allow : Bool)
    func setETAContainerBackground(background : String)
    func setETAString(etaString : String)
    func hideFareBreakdown()
    func showPromoInputDialog(currentPromo : String)
    func setPromoButtonLabel(validPromo : String)
    func setPromotionCode(promo: String)
    func showPromotionAppliedToast(show: Bool)
    
    func showScanPayCoachmark()
    func reloadDestinations()
    func moveRow(from: IndexPath, to: IndexPath)
    func moveRowToFirst(fromIndex from: Int)
    func restoreCustomerServiceSelection()
    func restoreCustomerServiceSelection(animateView: Bool)
    func reloadSelection()
    
    func getPromotions(promotions: [PromotionModel])
    func rebookRide()
}

let CHECK_DELAY = 90.0
enum BookingStep {
    case step1
    case step2
    case step3
}

let UNKNOWN : String = "str_loading".localized()
let TIMER_INTERVAL = 4;
var isBaseFareChangedForPromo = false

class KTCreateBookingViewModel: KTBaseViewModel {
    
    var currentBookingStep : BookingStep = BookingStep.step1  //Booking will strat with step 1
    var vehicleTypes : [KTVehicleType]?
    var modifiedVehicleTypes : [KTVehicleType]?
    
    public var estimates : [KTFareEstimate]?
    var etas: [Any]?
    
    private var nearByVehicle: [VehicleTrack] = []
    
    var selectedPickupDateTime : Date = Date()
    var timerFetchNearbyVehicle : Timer?
    
    var del : KTCreateBookingViewModelDelegate?
    
    var booking : KTBooking = KTBookingManager().booking()
    var cloneBooking : BookingBean = BookingBean()
    
    var selectedVehicleType : VehicleType = VehicleType.KTCityTaxi
    var previousSelectedIndex = Int()
    var dropOffBtnText = "str_no_destination_set".localized()
    var promo = ""
    
    var rebook: Bool = false
    public var isEstimeting : Bool = false
    public var isCoachmarkOneShown: Bool = false
    var removeBooking = true
    var removeBookingOnReset = true
    var isAdvanceBooking = false
    
    var selectedPaymentMethodId = ""
    
    var encodedPath = ""
    var initialDateSetUp = true
    var carouselSelected = false
    
    var vehicleCategories: [String: [KTVehicleType]] = [:]
    var pickUpAddressGeoLocation: KTGeoLocation?
    var dropOffAddressGeoLocation: KTGeoLocation?

    override func viewDidLoad() {
        
        super.viewDidLoad()
        del = self.delegate as? KTCreateBookingViewModelDelegate
        
        self.syncApplicationData()
        vehicleTypes = KTVehicleTypeManager().VehicleTypes()
        self.setupVehicleCategories()
        self.modifiedVehicleTypes = KTVehicleTypeManager().VehicleTypes()
        del?.pickDropBoxStep1()
        del?.hideRequestBookingBtn()
        del?.hidePickDropoffParentContainer()
        del?.hideRideServicesContainer()
        
        if booking.bookingId != nil && booking.bookingId != "" {
            rebook = true
            updateForRebook()
            PreviousSelectedPayment.shared.rebook = true
            PreviousSelectedPayment.shared.selectedPaymentMethod = nil
        } else {
            PreviousSelectedPayment.shared.rebook = false
        }
        
        resetPromo()
        resetPromoOrBaseFare()
    }
    
    override func viewWillAppear() {
        removeBooking = true
        setupCurrentLocaiton()
        
        super.viewWillAppear()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.LocationManagerLocaitonUpdate(notification:)), name: Notification.Name(Constants.Notification.LocationManager), object: nil)
        
        FetchNearByVehicle()
        KTPaymentManager().fetchPaymentsFromServer { status, response in}

        // Resuming timer even if booking in progress
        if timerFetchNearbyVehicle == nil {
            timerFetchNearbyVehicle = Timer.scheduledTimer(timeInterval: TimeInterval(TIMER_INTERVAL), target: self, selector: #selector(KTCreateBookingViewModel.FetchNearByVehicle), userInfo: nil, repeats: true)
        }
        if currentBookingStep == BookingStep.step1 {
            (delegate as! KTCreateBookingViewModelDelegate).hideCancelBookingBtn()
        }
        else if currentBookingStep == BookingStep.step3 {
            (delegate as! KTCreateBookingViewModelDelegate).showCancelBookingBtn()
            
            setPickupDate(date: Date())
            (delegate as! KTCreateBookingViewModelDelegate).setRequestButtonTitle(title: "txt_req_karwa".localized())
            (delegate as! KTCreateBookingViewModelDelegate).setPickDate(date: "title_schedule".localized())
            
            if promo != ""{
                fetchEstimateForPromo(promo)
            } else {
                fetchEstimates()
            }
            
            registerForMinuteChange()
            encodedPath = ""
            drawDirectionOnMap(encodedPath: "")
            showCurrentLocationDot(location: KTLocationManager.sharedInstance.currentLocation.coordinate)
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        del?.allowScrollVTypeCard(allow: true)
    }
    
    override func viewWillDisappear() {
        if removeBooking  && booking.bookingStatus == BookingStatus.UNKNOWN.rawValue{
            booking.mr_deleteEntity()
        }
        super.viewWillDisappear()
        NotificationCenter.default.removeObserver(self)
        if timerFetchNearbyVehicle != nil {
            timerFetchNearbyVehicle!.invalidate()
            timerFetchNearbyVehicle = nil
        }
        initialDateSetUp = true
    }
    
    //MARK:- Address picker setting pick drop
    func setPickAddress(pAddress : KTGeoLocation) {
        booking.pickupLocationId = pAddress.locationId
        
        if pAddress.favoriteName == "" {
            booking.pickupAddress = pAddress.name
        } else {
            booking.pickupAddress = pAddress.favoriteName
        }
        
        pickUpAddressGeoLocation = pAddress
        booking.pickupAddress = pAddress.name
        booking.pickupLat = pAddress.latitude
        booking.pickupLon = pAddress.longitude
    }
    
    func setDropAddress(dAddress : KTGeoLocation) {
        booking.dropOffLocationId = dAddress.locationId
        dropOffAddressGeoLocation = dAddress
        if dAddress.favoriteName == "" {
            booking.dropOffAddress = dAddress.name
        } else {
            booking.dropOffAddress = dAddress.favoriteName
        }
        
        booking.dropOffAddress = dAddress.name
        booking.dropOffLat = dAddress.latitude
        booking.dropOffLon = dAddress.longitude
    }
    
    func setSkipDropOff() {
        booking.dropOffLocationId = 0
        booking.dropOffAddress = nil
        booking.dropOffLat = 0
        booking.dropOffLon = 0
        booking.bookingToEstimate = nil
        estimates = nil
    }
    
    //MARK:-
    private func locationAvailable(locationName: String?) -> Bool {
        guard locationName != nil, locationName != ""  else {
            return false
        }
        return true
        
    }
    func isPickAvailable() -> Bool {
        if(booking.pickupAddress == nil || booking.pickupAddress == "")
        {
            booking = BookingBean.getBookingEntityFromBooking(bookingBean: self.cloneBooking)
        }
        
        return locationAvailable(locationName: booking.pickupAddress)
    }
    
    func isDropAvailable() -> Bool {
        return locationAvailable(locationName: booking.dropOffAddress)
    }
    
    func pickUpAddress() -> KTGeoLocation? {
        guard  isPickAvailable() else {
            return nil
        }
        return KTBookingManager().geoLocaiton(forLocationId: booking.pickupLocationId, latitude: booking.pickupLat, longitude: booking.pickupLon, name: booking.pickupAddress!)
        
    }
    
    func destinationSelectedFromHomeScreen(location: KTGeoLocation) {
        if isPickAvailable() {
            setDropAddress(dAddress: location)
            carouselSelected = true
            step3SelectRideService()
            (delegate as! KTCreateBookingViewModelDelegate).showCancelBookingBtn()
            fetchEstimates()
        }
    }
    
    func dropOffAddress() -> KTGeoLocation? {
        guard  isDropAvailable() else {
            return nil
        }
        return KTBookingManager().geoLocaiton(forLocationId: booking.dropOffLocationId, latitude: booking.dropOffLat, longitude: booking.dropOffLon, name: booking.dropOffAddress!)
        
    }
    
    func updateForRebook() {
        AnalyticsUtil.trackBehavior(event: "rebook")
        currentBookingStep = BookingStep.step3
        if isPickAvailable() {
            (self.delegate as! KTCreateBookingViewModelDelegate).setPickUp(pick: booking.pickupAddress!)
        }
        
        if isDropAvailable()
        {
            (self.delegate as! KTCreateBookingViewModelDelegate).setDropOff(drop: booking.dropOffAddress!)
        }
        else
        {
            (self.delegate as! KTCreateBookingViewModelDelegate).setDropOff(drop: "txt_set_destination".localized())
        }
        
        selectedVehicleType = VehicleType(rawValue: booking.vehicleType)!
        
        (self.delegate as! KTCreateBookingViewModelDelegate).setVehicleType(idx: idxToSelectVehicleType())
        
        updateUI()
        
        if booking.bookingToEstimate != nil {
            booking.bookingToEstimate?.mr_deleteEntity()
            booking.bookingToEstimate = nil
        }
        
        (delegate as! KTCreateBookingViewModelDelegate).setETAContainerBackground(background: KTUtils.getEtaBackgroundNameByVT(vehicleType: selectedVehicleType.rawValue))
        
        fetchEstimates(rebook: rebook)
    }
    //MARK:- Sync Applicaiton Data
    func syncApplicationData() {
        KTAppDataSyncManager().syncApplicationData()
    }
    
    //MARK: - FareBreakdown
    
    func vehicleTypeTapped(idx: Int)
    {
        
        print("vehicleTypes?[idx]", vehicleTypes?[idx])
        print("idx", idx)
        
        selectedVehicleType = VehicleType(rawValue: Int16(vehicleTypes![idx].typeId))!
        print("Selected ---> \(selectedVehicleType.rawValue)")
        
        let firstElement = (vehicleTypes?[idx])!
        let filteredList = (modifiedVehicleTypes?.filter{$0.typeId != vehicleTypes![idx].typeId})!
        modifiedVehicleTypes?.removeAll()
        modifiedVehicleTypes?.append(firstElement)
        modifiedVehicleTypes?.append(contentsOf: filteredList)
        if previousSelectedIndex != idx  {
            previousSelectedIndex = idx
        }
        
        
    }
    
    func showEstimate(vehicleType vtype: KTVehicleType){
        
        let title = "Estimated Fare"
        var orderedKV : [[String:String]] = []
        
        for kv : KTKeyValue in  estimate(forVehicleType: vtype.typeId)?.toKeyValueBody?.array as! [KTKeyValue] {
            
            var kvDictionary : [String:String] = [:]
            kvDictionary[kv.key!] = kv.value
            orderedKV.append(kvDictionary)
        }
        del?.showFareBreakdown(animated: true, kvPair: orderedKV, title: title)
    }
    
    func updateEstimates(vehicleType vtype: KTVehicleType ) {
        
        var orderedKV : [[String:String]] = []
        
        for kv : KTKeyValue in  estimate(forVehicleType: vtype.typeId)?.toKeyValueBody?.array as! [KTKeyValue] {
            var kvDictionary : [String:String] = [:]
            kvDictionary[kv.key!] = kv.value
            orderedKV.append(kvDictionary)
        }
        del?.updateFareBreakdown(kvPair: orderedKV)
    }
    
    func showFareBreakDown(vehicleType vtype: KTVehicleType) {
        let title = "Fare Breakdown"
        var orderedKV : [[String:String]] = []
        
        for kv : KTKeyValue in vtype.toKeyValueBody?.array as! [KTKeyValue] {
            
            var kvDictionary : [String:String] = [:]
            kvDictionary[kv.key!] = kv.value
            orderedKV.append(kvDictionary)
        }
        
        del?.showFareBreakdown(animated: true, kvPair: orderedKV, title: title)
    }
    
    func updateFareDetails(vehicleType vtype: KTVehicleType ) {
        
        var orderedKV : [[String:String]] = []
        
        for kv : KTKeyValue in vtype.toKeyValueBody?.array as! [KTKeyValue] {
            var kvDictionary : [String:String] = [:]
            kvDictionary[kv.key!] = kv.value
            orderedKV.append(kvDictionary)
        }
        del?.updateFareBreakdown(kvPair: orderedKV)
    }
    
    //MARK: - Navigation to Address Picker
    func btnPickupAddTapped(){
        removeBooking = false
        delegate?.performSegue(name: "segueBookingToAddresspickerForPickup")
    }
    
    func btnDropAddTapped() {
        removeBooking = false
        del?.allowScrollVTypeCard(allow: false)
        delegate?.performSegue(name: "segueBookingToAddresspickerForDropoff")
    }
    //MARK: - Navigation view functions
    func step3SelectRideService() {
        currentBookingStep = BookingStep.step3
        if booking.pickupAddress != nil || booking.pickupAddress != "" {
            (delegate as! KTCreateBookingViewModelDelegate).setPickUp(pick: booking.pickupAddress)
            //        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
            //            (self.delegate as! KTCreateBookingViewModelDelegate).restoreCustomerServiceSelection()
            //        })
        }
        
        if(booking.dropOffAddress != nil && booking.dropOffAddress != "") {
            (delegate as! KTCreateBookingViewModelDelegate).setDropOff(drop: booking.dropOffAddress)
        }
        else {
            (delegate as! KTCreateBookingViewModelDelegate).setDropOff(drop: dropOffBtnText)
        }
        updateUI()
    }
    func dismiss() {
        step3SelectRideService()
        delegate?.dismiss()
    }
    
    func updateUI() {
        (delegate as! KTCreateBookingViewModelDelegate).showRequestBookingBtn()
        (delegate as! KTCreateBookingViewModelDelegate).pickDropBoxStep3()
    }
    
    //MARK: - Promotion
    func getPromotions() {
        guard (booking.pickupAddress != nil && booking.pickupAddress != "") || (booking.dropOffAddress != nil && booking.dropOffAddress != "") else {return}
        var params: PromotionParams = PromotionParams()
        if booking.pickupAddress != nil && booking.pickupAddress != "" {
            params.pickupLat = booking.pickupLat
            params.pickupLong = booking.pickupLon
        }
        if booking.dropOffAddress != nil && booking.dropOffAddress != "" {
            params.dropoffLat = booking.dropOffLat
            params.dropoffLong = booking.dropOffLon
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm:ss a"
        let date = dateFormatter.string(from: selectedPickupDateTime)
        params.dateTime = date

        KTPromotionManager().fetchPromotions(params: params) { [weak self] (status, response) in
            guard let `self` = self else{return}
            if status == Constants.APIResponseStatus.SUCCESS
            {
                var promotionList: [PromotionModel] = []
                guard let promotions = response["D"] as? [[String : Any]] else {
                    (self.delegate as! KTCreateBookingViewModelDelegate).getPromotions(promotions: [])
                    return
                }
                for item in promotions {
                    var promotionInfo = PromotionModel()
                    
                    promotionInfo.id = item["Id"] as? Int
                    promotionInfo.name = item["Name"] as? String
                    promotionInfo.description = item["Description"] as? String
                    promotionInfo.moreInfo = item["MoreInfo"] as? String
                    promotionInfo.code = item["Code"] as? String
                    let iconUrl = KTConfiguration.sharedInstance.envValue(forKey: Constants.API.BaseURLKey) + Constants.APIURL.PromotionIcon + String(promotionInfo.id!)
                    promotionInfo.icon = iconUrl
                    
                    promotionList.append(promotionInfo)
                }
                (self.delegate as! KTCreateBookingViewModelDelegate).getPromotions(promotions: promotionList)
            }
            else
            {
                (self.delegate as! KTCreateBookingViewModelDelegate).getPromotions(promotions: [])
            }
        }
    }
    
    func getPickupDropoffForPromotions() -> PromotionParams? {
        guard (booking.pickupAddress != nil && booking.pickupAddress != "") || (booking.dropOffAddress != nil && booking.dropOffAddress != "") else {return nil}
        var params: PromotionParams = PromotionParams()
        if booking.pickupAddress != nil && booking.pickupAddress != "" {
            params.pickupLat = booking.pickupLat
            params.pickupLong = booking.pickupLon
        }
        if booking.dropOffAddress != nil && booking.dropOffAddress != "" {
            params.dropoffLat = booking.dropOffLat
            params.dropoffLong = booking.dropOffLon
        }
        
        return params
    }
    
    //MARK: - Estimates
    private func fetchEstimates(rebook: Bool = false) {
        //    del?.updateVehicleTypeList()
        //    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
        //        (self.delegate as! KTCreateBookingViewModelDelegate).restoreCustomerServiceSelection()
        //    })
        
        if booking.pickupAddress != nil && booking.pickupAddress != "" && booking.dropOffAddress != nil && booking.dropOffAddress != "" {
            isEstimeting = true
            
            let pickup = CLLocationCoordinate2D(latitude: booking.pickupLat, longitude: booking.pickupLon)
            let dropoff = CLLocationCoordinate2D(latitude: booking.dropOffLat,longitude: booking.dropOffLon)
            
            KTVehicleTypeManager().fetchEstimate(pickup: pickup,
                                                 dropoff: dropoff,
                                                 time: selectedPickupDateTime.serverTimeStamp(),
                                                 complition: { (status, response) in
                                                    self.isEstimeting = false
                                                    if status == Constants.APIResponseStatus.SUCCESS {
                                                        self.estimates = KTVehicleTypeManager().estimates()
                                                        
                                                        let encodedPath = response[Constants.BookingResponseAPIKey.EncodedPath] as? String
                                                        self.encodedPath = encodedPath ?? ""
                                                        self.del?.updateVehicleTypeList()
                                                        if rebook {
                                                            self.del?.rebookRide()
                                                        }
                                                        self.drawDirectionOnMap(encodedPath: encodedPath ?? "")
                                                        
                                                        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                                                            (self.delegate as! KTCreateBookingViewModelDelegate).restoreCustomerServiceSelection(animateView: false)
                                                        })
                                                        
                                                        if self.booking.paymentMethod != nil && self.selectedVehicleType.rawValue == self.booking.vehicleType {
                                                            let vehicleType = KTVehicleTypeManager().vehicleType(typeId: (self.booking.vehicleType))!
                                                            let selectedIndex = (self.vehicleTypes?.index(of: vehicleType)) ?? 0
                                                            
                                                            self.selectedVehicleType = VehicleType(rawValue: Int16(self.vehicleTypes![selectedIndex].typeId))!
                                                            print("Selected ---> \(self.selectedVehicleType.rawValue)")
                                                            
                                                            let firstElement = (self.vehicleTypes?[selectedIndex])!
                                                            let filteredList = (self.modifiedVehicleTypes?.filter{$0.typeId != self.vehicleTypes![selectedIndex].typeId})!
                                                            self.modifiedVehicleTypes?.removeAll()
                                                            self.modifiedVehicleTypes?.append(firstElement)
                                                            self.modifiedVehicleTypes?.append(contentsOf: filteredList)
                                                            
                                                            self.vehicleTypes = self.modifiedVehicleTypes
                                                            
                                                            (self.delegate as! KTCreateBookingViewModelDelegate).reloadSelection()
                                                        }
                                                        
                                                    }
                                                    else {
                                                        if self.estimates != nil{
                                                            self.estimates?.removeAll()
                                                            self.estimates = nil
                                                        }
                                                        if rebook {
                                                            self.del?.rebookRide()
                                                        }
                                                    }
                                                 })
            
            KTVehicleTypeManager().fetchETA(pickup: pickup) { [weak self] (status, response) in
                if status == Constants.APIResponseStatus.SUCCESS {
                    self?.vehicleTypes?.removeAll()
                    self?.vehicleTypes = KTVehicleTypeManager().VehicleTypes()
                    self?.setupVehicleCategories()
                    self?.modifiedVehicleTypes = self?.vehicleTypes
                    
                    let firstElement = self?.vehicleTypes?.filter({ (KTV) -> Bool in
                        if KTV.typeId == self?.selectedVehicleType.rawValue{
                            return true
                        } else {
                            return false
                        }
                    })
                    let filteredList = (self?.modifiedVehicleTypes?.filter{$0.typeId != self?.selectedVehicleType.rawValue})!
                    self?.modifiedVehicleTypes?.removeAll()
                    self?.modifiedVehicleTypes?.append(firstElement![0])
                    self?.modifiedVehicleTypes?.append(contentsOf: filteredList)
                    
                    self?.vehicleTypes = self?.modifiedVehicleTypes
                    
                    
                }
            }
        }
        else if estimates != nil{
            estimates?.removeAll()
            estimates = nil
        } else {
            (self.delegate as! KTCreateBookingViewModelDelegate).reloadSelection()
            if rebook {
                self.del?.rebookRide()
            }
        }
        
    }
    
    func resetVehicleTypes()
    {
        vehicleTypes?.removeAll()
        vehicleTypes = KTVehicleTypeManager().VehicleTypes()
        self.setupVehicleCategories()
        self.modifiedVehicleTypes = KTVehicleTypeManager().VehicleTypes()
    }
    
    private func fetchEstimateForPromo(_ promoEntered: String)
    {
        //    del?.updateVehicleTypeList()
        //    DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
        //        (self.delegate as! KTCreateBookingViewModelDelegate).restoreCustomerServiceSelection()
        //    })
        
        if(booking.pickupAddress != nil && booking.pickupAddress != "")
        {
            // Drop-off has been skipped and asking for promo :/
            if(booking.dropOffAddress == nil || booking.dropOffAddress == "")
            {
                //                isEstimeting = true
                cloneBooking = BookingBean.init(bookingEntity: booking)
                
                KTVehicleTypeManager().fetchEstimateForPromo(pickup: CLLocationCoordinate2D(latitude: booking.pickupLat, longitude: booking.pickupLon), time: selectedPickupDateTime.serverTimeStamp(), promo: promoEntered, complition: { (status, response) in
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        
                        self.booking = BookingBean.getBookingEntityFromBooking(bookingBean: self.cloneBooking)
                        
                        // self.isEstimeting = false
                        if status == Constants.APIResponseStatus.SUCCESS
                        {
                            isBaseFareChangedForPromo = true
                            
                            self.vehicleTypes = nil
                            self.vehicleTypes = KTVehicleTypeManager().VehicleTypes()
                            self.setupVehicleCategories()
                            self.modifiedVehicleTypes = KTVehicleTypeManager().VehicleTypes()
                            self.promo = promoEntered
                            (self.delegate as! KTCreateBookingViewModelDelegate).setPromotionCode(promo: promoEntered)
                            (self.delegate as! KTCreateBookingViewModelDelegate).showPromotionAppliedToast(show: true)
                            
                            self.del?.setPromoButtonLabel(validPromo: promoEntered)
                            self.estimates = KTVehicleTypeManager().estimates()
                            
                            let encodedPath = response[Constants.BookingResponseAPIKey.EncodedPath] as? String
                            self.encodedPath = encodedPath ?? ""
                            self.del?.updateVehicleTypeList()
                            self.drawDirectionOnMap(encodedPath: encodedPath ?? "")
                            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                                (self.delegate as! KTCreateBookingViewModelDelegate).restoreCustomerServiceSelection()
                            })
                        }
                        else
                        {
                            (self.delegate as! KTBaseViewController).showOkDialog(titleMessage: response["T"] as? String ?? "Error", descMessage: response["M"] as! String, completion:
                                                                                    { (UIAlertAction) in
                                                                                        self.removeBooking = false
                                                                                        self.promo = ""
                                                                                        (self.delegate as! KTCreateBookingViewModelDelegate).showPromoInputDialog(currentPromo: "")
                                                                                    })
                        }
                        
                    })
                })
            }
            // Pickup and Drop-off both are present and asking for promo, good customer :)
            else if booking.pickupAddress != nil && booking.pickupAddress != "" && booking.dropOffAddress != nil && booking.dropOffAddress != ""
            {
                //                isEstimeting = true
                
                KTVehicleTypeManager().fetchEstimateForPromo(pickup: CLLocationCoordinate2D(latitude: booking.pickupLat, longitude: booking.pickupLon), dropoff: CLLocationCoordinate2D(latitude: booking.dropOffLat,longitude: booking.dropOffLon), time: selectedPickupDateTime.serverTimeStamp(), promo: promoEntered, complition: { (status, response) in
                    //            self.isEstimeting = false
                    
                    if status == Constants.APIResponseStatus.SUCCESS
                    {
                        self.promo = promoEntered
                        (self.delegate as! KTCreateBookingViewModelDelegate).setPromotionCode(promo: promoEntered)
                        (self.delegate as! KTCreateBookingViewModelDelegate).showPromotionAppliedToast(show: true)
                        self.del?.setPromoButtonLabel(validPromo: promoEntered)
                        self.estimates = KTVehicleTypeManager().estimates()
                        
                        let encodedPath = response[Constants.BookingResponseAPIKey.EncodedPath] as? String
                        self.encodedPath = encodedPath ?? ""
                        self.del?.updateVehicleTypeList()
                        self.drawDirectionOnMap(encodedPath: encodedPath ?? "")
                        
                        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                            (self.delegate as! KTCreateBookingViewModelDelegate).restoreCustomerServiceSelection()
                        })
                        
                        let vehicleType = KTVehicleTypeManager().vehicleType(typeId: (self.booking.vehicleType))!
                        let selectedIndex = (self.vehicleTypes?.index(of: vehicleType)) ?? 0
                        self.selectedVehicleType = VehicleType(rawValue: Int16(self.vehicleTypes![selectedIndex].typeId))!
                        print("Selected ---> \(self.selectedVehicleType.rawValue)")
                        
                        let firstElement = (self.vehicleTypes?[selectedIndex])!
                        let filteredList = (self.modifiedVehicleTypes?.filter{$0.typeId != self.vehicleTypes![selectedIndex].typeId})!
                        self.modifiedVehicleTypes?.removeAll()
                        self.modifiedVehicleTypes?.append(firstElement)
                        self.modifiedVehicleTypes?.append(contentsOf: filteredList)
                        
                        self.vehicleTypes = self.modifiedVehicleTypes
                        
                        (self.delegate as! KTCreateBookingViewModelDelegate).reloadSelection()
                        
                    }
                    else
                    {
                        let title = (response[Constants.ResponseAPIKey.Title] as? String) ?? "error_sr".localized()
                        let message = (response[Constants.ResponseAPIKey.Message] as? String) ?? "please_dialog_msg_went_wrong".localized()
                        
                        (self.delegate as! KTBaseViewController).showOkDialog(titleMessage: title, descMessage: message, completion:
                                                                                { (UIAlertAction) in
                                                                                    self.removeBooking = false
                                                                                    self.promo = ""
                                                                                    (self.delegate as! KTCreateBookingViewModelDelegate).showPromoInputDialog(currentPromo: "")
                                                                                })
                    }
                })
            }
            else if estimates != nil
            {
                estimates?.removeAll()
                estimates = nil
            }
        }
        else
        {
            self.delegate?.showError!(title: "Error", message:"Pickup location is not confirmed for this promo")
        }
    }
    
    func fetchEstimateId(forVehicleType vType: VehicleType) -> KTFareEstimate?{
        //var estId : String = ""
        let vEstimate : KTFareEstimate? = self.estimate(forVehicleType: vType.rawValue)
        //        if estimate != nil {
        //            estId = (estimate?.estimateId)!
        //        }
        return vEstimate
    }
    
    func vTypeEta(forIndex idx: Int) -> String {
        var result = ""
        
        if let vehicles = self.vehicleTypes {
            
            if  !isDropAvailable() && (selectedPickupDateTime >= Date()) {
                result =  "str_starting_fare".localized()
            } else if isDropAvailable() && (selectedPickupDateTime >= Date()) {
                result = "str_estimated_fare".localized()
            } else {
                result = vehicles[idx].etaText ?? "" == "" ? "txt_not_available".localized() : (vehicles[idx].etaText ?? "txt_not_available".localized())
            }
            
        }
        
        return result.isEmpty ? "txt_not_available".localized() : result
    }
    func vTypeBaseFareOrEstimate(forIndex idx: Int) -> String
    {
        var fareOrEstimate : String = ""
        let vType : KTVehicleType = vehicleTypes![idx]
        if isEstimeting == false
        {
            if estimates == nil || estimates?.count == 0
            {
                let localizedMsg = String(format: "txt_fare_base".localized(), vType.typeBaseFare ?? "")
                
                fareOrEstimate =  localizedMsg //vType.typeBaseFare ?? ""
            }
            else
            {
                let estimate : KTFareEstimate? = self.estimate(forVehicleType: vType.typeId)
                if estimate != nil
                {
                    fareOrEstimate = (estimate?.estimatedFare!)!
                }
            }
        }
        return fareOrEstimate
    }
    
    func isPromoFare(forIndex idx: Int) -> Bool
    {
        var isPromoApplied = false
        let vType : KTVehicleType = vehicleTypes![idx]
        
        if estimates == nil || estimates?.count == 0
        {
            let vType : KTVehicleType = vehicleTypes![idx]
            isPromoApplied = vType.isPromoApplied
        }
        else
        {
            let estimate : KTFareEstimate? = self.estimate(forVehicleType: vType.typeId)
            if estimate != nil
            {
                isPromoApplied = estimate?.isPromoApplied ?? false
            }
        }
        return isPromoApplied
    }
    
    func FareEstimateTitle() -> String
    {
        var title: String = "Estimated Fare"
        if isEstimeting == true {
            title = "Estimating..."
        }
        else if estimates == nil || estimates?.count == 0 {
            title = "Starting Fare"
        }
        
        return title
    }
    //MARK: - Direction / Polyline on Map
    public func drawDirectionOnMap(encodedPath: String) {
        
        (delegate as! KTCreateBookingViewModelDelegate).clearMap()
        if isPickAvailable() && isDropAvailable() {
            //if both pickup and dropoff are available then draw path.
            drawPath(encodedPath: encodedPath)
        }
        else {
            
            if(isPickAvailable() && !isDropAvailable())
            {
                (delegate as! KTCreateBookingViewModelDelegate).addMarkerOnMap(location:CLLocationCoordinate2D(latitude: booking.pickupLat,longitude: booking.pickupLon) , image: UIImage(named: "BookingMapDirectionPickup")!)
                (delegate as! KTCreateBookingViewModelDelegate).focusOnLocation(lat: booking.pickupLat, lon: booking.pickupLon)
            }
            else
            {
                //else draw point what ever is available
                if isPickAvailable() {
                    //Setting Pick marker
                    (delegate as! KTCreateBookingViewModelDelegate).addMarkerOnMap(location:CLLocationCoordinate2D(latitude: booking.pickupLat,longitude: booking.pickupLon) , image: UIImage(named: "BookingMapDirectionPickup")!)
                }
                
                if isDropAvailable() {
                    (delegate as! KTCreateBookingViewModelDelegate).addMarkerOnMap(location:CLLocationCoordinate2D(latitude: booking.dropOffLat,longitude: booking.dropOffLon) , image: UIImage(named: "BookingMapDirectionDropOff")!)
                }
            }
        }
    }
    
    func drawPath(encodedPath: String){
        
        (self.delegate as! KTCreateBookingViewModelDelegate).addPointsOnMap(points: encodedPath)
        
        if(Constants.DIRECTIONS_API_ENABLE)
        {
            let origin = String(format:"%f", booking.pickupLat) + "," + String(format:"%f", booking.pickupLon)
            //"\(String(describing: pickUpAddress?.latitude)),\(String(describing: pickUpAddress?.longitude))"
            let destination = String(format:"%f", booking.dropOffLat) + "," + String(format:"%f", booking.dropOffLon)
            //"\(String(describing: dropOffAddress?.latitude)),\(String(describing: dropOffAddress?.longitude))"
            
            let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=\(Constants.GOOGLE_DIRECTION_API_KEY)"
            print(url)
            Alamofire.request(url, method: .get, parameters: nil, headers: nil).responseJSON { (response:DataResponse<Any>) in
                //print(response)
                
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        do {
                            let json = try JSON(data: response.data!)
                            
                            let routes = json["routes"].arrayValue
                            
                            for route in routes
                            {
                                let routeOverviewPolyline = route["overview_polyline"].dictionary
                                let points = routeOverviewPolyline?["points"]?.stringValue
                                
                                (self.delegate as! KTCreateBookingViewModelDelegate).addPointsOnMap(points: points!)
                            }
                        }
                        catch _ {
                            
                            print("Error: Unalbe to draw polyline. ")
                        }
                    }
                    break
                    
                case .failure(_):
                    print(response.result.error as Any)
                    break
                }
            }
        }
        else
        {
            let pickMarker = (delegate as! KTCreateBookingViewModelDelegate).addAndGetMarkerOnMap(location:CLLocationCoordinate2D(latitude: booking.pickupLat,longitude: booking.pickupLon) , image: UIImage(named: "BookingMapDirectionPickup")!)
            let dropMarker = (delegate as! KTCreateBookingViewModelDelegate).addAndGetMarkerOnMap(location:CLLocationCoordinate2D(latitude: booking.dropOffLat,longitude: booking.dropOffLon) , image: UIImage(named: "BookingMapDirectionDropOff")!)
            
            var pickDropMarkers = [GMSMarker]()
            pickDropMarkers.append(pickMarker)
            pickDropMarkers.append(dropMarker)
            
            (delegate as! KTCreateBookingViewModelDelegate).focusMapToShowAllMarkers(gmsMarker: pickDropMarkers)
        }
    }
    
    func fetchETA(vehicles: [VehicleTrack]){
        var sortedListForETA : [Int] = []
        for vehicle in vehicles
        {
            if(vehicle.eta > 0)
            {
                sortedListForETA.append(Int(vehicle.eta))
            }
        }
        if(sortedListForETA.count > 0)
        {
            sortedListForETA = sortedListForETA.sorted()
            //      (self.delegate as! KTCreateBookingViewModelDelegate).setETAString(etaString: KTUtils.getETAString(etaInSeconds: sortedListForETA[0]))
            
            (self.delegate as! KTCreateBookingViewModelDelegate).setETAString(etaString: vehicles[0].etaText)
        }
    }
    
    func directionBounds() -> GMSCoordinateBounds
    {
        
        var bounds = GMSCoordinateBounds()
        bounds = bounds.includingCoordinate(CLLocationCoordinate2D(latitude: booking.pickupLat,longitude: booking.pickupLon))
        bounds = bounds.includingCoordinate(CLLocationCoordinate2D(latitude: booking.dropOffLat,longitude: booking.dropOffLon))
        
        return bounds
    }
    
    //MARK: - Minute Change
    private func registerForMinuteChange() {
        
        if(!isAdvanceBooking)
        {
            setPickupDate(date: Date())
            KTTimer.sharedInstance.startMinTimer()
        }
        else
        {
            KTTimer.sharedInstance.stoprMinTimer()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.MinuteChanged(notification:)), name: Notification.Name(Constants.Notification.MinuteChanged), object: nil)
    }
    
    private func unregisterForMinuteChange()
    {
        KTTimer.sharedInstance.stoprMinTimer()
    }
    
    @objc func MinuteChanged(notification: Notification)
    {
        
        if selectedPickupDateTime.timeIntervalSinceNow < CHECK_DELAY {
            //Update UI as its current time.
            //updateUIForCurrentDate()
            setPickupDate(date: Date())
            
        }
    }
    
    func setPickupDateForAdvJob(date: Date)
    {
        isAdvanceBooking = true
        initialDateSetUp = false
        setPickupDate(date: date)
        
        if promo != ""{
            fetchEstimateForPromo(promo)
        } else {
            fetchEstimates()
            resetPromo()
            resetPromoOrBaseFare()
        }
        
        
    }
    func setPickupDate(date: Date)
    {
        if selectedPickupDateTime.timeIntervalSinceNow >= date.timeIntervalSinceNow {
            
        }
        
        selectedPickupDateTime = date
        updateUI(forDate: selectedPickupDateTime)
        getPromotions()
    }
    
    func updateUI(forDate date: Date)
    {
        
        let formatedDate : String = formatedDateForUI(date: date)
        (delegate as! KTCreateBookingViewModelDelegate).setPickDate(date: formatedDate)
    }
    
    func formatedDateForUI(date: Date) -> String
    {
        
        var datePart : String = ""
        if date.isToday {
            
            datePart = "day_title_today".localized()
            (delegate as! KTCreateBookingViewModelDelegate).setRequestButtonTitle(title: "txt_req_karwa".localized())
            
        }
        else {
            
            let dateFormatter = DateFormatter()
            //            dateFormatter.dateFormat = "MM/dd/yyyy"
            dateFormatter.dateFormat = "MM/dd"
            datePart = dateFormatter.string(from: date)
            (delegate as! KTCreateBookingViewModelDelegate).setRequestButtonTitle(title: "txt_schedule_karwa".localized())
            
        }
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        
        var time = ""
        
        if initialDateSetUp == true {
            time = "title_schedule".localized()
        } else {
            time = "\(datePart), \(timeFormatter.string(from: date))"
        }
        
        return time
        
    }

    //MARK:-  Vehicle Types
    func setupVehicleCategories(){
        if vehicleTypes != nil {
            vehicleCategories.removeAll()
            for i in 0...(vehicleTypes?.count)!-1 {
                if vehicleTypes![i].typeId == VehicleType.KTCityTaxi.rawValue || vehicleTypes![i].typeId == VehicleType.KTCityTaxi7Seater.rawValue {
                    if vehicleCategories.keys.contains(VehicleCategories.FIRST.rawValue) {
                        vehicleCategories[VehicleCategories.FIRST.rawValue]?.append(vehicleTypes![i])
                    }
                    else {
                        vehicleCategories[VehicleCategories.FIRST.rawValue] = [vehicleTypes![i]]
                    }
                }
                
                else if vehicleTypes![i].typeId == VehicleType.KTSpecialNeedTaxi.rawValue {
                    if vehicleCategories.keys.contains(VehicleCategories.SECOND.rawValue) {
                        vehicleCategories[VehicleCategories.SECOND.rawValue]?.append(vehicleTypes![i])
                    }
                    else {
                        vehicleCategories[VehicleCategories.SECOND.rawValue] = [vehicleTypes![i]]
                    }
                }
                else if vehicleTypes![i].typeId == VehicleType.KTStandardLimo.rawValue || vehicleTypes![i].typeId == VehicleType.KTBusinessLimo.rawValue || vehicleTypes![i].typeId == VehicleType.KTLuxuryLimo.rawValue {
                    if vehicleCategories.keys.contains(VehicleCategories.THIRD.rawValue) {
                        vehicleCategories[VehicleCategories.THIRD.rawValue]?.append(vehicleTypes![i])
                    }
                    else {
                        vehicleCategories[VehicleCategories.THIRD.rawValue] = [vehicleTypes![i]]
                    }
                }
                else if vehicleTypes![i].typeId == VehicleType.KTIconicLimousine.rawValue && KTConfiguration.sharedInstance.checkIconicLimousineEnabled() {
                    if vehicleCategories.keys.contains(VehicleCategories.FOURTH.rawValue) {
                        vehicleCategories[VehicleCategories.FOURTH.rawValue]?.append(vehicleTypes![i])
                    }
                    else {
                        vehicleCategories[VehicleCategories.FOURTH.rawValue] = [vehicleTypes![i]]
                    }
                }
            }
        }
    }
    
    func numberOfVehicleCategories() -> Int {
        return vehicleCategories.count
    }
    
    func numberOfRowsInCategories(catName: String) -> Int {
        if catName == VehicleCategories.FIRST.rawValue {
            return vehicleCategories.keys.contains(VehicleCategories.FIRST.rawValue) ? (vehicleCategories[VehicleCategories.FIRST.rawValue]?.count ?? 0) : 0
        }
        else if catName == VehicleCategories.SECOND.rawValue {
            return vehicleCategories.keys.contains(VehicleCategories.SECOND.rawValue) ? (vehicleCategories[VehicleCategories.SECOND.rawValue]?.count ?? 0) : 0
        }
        else if catName == VehicleCategories.THIRD.rawValue {
            return vehicleCategories.keys.contains(VehicleCategories.THIRD.rawValue) ? (vehicleCategories[VehicleCategories.THIRD.rawValue]?.count ?? 0) : 0
        }
        else if catName == VehicleCategories.FOURTH.rawValue {
            return vehicleCategories.keys.contains(VehicleCategories.FOURTH.rawValue) ? (vehicleCategories[VehicleCategories.FOURTH.rawValue]?.count ?? 0) : 0
        }
        return 0
    }
    
    func getVehicleCategory(by typeId: Int16) -> String? {
        let category = vehicleCategories.first { category in
            let vehicleType = category.value.first(where: { type in
                type.typeId == typeId
            })
            return vehicleType?.typeId == typeId
        }
        return category?.key
    }
    
    func getVehicleByCategory(catName: String) -> [KTVehicleType]{
        return vehicleCategories[catName] ?? []
    }
    
    func getTypeBaseFareOrEstimate(typeId: Int16) -> String {
        var fareOrEstimate : String = ""
        let vType : KTVehicleType? = vehicleTypes?.first(where: {$0.typeId == typeId})
        if isEstimeting == false, let vType = vType{
            if estimates == nil || estimates?.count == 0
            {
                let localizedMsg = String(format: "txt_fare_base".localized(), vType.typeBaseFare ?? "")
                
                fareOrEstimate =  localizedMsg //vType.typeBaseFare ?? ""
            }
            else
            {
                let estimate : KTFareEstimate? = self.estimate(forVehicleType: vType.typeId)
                if estimate != nil
                {
                    fareOrEstimate = (estimate?.estimatedFare!)!
                }
            }
        }
        return fareOrEstimate
    }
    
    func getTypeCapacity(typeId: Int16) -> String {
        let sType : KTVehicleType? = vehicleTypes?.first(where: {$0.typeId == typeId})
        var capacity : String = "txt_four".localized()
        guard let _sType = sType else {return capacity}
        switch _sType.typeId {
        case Int16(VehicleType.KTCityTaxi7Seater.rawValue):
            capacity = "txt_seven".localized()
        default:
            capacity = "txt_four".localized()
        }
        return capacity
    }
    
    func getTypeEta(typeId: Int16) -> String {
        var result = ""
        
        if let _ = self.vehicleTypes {
            
            if  !isDropAvailable() && (selectedPickupDateTime >= Date()) {
                result =  "str_starting_fare".localized()
            } else if isDropAvailable() && (selectedPickupDateTime >= Date()) {
                result = "str_estimated_fare".localized()
            } else {
                if let item : KTVehicleType = vehicleTypes?.first(where: {$0.typeId == typeId}) {
                    result = item.etaText ?? "" == "" ? "txt_not_available".localized() : (item.etaText ?? "txt_not_available".localized())
                }
            }
            
        }
        
        return result.isEmpty ? "txt_not_available".localized() : result
    }
    
    func getAvailableEta(category: VehicleCategories) -> String {
        var result = ""
        
        if let _ = self.vehicleTypes {
            
            if  !isDropAvailable() && (selectedPickupDateTime >= Date()) {
                result =  "str_starting_fare".localized()
            } else if isDropAvailable() && (selectedPickupDateTime >= Date()) {
                result = "str_estimated_fare".localized()
            } else {
                result = vehicleCategories[category.rawValue]?.compactMap({$0.etaText}).min() ?? ""
            }
            
        }
        
        return result.isEmpty ? "txt_not_available".localized() : result
    }
    
    func getTypeVehicleImage(typeId: Int16) -> UIImage {
        var imgSType : UIImage = UIImage()
        if let sType : KTVehicleType = vehicleTypes?.first(where: {$0.typeId == typeId}) {
            
            switch sType.typeId {
            case Int16(VehicleType.KTCityTaxi.rawValue):
                imgSType = UIImage(named: "icon-karwa-taxi")!
            case Int16(VehicleType.KTCityTaxi7Seater.rawValue):
                imgSType = UIImage(named: "icon-family-taxi")!
            case Int16(VehicleType.KTSpecialNeedTaxi.rawValue):
                imgSType = UIImage(named: "icon-accessible-taxi")!
            case Int16(VehicleType.KTStandardLimo.rawValue):
                imgSType = UIImage(named: "icon-standard-limo")!
            case Int16(VehicleType.KTBusinessLimo.rawValue):
                imgSType = UIImage(named: "icon-business-limo")!
            case Int16(VehicleType.KTLuxuryLimo.rawValue):
                imgSType = UIImage(named: "icon-luxury-limo")!
            case Int16(VehicleType.KTIconicLimousine.rawValue):
                imgSType = UIImage(named: "icon-etron")!
            default:
                imgSType = UIImage(named: "icon-karwa-taxi")!
            }
        }
        return imgSType
    }
    
    func getEstimate(typeId: Int16) -> KTFareEstimate? {
        let vEstimate : KTFareEstimate? = self.estimate(forVehicleType: typeId)
        return vEstimate
    }
    
    func getEstimateOrderedBody(typeId: Int16) -> [KTKeyValue]? {
        let vEstimate : KTFareEstimate? = self.estimate(forVehicleType: typeId)
        return vEstimate?.toKeyValueBody?.array as? [KTKeyValue]
    }
    
    func getInitialEstimateOrderedBody(vehicle: KTVehicleType) -> [KTKeyValue]? {
        return vehicle.toKeyValueBody?.array as? [KTKeyValue]
    }
    
    func isPromoFare(typeId: Int16) -> Bool{
        var isPromoApplied = false
        if let vType : KTVehicleType = vehicleTypes?.first(where: {$0.typeId == typeId}) {
            if estimates == nil || estimates?.count == 0
            {
                isPromoApplied = vType.isPromoApplied
            }
            else
            {
                let estimate : KTFareEstimate? = self.estimate(forVehicleType: vType.typeId)
                if estimate != nil
                {
                    isPromoApplied = estimate?.isPromoApplied ?? false
                }
            }
        }
        return isPromoApplied
    }
    
    func isPremiumRide(typeId: Int16) -> Bool{
        var isPremiumRide = false
        
        if let sType : KTVehicleType = vehicleTypes?.first(where: {$0.typeId == typeId}) {
            switch sType.typeId {
            case Int16(VehicleType.KTStandardLimo.rawValue):
                isPremiumRide = true
            case Int16(VehicleType.KTBusinessLimo.rawValue):
                isPremiumRide = true
            case Int16(VehicleType.KTLuxuryLimo.rawValue):
                isPremiumRide = true
            case Int16(VehicleType.KTIconicLimousine.rawValue):
                isPremiumRide = true
            default:
                isPremiumRide = false
            }
        }
        return isPremiumRide
    }
    
    func idxToSelectVehicleType() -> Int {
        
        var idx:Int = 0
        if vehicleTypes != nil {
            
            for i in 0...(vehicleTypes?.count)!-1 {
                if selectedVehicleType.rawValue == vehicleTypes![i].typeId {
                    
                    idx = i
                    break
                }
            }
        }
        return idx
    }
    func maxCarouselIdx() -> Int {
        
        return (vehicleTypes?.count)! - 1
    }
    
    func numberOfRowsVType() -> Int {
        guard (vehicleTypes != nil) else {
            return 0;
        }
        return (vehicleTypes?.count)!
    }
    func sTypeTitle(forIndex idx: Int) -> String {
        let vType : KTVehicleType = vehicleTypes![idx]
        return getVehicleTitle(vehicleType: vType.typeId)
    }
    
    func getVehicleCategory(vehicleType : Int16) -> String
    {
        var category : String = ""
        switch vehicleType {
        case VehicleType.KTCityTaxi.rawValue, VehicleType.KTAirportSpare.rawValue, VehicleType.KTAiport7Seater.rawValue:
            category = "category_taxi".localized()
            
        case VehicleType.KTSpecialNeedTaxi.rawValue:
            category = "category_accessible".localized()
            
        case VehicleType.KTStandardLimo.rawValue, VehicleType.KTBusinessLimo.rawValue, VehicleType.KTLuxuryLimo.rawValue:
            category = "category_limo".localized()
            
        case VehicleType.KTIconicLimousine.rawValue:
            category = "category_electric".localized()
            
        default:
            category = "category_taxi".localized()
        }
        return category
    }
    
    func getVehicleTitle(vehicleType : Int16) -> String
    {
        var type : String = ""
        switch vehicleType {
        case VehicleType.KTCityTaxi.rawValue, VehicleType.KTAirportSpare.rawValue, VehicleType.KTAiport7Seater.rawValue:
            type = "txt_taxi".localized()
            
        case VehicleType.KTCityTaxi7Seater.rawValue:
            type = "txt_family_taxi".localized()
            
        case VehicleType.KTSpecialNeedTaxi.rawValue:
            type = "txt_accessible".localized()
            
        case VehicleType.KTStandardLimo.rawValue:
            type = "txt_limo_standard".localized()
            
        case VehicleType.KTBusinessLimo.rawValue:
            type = "txt_limo_buisness".localized()
            
        case VehicleType.KTLuxuryLimo.rawValue:
            type = "txt_limo_luxury".localized()
            
        case VehicleType.KTIconicLimousine.rawValue:
            type = "txt_etron".localized()
            
        default:
            type = ""
        }
        return type
    }
    
    func getVehicleDescription(vehicleType : Int16) -> String {
        var description : String = ""
        switch vehicleType {
        case VehicleType.KTCityTaxi.rawValue, VehicleType.KTAirportSpare.rawValue, VehicleType.KTAiport7Seater.rawValue:
            description = "description_taxi".localized()
            
        case VehicleType.KTCityTaxi7Seater.rawValue:
            description = "description_family_taxi".localized()
            
        case VehicleType.KTSpecialNeedTaxi.rawValue:
            description = "description_accessible".localized()
            
        case VehicleType.KTStandardLimo.rawValue:
            description = "description_standard_limo".localized()
            
        case VehicleType.KTBusinessLimo.rawValue:
            description = "description_business_limo".localized()
            
        case VehicleType.KTLuxuryLimo.rawValue:
            description = "description_limo".localized()
            
        case VehicleType.KTIconicLimousine.rawValue:
            description = "description_electric_limo".localized()
            
        default:
            description = ""
        }
        return description
    }
    
    func estimate(forVehicleType vTypeId:Int16) -> KTFareEstimate? {
        
        let fareEstimates = estimates?.filter( { (e: KTFareEstimate) -> Bool in
            return e.vehicleType == vTypeId
        })
        if fareEstimates != nil && fareEstimates?.count != 0 {
            return fareEstimates![0]
            
        }
        return nil
    }
    
    func sTypeBackgroundImage(forIndex idx: Int) -> UIImage
    {
        let sType : KTVehicleType = vehicleTypes![idx]
        var imgBg : UIImage = UIImage()
        switch sType.typeId {
        case Int16(VehicleType.KTCityTaxi.rawValue):
            imgBg = UIImage(named: "BookingCardTaxiBox")!
        case Int16(VehicleType.KTCityTaxi7Seater.rawValue):
            imgBg = UIImage(named: "BookingCard7SeaterBox")!
        case Int16(VehicleType.KTSpecialNeedTaxi.rawValue):
            imgBg = UIImage(named: "BookingCardSpecialNeedBox")!
        case Int16(VehicleType.KTStandardLimo.rawValue):
            imgBg = UIImage(named: "BookingCardStandardBox")!
        case Int16(VehicleType.KTBusinessLimo.rawValue):
            imgBg = UIImage(named: "BookingCardBusinessBox")!
        case Int16(VehicleType.KTLuxuryLimo.rawValue):
            imgBg = UIImage(named: "BookingCardLuxuryBox")!
        default:
            imgBg = UIImage(named: "BookingCardTaxiBox")!
        }
        
        return imgBg
    }
    
    func vTypeCapacity(forIndex idx: Int) -> String {
        let sType : KTVehicleType = vehicleTypes![idx]
        var capacity : String = "txt_four".localized()
        switch sType.typeId {
        case Int16(VehicleType.KTCityTaxi7Seater.rawValue):
            capacity = "txt_seven".localized()
        default:
            capacity = "txt_four".localized()
        }
        return capacity
    }
    
    func isPremiumRide(forIndex idx: Int) -> Bool
    {
        var isPremiumRide = false
        
        let sType : KTVehicleType = vehicleTypes![idx]
        switch sType.typeId {
        case Int16(VehicleType.KTStandardLimo.rawValue):
            isPremiumRide = true
        case Int16(VehicleType.KTBusinessLimo.rawValue):
            isPremiumRide = true
        case Int16(VehicleType.KTLuxuryLimo.rawValue):
            isPremiumRide = true
        default:
            isPremiumRide = false
        }
        
        return isPremiumRide
    }
    
    func sTypeVehicleImage(forIndex idx: Int) -> UIImage
    {
        let sType : KTVehicleType = vehicleTypes![idx]
        var imgSType : UIImage = UIImage()
        switch sType.typeId {
        case Int16(VehicleType.KTCityTaxi.rawValue):
            imgSType = UIImage(named: "icon-karwa-taxi")!
        case Int16(VehicleType.KTCityTaxi7Seater.rawValue):
            imgSType = UIImage(named: "icon-family-taxi")!
        case Int16(VehicleType.KTSpecialNeedTaxi.rawValue):
            imgSType = UIImage(named: "icon-accessible-taxi")!
        case Int16(VehicleType.KTStandardLimo.rawValue):
            imgSType = UIImage(named: "icon-standard-limo")!
        case Int16(VehicleType.KTBusinessLimo.rawValue):
            imgSType = UIImage(named: "icon-business-limo")!
        case Int16(VehicleType.KTLuxuryLimo.rawValue):
            imgSType = UIImage(named: "icon-luxury-limo")!
        case Int16(VehicleType.KTIconicLimousine.rawValue):
            imgSType = UIImage(named: "icon-etron")!
        default:
            imgSType = UIImage(named: "icon-karwa-taxi")!
        }
        
        return imgSType
    }
    
    func vTypeViewScroll(currentIdx:Int?)  {
        
        if currentIdx! < (vehicleTypes?.count)!  && selectedVehicleType != VehicleType(rawValue: Int16(vehicleTypes![currentIdx!].typeId))!
        {
            if rebook == false
            {
                selectedVehicleType = VehicleType(rawValue: Int16(vehicleTypes![currentIdx!].typeId))!
            }
            /*else {
             rebook = false
             }*/
            
            if currentBookingStep == BookingStep.step1 {
                
                fetchVehiclesNearCordinates(location: KTLocationManager.sharedInstance.currentLocation)
            }
            else if currentBookingStep == BookingStep.step3 {
                
                (self.delegate as! KTCreateBookingViewModelDelegate).setETAString(etaString: "-- mins to reach")
                
                if (del?.fareDetailVisible())! {
                    if(!isDropAvailable()) {
                        updateFareDetails(vehicleType: vehicleTypes![currentIdx!])
                    }
                    else {
                        
                        updateEstimates(vehicleType: vehicleTypes![currentIdx!])
                    }
                }
            }
            
        }
    }
    
    func vehicleTypeShouldAnimate() -> Bool {
        
        var animate : Bool = true
        if isPickAvailable() {
            
            animate = false
        }
        return animate
    }
    
    func btnPromoTapped()
    {
        removeBooking = false
        (delegate as! KTCreateBookingViewModelDelegate).showPromoInputDialog(currentPromo: promo)
    }
    
    func applyPromoTapped(_ newPromoCode: String)
    {
        if(booking.pickupAddress == nil || booking.pickupAddress == "")
        {
            booking = BookingBean.getBookingEntityFromBooking(bookingBean: self.cloneBooking)
        }
        
        promo = newPromoCode
        
        fetchEstimateForPromo(newPromoCode)
        
    }
    
    func removePromoTapped()
    {
        if(promo.length > 3)
        {
            resetPromo()
            resetPromoOrBaseFare()
        }
    }
    
    func resetPromo()
    {
        promo = ""
        (self.delegate as! KTCreateBookingViewModelDelegate).setPromotionCode(promo: promo)
        self.del?.setPromoButtonLabel(validPromo: promo)
        fetchEstimates()
        (self.delegate as! KTCreateBookingViewModelDelegate).restoreCustomerServiceSelection(animateView: false)
    }
    
    //MARK:- Create Booking
    func btnRequestBookingTapped() {
        if isPickAvailable() {
            if KTAppSessionInfo.currentSession.customerType == CustomerType.CORPORATE {
                //(delegate as! KTCreateBookingViewModelDelegate).showBookingConfirmation()
                (delegate as! KTCreateBookingViewModelDelegate).showCallerIdPopUp()
            }
            else {
                (delegate as! KTCreateBookingViewModelDelegate).showBookingConfirmation()
            }
        } else {
            self.delegate?.showError!(title: "Error", message:"Please provide pickup location")
        }
    }
    
    func bookRide() {
        if isPickAvailable() {
            var vEstimate : KTFareEstimate?
            let bookManager : KTBookingManager = KTBookingManager()
            booking.pickupTime = selectedPickupDateTime
            booking.creationTime = Date()
            booking.pickupMessage = (delegate as! KTCreateBookingViewModelDelegate).hintForPickup()
            booking.vehicleType = Int16(selectedVehicleType.rawValue)
            booking.callerId =  (delegate as! KTCreateBookingViewModelDelegate).callerPhoneNumber()
            if booking.callerId == nil || booking.callerId == "" {
                booking.callerId = KTAppSessionInfo.currentSession.phone
            }
            
            booking.paymentMethod = selectedPaymentMethodId
            var filterBaseFare = vehicleTypes?.filter( { (vtype: KTVehicleType) -> Bool in
                return vtype.typeId == booking.vehicleType
            })
            
            if filterBaseFare != nil && (filterBaseFare?.count)! > 0 {
                booking.toKeyValueBody = (filterBaseFare![0]).toKeyValueBody
            }
            
            if(isDropAvailable()) {
                vEstimate = fetchEstimateId(forVehicleType: selectedVehicleType)
                //                booking.bookingToEstimate = vEstimate
                //                vEstimate?.fareestimateToBooking = booking
                //                booking.estimatedFare = vEstimate?.estimatedFare
            }
            
            delegate?.showProgressHud(show: true, status: "please_dialog_msg_booking_creation".localized())
            bookManager.bookTaxi(job: booking,estimate: vEstimate, promo: promo) { (status, response) in
                self.delegate?.showProgressHud(show: false)
                if status == Constants.APIResponseStatus.SUCCESS {
                    self.removeBooking = false
                    
                    (self.delegate as! KTCreateBookingViewModelDelegate).moveToDetailView()
                }
                else {
                    
                    self.delegate?.showError!(title: response["T"] as! String, message: response["M"] as! String)
                }
            }
        }
        else {
            self.delegate?.showError!(title: "Error", message:"Please provide pickup location")
        }
    }
    
    
    
    //MARK: - Fetch near by vehicle
    @objc func FetchNearByVehicle() {
        self.fetchVehiclesNearCordinates(location: KTLocationManager.sharedInstance.currentLocation)
    }
    
    //MARK:- Location Manager
    static var askedToTurnOnLocaiton : Bool = false
    
    func setupCurrentLocaiton() {
        if KTLocationManager.sharedInstance.locationIsOn() {
            if KTLocationManager.sharedInstance.isLocationAvailable {
                var notification : Notification = Notification(name: Notification.Name(rawValue: Constants.Notification.LocationManager))
                var userInfo : [String :Any] = [:]
                userInfo["location"] = KTLocationManager.sharedInstance.baseLocation
                
                notification.userInfo = userInfo
                //notification.userInfo!["location"] as! CLLocation
                LocationManagerLocaitonUpdate(notification: notification)
            }
            else {
                KTLocationManager.sharedInstance.start()
            }
        }
        else if KTCreateBookingViewModel.askedToTurnOnLocaiton == false{
            (delegate as! KTCreateBookingViewModelDelegate).showAlertForLocationServerOn()
            KTCreateBookingViewModel.askedToTurnOnLocaiton = true
            
        }
    }
    
    //MARK:- Location manager & NearBy vehicles
    
    func isVehicleNearBy() -> Bool {
        var vehicleNearBy : Bool = false
        if self.nearByVehicle.count > 0 {
            vehicleNearBy = true
        }
        return vehicleNearBy
    }
    
    var isFirstZoomDone = false
    
    @objc func LocationManagerLocaitonUpdate(notification: Notification)
    {
        let location : CLLocation = notification.userInfo!["location"] as! CLLocation
        var updateMap = true
        
        if let info = notification.userInfo, let check = info["updateMap"] as? Bool
        {
            updateMap = check
            del?.setETAString(etaString: "")
        }
        
        //Show user Location on map
        if currentBookingStep == BookingStep.step1
        {
            if updateMap
            {
                if(isFirstZoomDone)
                {
                    (self.delegate as! KTCreateBookingViewModelDelegate).updateLocationInMap(location: location, shouldZoomToDefault: false)
                }
                else
                {
                    (self.delegate as! KTCreateBookingViewModelDelegate).updateLocationInMap(location: location, shouldZoomToDefault: true)
                    isFirstZoomDone = true
                }
            }
            
            booking.pickupLocationId = -1
            booking.pickupAddress = UNKNOWN
            booking.pickupLat = location.coordinate.latitude
            booking.pickupLon = location.coordinate.longitude
            
            (self.delegate as! KTCreateBookingViewModelDelegate).setPickUp(pick: booking.pickupAddress!)
            
            //Fetch location name (from Server) for current location.
            self.fetchLocationName(forGeoCoordinate: location.coordinate)
        }
        else if currentBookingStep == BookingStep.step3 && isPickAvailable()
        {
            showCurrentLocationDot(location: location.coordinate)
        }
    }
    
    var destinations = [KTGeoLocation]()
    func fetchDestinations()  {
        
        preloadHomeWork()
        
        (self.delegate as! KTCreateBookingViewModelDelegate).reloadDestinations()
        
        KTBookingManager().address(forLocation: KTLocationManager.sharedInstance.currentLocation.coordinate) { (status, response) in
            if status == Constants.APIResponseStatus.SUCCESS {
                self.parseResponseToDestinations(serverResponse: response[Constants.ResponseAPIKey.Data] as! [KTGeoLocation])
                (self.delegate as! KTCreateBookingViewModelDelegate).reloadDestinations()
            }
        }
    }
    
    func preloadHomeWork()
    {
        let bookmarkManager : KTBookmarkManager = KTBookmarkManager()
        let home : KTBookmark? = bookmarkManager.getHome()
        let work : KTBookmark?  = bookmarkManager.getWork()
        
        var array = [KTGeoLocation]()
        
        if let home = home, let location = home.bookmarkToGeoLocation {
            array.append(location)
        }
        if let work = work, let location = work.bookmarkToGeoLocation {
            array.append(location)
        }
        
        destinations = Array(array.prefix(5))
    }
    
    func parseResponseToDestinations(serverResponse locs: [KTGeoLocation]){
        let bookmarkManager : KTBookmarkManager = KTBookmarkManager()
        let home : KTBookmark? = bookmarkManager.getHome()
        let work : KTBookmark?  = bookmarkManager.getWork()
        
        var array = [KTGeoLocation]()
        let popular = locs.filter({ $0.type == geoLocationType.Popular.rawValue})
        let recent = locs.filter({ $0.type == geoLocationType.Recent.rawValue})
        
        if let home = home, let location = home.bookmarkToGeoLocation {
            array.append(location)
        }
        if let work = work, let location = work.bookmarkToGeoLocation {
            array.append(location)
        }
        let recentMaxCount = (destinations.count == 2) ? 2 : 3
        for index in 0..<recent.count {
            if index < recentMaxCount {
                array.append(recent[index])
            }
        }
        array.append(contentsOf: popular)
        destinations = Array(array.prefix(5))
    }
    
    private func showCurrentLocationDot(location: CLLocationCoordinate2D) {
        
        if location.distance(from: CLLocationCoordinate2D(latitude: booking.pickupLat, longitude: booking.pickupLon)) > 1000 {
            
            (delegate as! KTCreateBookingViewModelDelegate).showCurrentLocationDot(show: true)
        }
        else {
            (delegate as! KTCreateBookingViewModelDelegate).showCurrentLocationDot(show: false)
        }
    }
    
    private func fetchVehiclesNearCordinates(location:CLLocation) {
        KTBookingManager.init().vehiclesNearCordinate(coordinate: location.coordinate, vehicleType: selectedVehicleType, completion:{
            (status,response) in
            if status == Constants.APIResponseStatus.SUCCESS {
                self.nearByVehicle.removeAll()
                self.nearByVehicle.append(contentsOf: self.parseVehicleTrack(response))
                
                //Add User current location.
                if self.nearByVehicle.count > 0
                {
                    self.nearByVehicle.append(self.userCurrentLocaitonMarker())
                    self.fetchETA(vehicles: self.nearByVehicle)
                }
                else
                {
                    (self.delegate as! KTCreateBookingViewModelDelegate).setETAString(etaString: "str_no_ride_found".localized())
                }
                
                if(self.currentBookingStep != BookingStep.step3)
                {
                    if self.delegate != nil && (self.delegate as! KTCreateBookingViewModelDelegate).responds(to: Selector(("addMarkerOnMapWithVTrack:")))
                    {
                        (self.delegate as! KTCreateBookingViewModelDelegate).addOrRemoveOrMoveMarkerOnMap(vTrack: self.nearByVehicle, vehicleType: self.selectedVehicleType.rawValue)
                    }
                }
            }
        })
    }
    
    private func userCurrentLocaitonMarker() -> VehicleTrack {
        
        let track : VehicleTrack = VehicleTrack()
        track.position = KTLocationManager.sharedInstance.currentLocation.coordinate
        track.trackType = VehicleTrackType.user
        return track
    }
    
    private func parseVehicleTrack(_ respons: [AnyHashable: Any]) -> Array<VehicleTrack> {
        var vTrack: [VehicleTrack] = []
        
        let responseArray: Array<[AnyHashable: Any]> = respons[Constants.ResponseAPIKey.Data] as! Array<[AnyHashable: Any]>
        //respons[Constants.ResponseAPIKey.Data] as! [AnyHashable: Any].forEach { track in
        responseArray.forEach { rtrack in
            let track : VehicleTrack = VehicleTrack()
            track.vehicleNo = rtrack["VehicleNo"] as! String
            track.position = CLLocationCoordinate2D(latitude: (rtrack["Lat"] as? CLLocationDegrees)!, longitude: (rtrack["Lon"] as? CLLocationDegrees)!)
            track.vehicleType = rtrack["VehicleType"] as! Int
            track.bearing = (rtrack["Bearing"] as! NSNumber).floatValue
            track.eta = rtrack["Eta"] as? Int64 ?? 0
            track.etaText = rtrack["EtaText"] as? String ?? "txt_not_available".localized()
            track.trackType = VehicleTrackType.vehicle
            vTrack.append(track)
        }
        return vTrack
    }
    
    private func fetchLocationName(forGeoCoordinate coordinate: CLLocationCoordinate2D) {
        
        KTBookingManager().address(forLocation: coordinate, Limit: 1) { (status, response) in
            if status == Constants.APIResponseStatus.SUCCESS && response[Constants.ResponseAPIKey.Data] != nil && (response[Constants.ResponseAPIKey.Data] as! [KTGeoLocation]).count > 0{
                
                
                let pAddress : KTGeoLocation = (response[Constants.ResponseAPIKey.Data] as! [KTGeoLocation])[0]
                self.booking.pickupLocationId = pAddress.locationId
                self.booking.pickupAddress = pAddress.name
                self.booking.pickupLat = pAddress.latitude
                self.booking.pickupLon = pAddress.longitude
                DispatchQueue.main.async {
                    //self.delegate?.userIntraction(enable: true)
                    if self.delegate != nil {
                        (self.delegate as! KTCreateBookingViewModelDelegate).setPickUp(pick: self.booking.pickupAddress)
                    }
                }
            }
        }
    }
    
    func prepareToMoveAddressPicker() {
        //currentBookingStep = BookingStep.step2
        dropOffBtnText = "txt_set_destination".localized()
    }
    
    func setRemoveBookingOnReset(removeBookingOnReset : Bool) {
        self.removeBookingOnReset = removeBookingOnReset
    }
    
    public func resetInProgressBooking()
    {
        isAdvanceBooking = false
        if(removeBookingOnReset)
        {
            self.removeBookingOnReset = true
            booking.mr_deleteEntity()
        }
        
        booking = KTBookingManager().booking()
        
        currentBookingStep = BookingStep.step1  //Booking will strat with step 1
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.LocationManagerLocaitonUpdate(notification:)), name: Notification.Name(Constants.Notification.LocationManager), object: nil)
        
        setupCurrentLocaiton()
        
        //        timerFetchNearbyVehicle = Timer.scheduledTimer(timeInterval: TimeInterval(TIMER_INTERVAL), target: self, selector: #selector(KTCreateBookingViewModel.FetchNearByVehicle), userInfo: nil, repeats: true)
        
        (delegate as! KTCreateBookingViewModelDelegate).hideCancelBookingBtn()
        (delegate as! KTCreateBookingViewModelDelegate).showCurrentLocationDot(show: true)
        (delegate as! KTCreateBookingViewModelDelegate).clearMap()
        (delegate as! KTCreateBookingViewModelDelegate).setDropOff(drop: "str_set_destination".localized())
        
        resetPromo()
        
        del?.pickDropBoxStep1()
        del?.hideRequestBookingBtn()
        del?.hideFareBreakdown()
        FetchNearByVehicle()
        resetPromoOrBaseFare()
    }
    
    func resetPromoOrBaseFare()
    {
        if(isBaseFareChangedForPromo)
        {
            MagicalRecord.save({ (context) in
                KTBaseTrariff.mr_truncateAll(in: context)
                KTKeyValue.mr_truncateAll(in: context)
                KTDALManager().resetSyncTime(forKey: BOOKING_SYNC_TIME)
            }, completion: { (changed, error) in
                if let _ = error
                {
                    print("Error truncating BaseTariff: \(String(describing: error?.localizedDescription))")
                } else
                {
                    isBaseFareChangedForPromo = false
                    KTVehicleTypeManager().fetchBasicTariffFromServer
                    { (status, response) in
                        self.vehicleTypes = nil
                        self.vehicleTypes = KTVehicleTypeManager().VehicleTypes()
                        self.setupVehicleCategories()
                        self.modifiedVehicleTypes = KTVehicleTypeManager().VehicleTypes()
                        self.estimates = KTVehicleTypeManager().estimates()
                        self.del?.updateVehicleTypeList()
                        self.encodedPath = ""
                        self.drawDirectionOnMap(encodedPath: "")
                        self.fetchEstimates()
                    }
                }
            })
        }
        else
        {
            fetchEstimates()
        }
    }
}


