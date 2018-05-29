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

protocol KTCreateBookingViewModelDelegate: KTViewModelDelegate {
    func updateLocationInMap(location:CLLocation)
    func addMarkerOnMap(vTrack:[VehicleTrack])
    func hintForPickup() -> String
    func callerPhoneNumber() -> String?
    func setPickUp(pick: String?)
    func setDropOff(drop: String?)
    func setPickDate(date: String)
    func showBookingConfirmation()
    func showCallerIdPopUp()
    func showRequestBookingBtn()
    func hideRequestBookingBtn()
    func pickDropBoxStep3()
    func pickDropBoxStep1()
    //func updatePickDropBox()
    func setVehicleType(idx: Int)
    func addMarkerOnMap(location: CLLocationCoordinate2D, image: UIImage)
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
}

let CHECK_DELAY = 90.0
enum BookingStep {
    case step1
    case step2
    case step3
}

let UNKNOWN : String = "Unknown"

class KTCreateBookingViewModel: KTBaseViewModel {
    
    var currentBookingStep : BookingStep = BookingStep.step1  //Booking will strat with step 1
    var vehicleTypes : [KTVehicleType]?
    //public var pickUpAddress : KTGeoLocation?
    //public var dropOffAddress : KTGeoLocation?
    
    public var estimates : [KTFareEstimate]?
    public var isEstimeting : Bool = false
    
    private var nearByVehicle: [VehicleTrack] = []
    
    var selectedVehicleType : VehicleType = VehicleType.KTCityTaxi
    var selectedPickupDateTime : Date = Date()
    var dropOffBtnText = "Set Destination, Start your booking"
    var timerFetchNearbyVehicle : Timer = Timer()
    
    var rebook: Bool = false
    
    var del : KTCreateBookingViewModelDelegate?
    
    var booking : KTBooking = KTBookingManager().booking()
    var removeBooking = true
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        del = self.delegate as? KTCreateBookingViewModelDelegate
        
        self.syncApplicationData()
        vehicleTypes = KTVehicleTypeManager().VehicleTypes()
        del?.pickDropBoxStep1()
        del?.hideRequestBookingBtn()
        
        if booking.bookingId != nil && booking.bookingId != "" {
            rebook = true
            updateForRebook()
        }
    }
    
    override func viewWillAppear() {
        removeBooking = true
        setupCurrentLocaiton()
        
        super.viewWillAppear()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.LocationManagerLocaitonUpdate(notification:)), name: Notification.Name(Constants.Notification.LocationManager), object: nil)
        
        
        if currentBookingStep == BookingStep.step1 {
            
            timerFetchNearbyVehicle = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(KTCreateBookingViewModel.FetchNearByVehicle), userInfo: nil, repeats: true)
        }
        else if currentBookingStep == BookingStep.step3 {
            
            fetchEstimates()
            registerForMinuteChange()
            drawDirectionOnMap()
            showCurrentLocationDot(location: KTLocationManager.sharedInstance.currentLocation.coordinate)
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        rebook = false
    }
    
    override func viewWillDisappear() {
        if removeBooking {
            booking.mr_deleteEntity()
        }
        super.viewWillDisappear()
        NotificationCenter.default.removeObserver(self)
        timerFetchNearbyVehicle.invalidate()
    }
    
    //MARK:- Address picker setting pick drop
    func setPickAddress(pAddress : KTGeoLocation) {
        booking.pickupLocationId = pAddress.locationId
        booking.pickupAddress = pAddress.name
        booking.pickupLat = pAddress.latitude
        booking.pickupLon = pAddress.longitude
    }
    
    func setDropAddress(dAddress : KTGeoLocation) {
        booking.dropOffLocationId = dAddress.locationId
        booking.dropOffAddress = dAddress.name
        booking.dropOffLat = dAddress.latitude
        booking.dropOffLon = dAddress.longitude
    }
    
    //MARK:-
    private func locationAvailable(locationName: String?) -> Bool {
        guard locationName != nil, locationName != ""  else {
            return false
        }
        return true
        
    }
    func isPickAvailable() -> Bool {
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
    
    func dropOffAddress() -> KTGeoLocation? {
        guard  isDropAvailable() else {
            return nil
        }
        return KTBookingManager().geoLocaiton(forLocationId: booking.dropOffLocationId, latitude: booking.dropOffLat, longitude: booking.dropOffLon, name: booking.dropOffAddress!)
        
    }
    
    func updateForRebook() {
        currentBookingStep = BookingStep.step3
        if isPickAvailable() {
            (self.delegate as! KTCreateBookingViewModelDelegate).setPickUp(pick: booking.pickupAddress!)
        }
        
        if isDropAvailable() {
            (self.delegate as! KTCreateBookingViewModelDelegate).setDropOff(drop: booking.dropOffAddress!)
        }
        
        selectedVehicleType = VehicleType(rawValue: booking.vehicleType)!
        
        (self.delegate as! KTCreateBookingViewModelDelegate).setVehicleType(idx: idxToSelectVehicleType())
        
        updateUI()
    }
    //MARK:- Sync Applicaiton Data
    func syncApplicationData() {
        KTAppDataSyncManager().syncApplicationData()
    }
    
    //MARK: - FareBreakdown
    
    func vehicleTypeTapped(idx: Int) {
        
        if currentBookingStep == BookingStep.step3 {
            if(!(del?.fareDetailVisible())!) {
                //estimated fare view is not on screen right now
                let vType : KTVehicleType = vehicleTypes![idx]
                if(!isDropAvailable()) {
                    showFareBreakDown(vehicleType: vType)
                }
                else {
                    
                    showEstimate(vehicleType: vType)
                }
            }
            else {
                //Means view is on screen
                del?.hideFareBreakdown(animated: true)
            }
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
        delegate?.performSegue(name: "segueBookingToAddresspickerForDropoff")
    }
    //MARK: - Navigation view functions
    func dismiss() {
        currentBookingStep = BookingStep.step3
        
        if booking.pickupAddress != nil || booking.pickupAddress != "" {
            
            (delegate as! KTCreateBookingViewModelDelegate).setPickUp(pick: booking.pickupAddress)
        }
        
        if(booking.dropOffAddress != nil || booking.dropOffAddress != "") {
            
            (delegate as! KTCreateBookingViewModelDelegate).setDropOff(drop: booking.dropOffAddress)
        }
        else {
            
            (delegate as! KTCreateBookingViewModelDelegate).setDropOff(drop: dropOffBtnText)
        }
        
        updateUI()
        
        delegate?.dismiss()
    }
    
    func updateUI() {
        (delegate as! KTCreateBookingViewModelDelegate).showRequestBookingBtn()
        (delegate as! KTCreateBookingViewModelDelegate).pickDropBoxStep3()
    }
    
    //MARK: - Estimates
    private func fetchEstimates() {
        if booking.pickupAddress != nil && booking.dropOffAddress != nil {
            isEstimeting = true
            del?.updateVehicleTypeList()
            
            KTBookingManager().fetchEstimate(pickup: CLLocationCoordinate2D(latitude: booking.pickupLat, longitude: booking.pickupLon), dropoff: CLLocationCoordinate2D(latitude: booking.dropOffLat,longitude: booking.dropOffLon), time: selectedPickupDateTime.serverTimeStamp(), complition: { (status, response) in
                self.isEstimeting = false
                if status == Constants.APIResponseStatus.SUCCESS {
                    self.estimates = KTBookingManager().estimates()
                    self.del?.updateVehicleTypeList()
                    
                }
                else {
                    if self.estimates != nil{
                        self.estimates?.removeAll()
                        self.estimates = nil
                    }
                }
            })
        }
        else if estimates != nil{
            estimates?.removeAll()
            estimates = nil
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
    
    func vTypeBaseFareOrEstimate(forIndex idx: Int) -> String {
        var fareOrEstimate : String = ""
        let vType : KTVehicleType = vehicleTypes![idx]
        if isEstimeting == false {
            if estimates == nil || estimates?.count == 0 {
                fareOrEstimate =  vType.typeBaseFare!
            }
            else {
                
                let estimate : KTFareEstimate? = self.estimate(forVehicleType: vType.typeId)
                if estimate != nil {
                    fareOrEstimate = (estimate?.estimatedFare!)!
                }
            }
        }
        return fareOrEstimate
    }
    
    func FareEstimateTitle() -> String {
        
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
    private func drawDirectionOnMap() {
        
        (delegate as! KTCreateBookingViewModelDelegate).clearMap()
        if isPickAvailable() && isDropAvailable() {
            //if both pickup and dropoff are available then draw path.
            drawPath()
        }
        else {
            //else draw point what ever is available
            if isPickAvailable() {
                //Setting Pick marker
                (delegate as! KTCreateBookingViewModelDelegate).addMarkerOnMap(location:CLLocationCoordinate2D(latitude: booking.pickupLat,longitude: booking.pickupLon) , image: UIImage(named: "BookingMapDirectionPickup")!)
            }
            
            if isDropAvailable() {
                //Setting drop
                //dropOffAddress?.latitude = 25.275636
                //dropOffAddress?.longitude = 51.489212
                
                (delegate as! KTCreateBookingViewModelDelegate).addMarkerOnMap(location:CLLocationCoordinate2D(latitude: booking.dropOffLat,longitude: booking.dropOffLon) , image: UIImage(named: "BookingMapDirectionDropOff")!)
            }
        }
    }
    
    func drawPath(){
        
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
    
    func directionBounds() -> GMSCoordinateBounds
    {
        
        var bounds = GMSCoordinateBounds()
        bounds = bounds.includingCoordinate(CLLocationCoordinate2D(latitude: booking.pickupLat,longitude: booking.pickupLon))
        bounds = bounds.includingCoordinate(CLLocationCoordinate2D(latitude: booking.dropOffLat,longitude: booking.dropOffLon))
        
        return bounds
    }
    
    //MARK: - Minute Change
    private func registerForMinuteChange() {
        
        setPickupDate(date: Date())
        KTTimer.sharedInstance.startMinTimer()
        NotificationCenter.default.addObserver(self, selector: #selector(self.MinuteChanged(notification:)), name: Notification.Name(Constants.Notification.MinuteChanged), object: nil)
    }
    
    private func unregisterForMinuteChange() {
        KTTimer.sharedInstance.stoprMinTimer()
    }
    
    @objc func MinuteChanged(notification: Notification) {
        
        if selectedPickupDateTime.timeIntervalSinceNow < CHECK_DELAY {
            //Update UI as its current time.
            //updateUIForCurrentDate()
            setPickupDate(date: Date())
            
        }
    }
    
    func setPickupDateForAdvJob(date: Date)  {
        
        setPickupDate(date: date)
        fetchEstimates()
        
    }
    func setPickupDate(date: Date)  {
        selectedPickupDateTime = date
        updateUI(forDate: selectedPickupDateTime)
    }
    
    func updateUI(forDate date: Date) {
        
        let formatedDate : String = formatedDateForUI(date: date)
        (delegate as! KTCreateBookingViewModelDelegate).setPickDate(date: formatedDate)
    }
    
    func formatedDateForUI(date: Date) -> String {
        
        var datePart : String = ""
        if date.isToday {
            
            datePart = "Today"
        }
        else {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            datePart = dateFormatter.string(from: date)
        }
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mma"
        
        let time = "\(datePart), \(timeFormatter.string(from: date))"
        
        return time
    }
    
    //MARK:-  Vehicle Types
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
        return vType.typeName!
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
    
    func sTypeBackgroundImage(forIndex idx: Int) -> UIImage {
        let sType : KTVehicleType = vehicleTypes![idx]
        var imgBg : UIImage = UIImage()
        switch sType.typeId {
        case Int16(VehicleType.KTCityTaxi.rawValue):
            imgBg = UIImage(named: "BookingCardTaxiBox")!
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
    
    func sTypeVehicleImage(forIndex idx: Int) -> UIImage {
        let sType : KTVehicleType = vehicleTypes![idx]
        var imgSType : UIImage = UIImage()
        switch sType.typeId {
        case Int16(VehicleType.KTCityTaxi.rawValue):
            imgSType = UIImage(named: "BookingCardTaxiIco")!
        case Int16(VehicleType.KTStandardLimo.rawValue):
            imgSType = UIImage(named: "BookingCardStandardIco")!
        case Int16(VehicleType.KTBusinessLimo.rawValue):
            imgSType = UIImage(named: "BookingCardBusinessIco")!
        case Int16(VehicleType.KTLuxuryLimo.rawValue):
            imgSType = UIImage(named: "BookingCardLuxuryIco")!
        default:
            imgSType = UIImage(named: "BookingCardTaxiIco")!
        }
        
        return imgSType
    }
    
    func vTypeViewScroll(currentIdx:Int?)  {
        
        if currentIdx! < (vehicleTypes?.count)!  && selectedVehicleType != VehicleType(rawValue: Int16(vehicleTypes![currentIdx!].typeId))!{
            
            if rebook == false {
                selectedVehicleType = VehicleType(rawValue: Int16(vehicleTypes![currentIdx!].typeId))!
            }
            /*else {
             rebook = false
             }*/
            
            if currentBookingStep == BookingStep.step1 {
                
                fetchVehiclesNearCordinates(location: KTLocationManager.sharedInstance.currentLocation)
            }
            else if currentBookingStep == BookingStep.step3 {
                
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
    
    //MARK:- Create Booking
    func btnRequestBookingTapped() {
        if KTAppSessionInfo.currentSession.customerType == CustomerType.CORPORATE {
            //(delegate as! KTCreateBookingViewModelDelegate).showBookingConfirmation()
            (delegate as! KTCreateBookingViewModelDelegate).showCallerIdPopUp()
        }
        else {
            (delegate as! KTCreateBookingViewModelDelegate).showBookingConfirmation()
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
            
            if(isDropAvailable()) {
                vEstimate = fetchEstimateId(forVehicleType: selectedVehicleType)
//                booking.bookingToEstimate = vEstimate
//                vEstimate?.fareestimateToBooking = booking
//                booking.estimatedFare = vEstimate?.estimatedFare
            }
            
            delegate?.showProgressHud(show: true, status: "Booking a ride")
            bookManager.bookTaxi(job: booking,estimate: vEstimate) { (status, response) in
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
                userInfo["location"] = KTLocationManager.sharedInstance.currentLocation
                
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
    
    @objc func LocationManagerLocaitonUpdate(notification: Notification){
        
        let location : CLLocation = notification.userInfo!["location"] as! CLLocation
        //Show user Location on map
        if currentBookingStep == BookingStep.step1 {
            (self.delegate as! KTCreateBookingViewModelDelegate).updateLocationInMap(location: location)
            
            if booking.pickupAddress == nil || booking.pickupAddress == "" {
                
                //pickUpAddress = KTBookingManager().goeLocation(forLocation: location.coordinate)
                booking.pickupLocationId = -1
                booking.pickupAddress = UNKNOWN
                booking.pickupLat = location.coordinate.latitude
                booking.pickupLon = location.coordinate.longitude
                (self.delegate as! KTCreateBookingViewModelDelegate).setPickUp(pick: booking.pickupAddress!)
            }
            
            //Fetch location name (from Server) for current location.
            self.fetchLocationName(forGeoCoordinate: location.coordinate)
        }
        else if currentBookingStep == BookingStep.step3 && isPickAvailable() {
            showCurrentLocationDot(location: location.coordinate)
        }
        
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
                self.nearByVehicle = self.parseVehicleTrack(response)
                
                //Add User current location.
                if self.nearByVehicle.count > 0 {
                    self.nearByVehicle.append(self.userCurrentLocaitonMarker())
                }
                
                
                if self.delegate != nil && (self.delegate as! KTCreateBookingViewModelDelegate).responds(to: Selector(("addMarkerOnMapWithVTrack:"))) {
                    (self.delegate as! KTCreateBookingViewModelDelegate).addMarkerOnMap(vTrack: self.nearByVehicle)
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
            track.bearing = rtrack["Bearing"] as! Float
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
        currentBookingStep = BookingStep.step2
        dropOffBtnText = "Destination not set"
    }
}


