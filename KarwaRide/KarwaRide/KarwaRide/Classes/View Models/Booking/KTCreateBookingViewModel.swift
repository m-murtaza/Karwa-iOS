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


protocol KTCreateBookingViewModelDelegate: KTViewModelDelegate {
    func updateLocationInMap(location:CLLocation)
    func addMarkerOnMap(vTrack:[VehicleTrack])
    func updateCurrentAddress(addressName:String)
    func pickUpAdd() -> KTGeoLocation?
    func dropOffAdd() -> KTGeoLocation?
    func hintForPickup() -> String
    func setPickUp(pick: String?)
    func setDropOff(drop: String?)
    func setPickDate(date: String)
    func showBookingConfirmation()
    
}

let CHECK_DELAY = 90.0

class KTCreateBookingViewModel: KTBaseViewModel {
    
    
    var vehicleTypes : [KTVehicleType]?
    private var pickUpAddress : KTGeoLocation?
    private var dropOffAddress : KTGeoLocation?
    
    var selectedVehicleType : VehicleType = VehicleType.KTCityTaxi
    var selectedPickupDateTime : Date = Date()
    var dropOffBtnText = "Set Destination, Start your booking"
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.fetchVechicleTypes()
        KTLocationManager.sharedInstance.start()
        
    }
    
    override func viewWillAppear() {
        
        super.viewWillAppear()
        NotificationCenter.default.addObserver(self, selector: #selector(self.LocationManagerLocaitonUpdate(notification:)), name: Notification.Name(Constants.Notification.LocationManager), object: nil)
        
        pickUpAddress = (delegate as! KTCreateBookingViewModelDelegate).pickUpAdd()
        dropOffAddress = (delegate as! KTCreateBookingViewModelDelegate).dropOffAdd()
        
        if pickUpAddress != nil {
            
            (delegate as! KTCreateBookingViewModelDelegate).setPickUp(pick: pickUpAddress?.name)
        }
        
        if(dropOffAddress != nil) {
            
            (delegate as! KTCreateBookingViewModelDelegate).setDropOff(drop: dropOffAddress?.name)
        }
        else {
            
            (delegate as! KTCreateBookingViewModelDelegate).setDropOff(drop: dropOffBtnText)
        }
        
        registerForMinuteChange()
    }
    
    override func viewWillDisappear() {
        
        super.viewWillDisappear()
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK:- Minute Change
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
    func vTypeTitle(forIndex idx: Int) -> String {
        let vType : KTVehicleType = vehicleTypes![idx]
        return vType.typeName!
    }
    
    func vTypeBaseFare(forIndex idx: Int) -> String {
        let vType : KTVehicleType = vehicleTypes![idx]
        return String(vType.typeBaseFare)
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
        
        bookManager.bookTaxi(job: booking) { (status, response) in
            print(response)
        }
    }
    
    func vTypeViewScroll(currentIdx:Int?)  {
        
        if currentIdx! < (vehicleTypes?.count)!  && selectedVehicleType != VehicleType(rawValue: Int(vehicleTypes![currentIdx!].typeId))!{
            
                selectedVehicleType = VehicleType(rawValue: Int(vehicleTypes![currentIdx!].typeId))!
            fetchVehiclesNearCordinates(location: KTLocationManager.sharedInstance.currentLocation)
        }
    }
    
    //MARK:- Location manager
    @objc func LocationManagerLocaitonUpdate(notification: Notification){
        
        let location : CLLocation = notification.userInfo!["location"] as! CLLocation
        //Show user Location on map
        (self.delegate as! KTCreateBookingViewModelDelegate).updateLocationInMap(location: location)
        
        //Fetch location name (from Server) for current location.
        self.fetchLocationName(forGeoCoordinate: location.coordinate)
        
        //Fetch Vehicles to show on map
        self.fetchVehiclesNearCordinates(location: location)
    }
    
    var oneTimeCheck : Bool = true
    private func fetchVehiclesNearCordinates(location:CLLocation) {
        
        print("- - - - Fetch vehicle called - - - - ")
        //if oneTimeCheck {
            //Righ now allow only one time.
          //  oneTimeCheck = false
            KTBookingManager.init().vehiclesNearCordinate(coordinate: location.coordinate, vehicleType: selectedVehicleType, completion:{
            (status,response) in
                if status == Constants.APIResponseStatus.SUCCESS {
                    var vTrack: [VehicleTrack] = self.parseVehicleTrack(response)
                    
                    //Add User current location.
                    vTrack.append(self.userCurrentLocaitonMarker())
                    
                    (self.delegate as! KTCreateBookingViewModelDelegate).addMarkerOnMap(vTrack: vTrack)
                }
            })
        //}
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
                    
                    (self.delegate as! KTCreateBookingViewModelDelegate).updateCurrentAddress(addressName: (self.pickUpAddress?.name!)!)
                }
                
                
            }
        }
    }
    
    func prepareToMoveAddressPicker(addPickerController: KTAddressPickerViewController) {
        
        addPickerController.pickupAddress = pickUpAddress
        dropOffBtnText = "Destination not set"
    }
}


