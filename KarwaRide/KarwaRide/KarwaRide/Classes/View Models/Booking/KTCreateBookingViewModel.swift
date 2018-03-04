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
    func updateCurrentAddress(addressName:String)
    func hintForPickup() -> String
    func setPickUp(pick: String?)
    func setDropOff(drop: String?)
    func setPickDate(date: String)
    func showBookingConfirmation()
    func showRequestBookingBtn()
    func updatePickDropBox()
    func addMarkerOnMap(location: CLLocationCoordinate2D, image: UIImage)
    func addPointsOnMap(points : String)
    func clearMap()
    func showCurrentLocationDot(show : Bool)
    func moveToDetailView()
    func showAlertForLocationServerOn()
}

let CHECK_DELAY = 90.0
enum BookingStep {
    case step1
    case step2
    case step3
}

class KTCreateBookingViewModel: KTBaseViewModel {
    
    var currentBookingStep : BookingStep = BookingStep.step1  //Booking will strat with step 1
    var vehicleTypes : [KTVehicleType]?
    public var pickUpAddress : KTGeoLocation?  
    public var dropOffAddress : KTGeoLocation?
    
    private var nearByVehicle: [VehicleTrack] = []
    
    var selectedVehicleType : VehicleType = VehicleType.KTCityTaxi
    var selectedPickupDateTime : Date = Date()
    var dropOffBtnText = "Set Destination, Start your booking"
    var timerFetchNearbyVehicle : Timer = Timer()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.fetchVechicleTypes()
        
    }
    
    override func viewWillAppear() {
        
        setupCurrentLocaiton()
        
        super.viewWillAppear()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.LocationManagerLocaitonUpdate(notification:)), name: Notification.Name(Constants.Notification.LocationManager), object: nil)
        
       
        if currentBookingStep == BookingStep.step1 {
            timerFetchNearbyVehicle = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(KTCreateBookingViewModel.FetchNearByVehicle), userInfo: nil, repeats: true)
            if pickUpAddress == nil {
                
                //delegate?.userIntraction(enable: false)
            }
        }
        else if currentBookingStep == BookingStep.step3 {
            
            registerForMinuteChange()
            drawDirectionOnMap()
            showCurrentLocationDot(location: KTLocationManager.sharedInstance.currentLocation.coordinate)
        }
    }
    
    override func viewWillDisappear() {
        
        super.viewWillDisappear()
        NotificationCenter.default.removeObserver(self)
        timerFetchNearbyVehicle.invalidate()
    }
    
    //MARK: - Navigation to Address Picker
    func btnPickupAddTapped(){
        
        delegate?.performSegue(name: "segueBookingToAddresspicker")
    }
    
    func btnDropAddTapped() {
        
        delegate?.performSegue(name: "segueBookingToAddresspicker")
    }
    //MARK: - Navigation view functions
    func dismiss() {
        currentBookingStep = BookingStep.step3
        
        if pickUpAddress != nil {
            
            (delegate as! KTCreateBookingViewModelDelegate).setPickUp(pick: pickUpAddress?.name)
        }
        
        if(dropOffAddress != nil) {
            
            (delegate as! KTCreateBookingViewModelDelegate).setDropOff(drop: dropOffAddress?.name)
        }
        else {
            
            (delegate as! KTCreateBookingViewModelDelegate).setDropOff(drop: dropOffBtnText)
        }
        
        updateUI()
        
        delegate?.dismiss()
    }
    
    func updateUI() {
        (delegate as! KTCreateBookingViewModelDelegate).showRequestBookingBtn()
        (delegate as! KTCreateBookingViewModelDelegate).updatePickDropBox()
    }
    
    //MARK: - Direction / Polyline on Map
    private func drawDirectionOnMap() {
        
        (delegate as! KTCreateBookingViewModelDelegate).clearMap()
        
        if pickUpAddress != nil {
        //Setting Pick marker
            (delegate as! KTCreateBookingViewModelDelegate).addMarkerOnMap(location:CLLocationCoordinate2D(latitude: (pickUpAddress?.latitude)!,longitude: (pickUpAddress?.longitude)!) , image: UIImage(named: "BookingMapDirectionPickup")!)
        }
        
        if dropOffAddress != nil {
        //Setting drop
            //dropOffAddress?.latitude = 25.275636
            //dropOffAddress?.longitude = 51.489212
            
            (delegate as! KTCreateBookingViewModelDelegate).addMarkerOnMap(location:CLLocationCoordinate2D(latitude: (dropOffAddress?.latitude)!,longitude: (dropOffAddress?.longitude)!) , image: UIImage(named: "BookingMapDirectionDropOff")!)
        }
        
        if pickUpAddress != nil && dropOffAddress != nil {
            drawPath()
        }
    }
    
    func drawPath()
    {
        let origin = String(format:"%f", (pickUpAddress?.latitude)!) + "," + String(format:"%f", (pickUpAddress?.longitude)!)
        //"\(String(describing: pickUpAddress?.latitude)),\(String(describing: pickUpAddress?.longitude))"
        let destination = String(format:"%f", (dropOffAddress?.latitude)!) + "," + String(format:"%f", (dropOffAddress?.longitude)!)
        //"\(String(describing: dropOffAddress?.latitude)),\(String(describing: dropOffAddress?.longitude))"
        
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=AIzaSyCcK4czilOp9CMilAGmbq47i6HQk18q7Tw"
        
        Alamofire.request(url, method: .get, parameters: nil, headers: nil).responseJSON { (response:DataResponse<Any>) in
            print(response)
            
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
        bounds = bounds.includingCoordinate(CLLocationCoordinate2D(latitude: (pickUpAddress?.latitude)!,longitude: (pickUpAddress?.longitude)!))
        bounds = bounds.includingCoordinate(CLLocationCoordinate2D(latitude: (dropOffAddress?.latitude)!,longitude: (dropOffAddress?.longitude)!))
        
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
    
    private func fetchVechicleTypes() {
        let vTypeManager: KTVehicleTypeManager = KTVehicleTypeManager()
        vehicleTypes = vTypeManager.VehicleTypes()
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
    
    func sTypeBaseFare(forIndex idx: Int) -> String {
        let vType : KTVehicleType = vehicleTypes![idx]
        return String(vType.typeBaseFare)
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
    //MARK:- Create Booking
    func btnRequestBookingTapped() {
        
        (delegate as! KTCreateBookingViewModelDelegate).showBookingConfirmation()
    }
    
    func bookRide() {
        let bookManager : KTBookingManager = KTBookingManager()
        let booking : KTBooking = bookManager.booking(pickUp: pickUpAddress, dropOff: dropOffAddress)
        booking.pickupTime = selectedPickupDateTime
        booking.creationTime = Date()
        booking.pickupHint = (delegate as! KTCreateBookingViewModelDelegate).hintForPickup()
        booking.vehicleType = Int16(selectedVehicleType.rawValue)
        booking.callerId = KTAppSessionInfo.currentSession.phone
        
        delegate?.showProgressHud(show: true, status: "Booking a ride")
        bookManager.bookTaxi(job: booking) { (status, response) in
            self.delegate?.showProgressHud(show: false)
            if status == Constants.APIResponseStatus.SUCCESS {
                (self.delegate as! KTCreateBookingViewModelDelegate).moveToDetailView()
            }
            else {
                self.delegate?.showError!(title: response["T"] as! String, message: response["M"] as! String)
                
            }
        }
    }
    
    func vTypeViewScroll(currentIdx:Int?)  {
        
        if currentIdx! < (vehicleTypes?.count)!  && selectedVehicleType != VehicleType(rawValue: Int(vehicleTypes![currentIdx!].typeId))!{
            
            selectedVehicleType = VehicleType(rawValue: Int(vehicleTypes![currentIdx!].typeId))!
            
            if currentBookingStep == BookingStep.step1 {
                
                fetchVehiclesNearCordinates(location: KTLocationManager.sharedInstance.currentLocation)
            }
            
        }
    }
    
    func vehicleTypeShouldAnimate() -> Bool {
        
        var animate : Bool = true
        if pickUpAddress != nil {
            
            animate = false
        }
        return animate
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
            
            if pickUpAddress == nil{
                
                pickUpAddress = KTBookingManager().goeLocation(forLocation: location.coordinate)
                (self.delegate as! KTCreateBookingViewModelDelegate).updateCurrentAddress(addressName: (self.pickUpAddress?.name!)!)
            }
            
            //Fetch location name (from Server) for current location.
            self.fetchLocationName(forGeoCoordinate: location.coordinate)
        }
        else if currentBookingStep == BookingStep.step3 && pickUpAddress != nil {
            showCurrentLocationDot(location: location.coordinate)
        }
        
    }
    
    private func showCurrentLocationDot(location: CLLocationCoordinate2D) {
        
        if location.distance(from: CLLocationCoordinate2D(latitude: (pickUpAddress?.latitude)!, longitude: (pickUpAddress?.longitude)!)) > 1000 {
            
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
                
                (self.delegate as! KTCreateBookingViewModelDelegate).addMarkerOnMap(vTrack: self.nearByVehicle)
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
                
                self.pickUpAddress = (response[Constants.ResponseAPIKey.Data] as! [KTGeoLocation])[0]
                DispatchQueue.main.async {
                    //self.delegate?.userIntraction(enable: true)
                    (self.delegate as! KTCreateBookingViewModelDelegate).updateCurrentAddress(addressName: (self.pickUpAddress?.name!)!)
                }
            }
        }
    }
    
    func prepareToMoveAddressPicker() {
        currentBookingStep = BookingStep.step2
        dropOffBtnText = "Destination not set"
    }
}


