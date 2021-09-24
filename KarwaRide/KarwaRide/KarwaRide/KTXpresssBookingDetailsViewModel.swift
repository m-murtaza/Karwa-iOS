//
//  KTXpressBookingDetailsViewModel.swift
//  KarwaRide
//
//  Created by Satheesh on 8/8/21.
//  Copyright © 2021 Karwa. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON
import GoogleMaps

struct WayPoints {
    /*
     {
                     "Location": {
                         "lat": 25.195471,
                         "lon": 51.471721
                     },
                     "PickCount": 0,
                     "DropCount": 1
                 }
     */
    var Location: WayPointLocations
    var PickCount: Int
    var DropCount: Int

}

struct WayPointLocations {
    var lat: Double
    var lon: Double
}

//MARK: - Protocols
protocol KTXpresssBookingDetailsViewModelDelegate: KTViewModelDelegate {
    func initializeMap(location : CLLocationCoordinate2D)
    func showCurrentLocationDot(show: Bool)
    func showUpdateVTrackMarker(vTrack: VehicleTrack)
    func showPathOnMap(path: GMSPath)
    func updateBookingCard()
    func updateHeaderMsg(_ msg : String)
    func updateCallerId()
    func hidePhoneButton()
    func showCancelBooking()
    func showEbill()
    func showFareBreakdown()
    func showRecenterBtn()
    func hideRecenterBtn()
    func moveToBooking()
    
    func popViewController()
    func updateBookingCardForCompletedBooking()
    func updateBookingCardForUnCompletedBooking()
    
    func addPickupMarker(location : CLLocationCoordinate2D)
    func addDropOffMarker(location : CLLocationCoordinate2D)
    func setMapCamera(bound : GMSCoordinateBounds)
    func clearMaps()
    
    func updateAssignmentInfo()
    func hideDriverInfoBox()
    func showDriverInfoBox()
    
    func updateEta(eta: String)
    func hideEtaView()
    func showEtaView()
    
    func hideMoreOptions()
    func showMoreOptions()
    
    func updateLeftBottomBarButtom(title: String, color: UIColor,tag: Int)
    func updateRightBottomBarButtom(title: String, color: UIColor, tag: Int)
    
    func showRatingScreen()
    
    func showRouteOnMap(points pointsStr: String)
    
    func updateMapCamera()
    func updateBookingStatusOnCard(_ withAnimation: Bool)
    func showHideShareButton(_ show : Bool)
    
    func addAndGetMarkerOnMap(location: CLLocationCoordinate2D, image: UIImage) -> GMSMarker
    func getMarkerOnMap(location: CLLocationCoordinate2D, image: UIImage) -> GMSMarker
    func focusMapToShowAllMarkers(gmsMarker : Array<GMSMarker>)
    func addPointsOnMap(encodedPath: String)

}

class KTXpresssBookingDetailsViewModel: KTBaseViewModel {
    
    var booking : KTBooking?
    var del : KTBookingDetailsViewModelDelegate?
    var rideServicePickDropOffData: RideSerivceLocationData? = nil

    private var timerVechicleTrack : Timer? = Timer()
    private var timerBookingFreshness : Timer? = Timer()
    
    final let VEHICLE_STATUS_HIRED : Int = 4
    var isHiredShown = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        del = self.delegate as? KTBookingDetailsViewModelDelegate
        initializeViewWRTBookingStatus()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        checkForRating()
        //Check the drop of address name
        
        guard self.rideServicePickDropOffData != nil else {
            return
        }
        
        if self.rideServicePickDropOffData?.dropOffStop == nil && self.rideServicePickDropOffData?.dropOfSftation == nil{
            self.fetchLocationName(forGeoCoordinate: (self.rideServicePickDropOffData?.dropOffCoordinate)!, type: "Drop")
        } else {
            if self.rideServicePickDropOffData?.dropOffStop == nil {
                (delegate as! KTXpressRideCreationViewModelDelegate).setDropOff(pick: self.rideServicePickDropOffData?.dropOfSftation?.name ?? "")
            } else {
                (delegate as! KTXpressRideCreationViewModelDelegate).setDropOff(pick: self.rideServicePickDropOffData?.dropOffStop?.name ?? "")
            }
        }

        //Check the pickup address name
        if self.rideServicePickDropOffData?.pickUpStop == nil && self.rideServicePickDropOffData?.pickUpStation == nil {
            self.fetchLocationName(forGeoCoordinate: (self.rideServicePickDropOffData?.pickUpCoordinate)!, type: "Pick")
        } else {
            if  self.rideServicePickDropOffData?.pickUpStop == nil {
                (delegate as! KTXpressRideCreationViewModelDelegate).setPickup(pick: self.rideServicePickDropOffData?.pickUpStation?.name ?? "")
            } else {
                (delegate as! KTXpressRideCreationViewModelDelegate).setPickup(pick: self.rideServicePickDropOffData?.pickUpStop?.name ?? "")
            }
        }

    }
    
    private func fetchLocationName(forGeoCoordinate coordinate: CLLocationCoordinate2D, type: String) {
        
        KTBookingManager().address(forLocation: coordinate, Limit: 1) { (status, response) in
            if status == Constants.APIResponseStatus.SUCCESS && response[Constants.ResponseAPIKey.Data] != nil && (response[Constants.ResponseAPIKey.Data] as! [KTGeoLocation]).count > 0{
                
                let pAddress : KTGeoLocation = (response[Constants.ResponseAPIKey.Data] as! [KTGeoLocation])[0]
                
                DispatchQueue.main.async {
                    if self.delegate != nil {
                        if type == "Drop" {
                            (self.delegate as? KTXpressRideCreationViewModelDelegate)?
                                .setDropOff(pick: pAddress.name)
                        } else {
                            (self.delegate as? KTXpressRideCreationViewModelDelegate)?.setPickup(pick: pAddress.name)
                        }
                    }
                }
            }
        }
    }
    
    func initializeViewWRTBookingStatus() {
        
        //Check for booking == nil
        guard let _ = booking else {
            return
        }
        
        updateMap()
        updateEta()
        updateCallerId()
        updateBookingCard()
        updateAssignmentInfo()
        updateBottomBarButtons()
    }
    
    func bookingId() -> String {
        return booking?.bookingId ?? "RS210807-ILNL"
    }
    
    func bookingStatii() -> Int32 {
        return booking?.bookingStatus ?? 4
    }
    
    func getBookingOtp() -> String? {
        return booking?.otp
    }
    
    func getCancellationCharges() -> String {
        return "str_cancellation".localized() + ": \(booking?.cancellationCharges ?? "")"
    }
    
    
    func updateEta() {
        updateEta(eta: "")
    }
    
    //MARK:- ETA View
    func updateEta(eta: String) {
        var etaVal = ""
        if booking?.bookingStatus == BookingStatus.CONFIRMED.rawValue || booking?.bookingStatus == BookingStatus.ARRIVED.rawValue || booking?.bookingStatus == BookingStatus.PICKUP.rawValue
        {
            del?.showEtaView()
            if(eta == "")
            {
                etaVal = eta
                del?.updateEta(eta: etaVal)
            }
            else
            {
                etaVal = eta
                del?.updateEta(eta: etaVal)
            }
            
        }
        
        if(booking?.bookingStatus == BookingStatus.COMPLETED.rawValue || booking?.bookingStatus == BookingStatus.CANCELLED.rawValue || etaVal == "0 min" || (booking?.bookingStatus == BookingStatus.PICKUP.rawValue && booking?.dropOffLat == 0))
        {
            del?.hideEtaView()
        }
        else
        {
            del?.showEtaView()
        }
        
    }
    
    func formatedETA(eta: Int64) -> String {
        let formatedEta : Double = Double(eta)/60
        if formatedEta > 1 {
            return String(format: "txt_eta_mins".localized(), "\(Int(ceil(Double(formatedEta))))")
        } else {
            return String(format: "txt_eta".localized(), "\(Int(ceil(Double(formatedEta))))")
        }
    }
    
    override func viewWillDisappear()
    {
        stopBookingUpdateTimer()
        stopVehicleUpdateTimer()
    }
    
    //MARK:- Driver Info
    func callDriver() {
        guard let phone : String = booking?.driverPhone else {
            del?.showError!(title: "Error", message: "Driver phone number is not available")
            return
        }
        if !phone.isEmpty {
            UIApplication.shared.open(URL(string: "TEL://\(phone)")!)
        }
        else {
            del?.showError!(title: "Error", message: "Driver phone number is not available")
        }
        
    }
    
    func updateAssignmentInfo() {
        if(booking?.bookingStatus == BookingStatus.PICKUP.rawValue || booking?.bookingStatus == BookingStatus.ARRIVED.rawValue || booking?.bookingStatus == BookingStatus.CONFIRMED.rawValue)
        {
            del?.showRecenterBtn()
        }
        else
        {
            del?.hideRecenterBtn()
        }

        if(booking?.bookingStatus == BookingStatus.CANCELLED.rawValue)
        {
            if booking?.driverName == nil && (booking?.driverName?.isEmpty ?? false) {
                del?.hideDriverInfoBox()
            } else {
                del?.showDriverInfoBox()
            }
        }
        else if booking?.driverName != nil && !(booking?.driverName?.isEmpty)!
        {
            //del?.hideDriverInfoBox()
            del?.updateAssignmentInfo()
        }else if(booking?.bookingStatus == BookingStatus.TAXI_NOT_FOUND.rawValue || booking?.bookingStatus == BookingStatus.NO_TAXI_ACCEPTED.rawValue) || booking?.bookingStatus == BookingStatus.PENDING.rawValue
        {
            
            del?.hideDriverInfoBox()
            
        }
        
        
    }
    
    func driverName() -> String {
        
        guard let name = booking?.driverName else {
            return ""
        }
        
        return name
    }
    
    func vehicleNumber() -> String {
        guard var vNum = booking?.vehicleNo else {
            return ""
        }
        
        let vNumArr = vNum.components(separatedBy: " ")
        if vNumArr.count >= 2 {
            
            vNum = vNumArr[1]
        }
        
        return vNum
    }
    
    func imgForPlate() -> UIImage {
        guard let vehicleType = booking?.vehicleType else {
            return UIImage(named:"taxiplate")!
        }
        if KTVehicleTypeManager.isTaxi(vType: VehicleType(rawValue: vehicleType)!) {
            return UIImage(named:"taxiplate")!
        }
        return UIImage(named:"limo_number_plate")!
    }
    
    func driverRating() -> Double {
        guard let rating = booking?.driverRating else {
            return 0.0
        }
        return rating
    }
    //MARK:- CallerId
    func updateCallerId() {
        if KTAppSessionInfo.currentSession.customerType == CustomerType.CORPORATE {
            del?.updateCallerId()
        }
        
    }
    
    func idForCaller() -> String {
        return booking?.callerId ?? "345678876"
    }
    
    //MARK:- BookingCard
    func updateBookingCard() {
        del?.updateBookingCard()
        del?.updateHeaderMsg(getHeaderMsg(booking!.bookingStatus))

        if booking?.bookingStatus == BookingStatus.COMPLETED.rawValue {
            del?.hidePhoneButton()
            del?.updateBookingCardForCompletedBooking()
        }
        else {
            del?.updateBookingCardForUnCompletedBooking()
        }
    }
    
    func pickMessage () -> String {
        var msg : String = ""
        if booking?.pickupMessage != nil && booking?.pickupMessage?.isEmpty == false {
            msg = "(\((booking?.pickupMessage ?? "******")))"
        }
        return msg
    }
    
    func pickAddress() -> String{
        return  booking?.pickupAddress ?? ""
    }
    
    func dropAddress() -> String{
        var dropAdd : String?
        
        
        dropAdd = booking?.dropOffAddress
        if dropAdd == nil || (dropAdd?.isEmpty)! {
            
            dropAdd = "No Destination Set"
        }
        
        return dropAdd ?? "******"
    }
    
    func cellBGColor() -> UIColor{
        var color : UIColor = UIColor.white
        
        switch booking?.bookingStatus {
        case BookingStatus.CONFIRMED.rawValue?, BookingStatus.ARRIVED.rawValue?, BookingStatus.PICKUP.rawValue?:
            color = UIColor(hexString:"#F9FDFC")
            
        case BookingStatus.PENDING.rawValue?, BookingStatus.DISPATCHING.rawValue? :
            color = UIColor(hexString:"#E5F5F2")
            
        case BookingStatus.COMPLETED.rawValue?:
            color = UIColor(hexString:"#D7E6E3")
            
        case BookingStatus.CANCELLED.rawValue?, BookingStatus.TAXI_NOT_FOUND.rawValue? ,BookingStatus.TAXI_UNAVAIALBE.rawValue? ,BookingStatus.NO_TAXI_ACCEPTED.rawValue?, BookingStatus.EXCEPTION.rawValue?:
            color = UIColor(hexString:"#FEE5E5")
            
        default:
            color = UIColor(hexString:"#F9FDFC")
        }
        
        return color
    }
    
    func cellBorderColor() -> UIColor{
        var color : UIColor = UIColor.white
        switch booking?.bookingStatus {
        case BookingStatus.CONFIRMED.rawValue?,  BookingStatus.ARRIVED.rawValue?,BookingStatus.PICKUP.rawValue?,BookingStatus.PENDING.rawValue?, BookingStatus.DISPATCHING.rawValue?, BookingStatus.COMPLETED.rawValue? :
            color = UIColor(hexString:"#CFD0D1")
            
        case BookingStatus.CANCELLED.rawValue?, BookingStatus.TAXI_NOT_FOUND.rawValue? ,BookingStatus.TAXI_UNAVAIALBE.rawValue? ,BookingStatus.NO_TAXI_ACCEPTED.rawValue?, BookingStatus.EXCEPTION.rawValue?:
            color = UIColor(hexString:"#EBC0C6")
            
        default:
            color = UIColor(hexString:"#CFD0D1")
        }
        
        return color
    }
    
    func pickupDateOfMonth() -> String {
        return booking!.pickupTime!.dayOfMonth()
    }
    
    func pickupMonth() -> String {
        return " \(booking!.pickupTime!.threeLetterMonth()) "
    }
    
    func pickupYear() -> String{
        return booking!.pickupTime!.year()
    }
    
    func pickupDayAndTime() -> String {
        let day = booking!.pickupTime!.dayOfWeek()
        let time = booking!.pickupTime!.timeWithAMPM()
        let dayAndTime = "\(time), "
        return dayAndTime
    }
    
    func paymentMethod() -> String
    {
        var paymentMethod = "str_cash".localized()
        let bookingStatus = bookingStatii()
        
        print(booking?.paymentMethod)
        
        if(bookingStatus == BookingStatus.PICKUP.rawValue || bookingStatus == BookingStatus.ARRIVED.rawValue || bookingStatus == BookingStatus.CONFIRMED.rawValue || bookingStatus == BookingStatus.PENDING.rawValue || bookingStatus == BookingStatus.DISPATCHING.rawValue) {
            //Skipping the payment method because the booking hasn't been completed yet, so sticking to cash, it will be changed once we work for pre-paid payment
        }
        else if (booking?.paymentMethod ?? "WALLET") == "WALLET" {
            paymentMethod = "str_paid_with".localized()
        }
        else if(!(booking!.lastFourDigits == "Cash" || booking!.lastFourDigits == "" || booking!.lastFourDigits == "CASH" || booking!.lastFourDigits == nil)) {
            paymentMethod = "**** " +  (booking!.lastFourDigits ?? "")
        }
        else if(booking!.paymentMethod == "ApplePay") {
            paymentMethod = "str_paid_by".localized()
        }

        return paymentMethod
        
    }
    
    
    func paymentMethodIcon() -> String
    {
        var paymentMethodIcon = ""
        let bookingStatus = bookingStatii()
        if(bookingStatus == BookingStatus.PICKUP.rawValue || bookingStatus == BookingStatus.ARRIVED.rawValue || bookingStatus == BookingStatus.CONFIRMED.rawValue || bookingStatus == BookingStatus.PENDING.rawValue || bookingStatus == BookingStatus.DISPATCHING.rawValue)
        {
            //Skipping the payment method because the booking hasn't been completed yet, so sticking to cash, it will be changed once we work for pre-paid payment
        }
        else
        {
            paymentMethodIcon = booking!.paymentMethod ?? ""
        }
        return paymentMethodIcon
    }
    
    func vehicleType() -> String {
        
        var type : String = ""
        switch booking!.vehicleType {
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
        
        case VehicleType.KTXpressTaxi.rawValue:
            type = "str_xpress".localized()
        default:
            type = ""
        }
        return type
    }
    
    func pickupTime() -> String {
        
        var time : String = ""
        if booking?.bookingStatus == BookingStatus.COMPLETED.rawValue {
            if booking?.pickupTime != nil {
                time = (booking?.pickupTime?.timeWithAMPM())!
            }
            
        }
        return time
    }
    
    func getHeaderMsg(_ bookingStatus: Int32) -> String
    {
        var msg = ""
        switch bookingStatus
        {
            case BookingStatus.DISPATCHING.rawValue:
                msg = "str_searching_ride".localized()
                break
            case BookingStatus.CONFIRMED.rawValue:
                msg = "str_confirmed".localized()
                break
        case BookingStatus.ARRIVED.rawValue:
            msg = "str_arrived".localized()
            break
            case BookingStatus.PICKUP.rawValue:
                msg = "str_pickup".localized()
                break
            case BookingStatus.CANCELLED.rawValue:
                msg = "txt_ride_cancelled".localized()
                break
            case BookingStatus.COMPLETED.rawValue:
                msg = "txt_completed_metro".localized()
                break
            case BookingStatus.PENDING.rawValue:
                msg = "str_scheduled".localized()
                break;
            case BookingStatus.NO_TAXI_ACCEPTED.rawValue:
                msg = "txt_no_rides_found".localized()
                break
        case BookingStatus.TAXI_NOT_FOUND.rawValue:
            msg = "txt_no_rides_found".localized()
            break
            default:
                msg = "--"
            
        }

        return msg
    }
    
    func getPassengerCountr() -> String
    {
        var passengerCount = "txt_four".localized()

        if(booking?.vehicleType == VehicleType.KTAiport7Seater.rawValue || booking?.vehicleType == VehicleType.KTCityTaxi7Seater.rawValue)
        {
            passengerCount = "txt_seven".localized()
        }
        
        return  "\(booking?.passengerCount ?? 0)" // "1" //passengerCount //modified for testing purpose
    }
    
    func dropoffTime() -> String {
        var time : String = ""
        if booking?.bookingStatus == BookingStatus.COMPLETED.rawValue {
            if booking?.dropOffTime != nil {
                time = (booking?.pickupTime?.timeWithAMPM())!
            }
            
        }
        return time
    }
    
    
    func estimatedFare() -> String {
        var estimate : String = "N/A"
        if (booking!.estimatedFare != nil && (booking!.estimatedFare?.count)! > 0) {
            estimate = booking!.estimatedFare!
        }
        return estimate
    }
    
    
    //MARK:- Map
    
    func currentLocation() -> CLLocationCoordinate2D {
        
        return KTLocationManager.sharedInstance.currentLocation.coordinate
    }
    
    func updateMap() {
        
        let bStatus = BookingStatus(rawValue: (booking?.bookingStatus)!)
        
        if(bStatus == BookingStatus.PENDING || bStatus == BookingStatus.DISPATCHING)
        {
            del?.initializeMap(location: CLLocationCoordinate2D(latitude: (booking?.pickupLat)!,longitude: (booking?.pickupLon)!))
            
            self.showCurrentLocationDot(location: KTLocationManager.sharedInstance.currentLocation.coordinate)
            showPickDropMarker(showOnlyPickup: false)
            startPollingForBooking()
            del?.showHideShareButton(false)
        }
        else if bStatus ==  BookingStatus.CANCELLED || bStatus == BookingStatus.EXCEPTION || bStatus ==  BookingStatus.NO_TAXI_ACCEPTED || bStatus == BookingStatus.TAXI_NOT_FOUND || bStatus == BookingStatus.TAXI_UNAVAIALBE
        {
            del?.clearMaps()
            showPickDropMarker()
            del?.showHideShareButton(false)
        }
        else if(bStatus == BookingStatus.PICKUP)
        {
            del?.initializeMap(location: CLLocationCoordinate2D(latitude: (booking?.pickupLat)!,longitude: (booking?.pickupLon)!))
            self.showCurrentLocationDot(location: KTLocationManager.sharedInstance.currentLocation.coordinate)
            startVechicleTrackTimer()
            del?.showHideShareButton(true)
        }
        else if  bStatus == BookingStatus.ARRIVED || bStatus == BookingStatus.CONFIRMED
        {
            del?.initializeMap(location: CLLocationCoordinate2D(latitude: (booking?.pickupLat)!,longitude: (booking?.pickupLon)!))
            self.showCurrentLocationDot(location: KTLocationManager.sharedInstance.currentLocation.coordinate)
            showPickDropMarker(showOnlyPickup: true)
            del?.showHideShareButton(true)
            startVechicleTrackTimer()
        }
        else if bStatus == BookingStatus.COMPLETED
        {
            del?.showHideShareButton(false)
            if booking?.tripTrack != nil && booking?.tripTrack?.isEmpty == false {
                del?.initializeMap(location: CLLocationCoordinate2D(latitude: (booking?.pickupLat)!,longitude: (booking?.pickupLon)!))
                drawPath(encodedPath: booking?.encodedPath ?? "", wayPoints: [WayPoints]())
//                snapTrackToRoad(track: (booking?.tripTrack)!)
            }
        }
        else
        {
            del?.showHideShareButton(false)
            del?.initializeMap(location: CLLocationCoordinate2D(latitude: (booking?.pickupLat)!,longitude: (booking?.pickupLon)!))
        }
    }
    
    func startPollingForBooking()
    {
        timerBookingFreshness = Timer.scheduledTimer(timeInterval: 4, target: self,   selector: (#selector(self.fetchUpdatedBookings)), userInfo: nil, repeats: true)
    }
    
    @objc func fetchUpdatedBookings()
    {
        KTBookingManager().syncBookings { (status, response) in
            
            if(response[Constants.ResponseAPIKey.Data] != nil)
            {
                let deltaBookings: [KTBooking] = response[Constants.ResponseAPIKey.Data] as! [Any] as! [KTBooking]
                
                if  deltaBookings.count > 0
                {
                    for updatedBooking in deltaBookings
                    {
                        if(self.booking?.bookingId == updatedBooking.bookingId)
                        {
                            let bStatus = updatedBooking.bookingStatus
                            if(bStatus == BookingStatus.PICKUP.rawValue || bStatus == BookingStatus.ARRIVED.rawValue || bStatus == BookingStatus.CONFIRMED.rawValue)
                            {
                                self.del?.showHideShareButton(true)
                                self.booking = updatedBooking
                                self.stopBookingUpdateTimer()
                                self.del?.showDriverInfoBox()
                                self.initializeViewWRTBookingStatus()
                            }
                        }
                    }
                }
            }
        }
    }

    func stopBookingUpdateTimer()
    {
        if (timerBookingFreshness != nil && timerBookingFreshness!.isValid)
        {
            timerBookingFreshness?.invalidate()
            timerBookingFreshness = nil
        }
    }
    
    func stopVehicleUpdateTimer()
    {
        if (timerVechicleTrack != nil && timerVechicleTrack!.isValid)
        {
            timerVechicleTrack?.invalidate()
            timerVechicleTrack = nil
        }
    }
    
    func startVechicleTrackTimer()
    {
        timerVechicleTrack = Timer.scheduledTimer(timeInterval: 4, target: self,   selector: (#selector(self.fetchTaxiForTracking)), userInfo: nil, repeats: true)
    }
    
    @objc func fetchTaxiForTracking()
    {
        let bStatus = BookingStatus(rawValue: (booking?.bookingStatus)!)
        if  bStatus == BookingStatus.ARRIVED || bStatus == BookingStatus.CONFIRMED || bStatus == BookingStatus.PICKUP
        {
            KTBookingManager().trackVechicle(jobId: (booking?.bookingId)!,vehicleNumber: (booking?.vehicleNo)!, true, completion: {
                (status, response) in
                if status == Constants.APIResponseStatus.SUCCESS
                {
                    let vtrack : VehicleTrack = self.parseVehicleTrack(track: response)
                    
                    if(vtrack.status == self.VEHICLE_STATUS_HIRED && !self.isHiredShown)
                    {
                        self.booking?.bookingStatus = BookingStatus.PICKUP.rawValue
                        self.isHiredShown = true
                        self.del?.updateBookingStatusOnCard(true)
//                        self.del?.hideEtaView()
                    }
                    
                    if bStatus == BookingStatus.ARRIVED || bStatus == BookingStatus.CONFIRMED
                    {
                        self.fetchRouteToPickupOrDropOff(vTrack: vtrack, destinationLat: (self.booking?.pickupLat)!, destinationLong: (self.booking?.pickupLon)!)
                    }
                    else if(bStatus == BookingStatus.PICKUP && self.booking?.dropOffLat != nil && self.booking?.dropOffLon != nil)
                    {
                        self.fetchRouteToPickupOrDropOff(vTrack: vtrack, destinationLat: (self.booking?.dropOffLat)!, destinationLong: (self.booking?.dropOffLon)!)
                        self.updateBookingCard()
                    }

                    self.del?.showUpdateVTrackMarker(vTrack: vtrack)
                    
                    if(bStatus != BookingStatus.PICKUP)
                    {
                        self.del?.updateMapCamera()
                    }
                    self.updateEta(eta: self.formatedETA(eta: vtrack.eta))
//                    self.del?.updateEta(eta: self.formatedETA(eta: vtrack.eta))
                }
                else
                {
                    self.fetchBooking((self.booking?.bookingId)!, true)
//                    self.del?.showSuccessBanner("  ", "Trip status has been updated")
                    self.stopVehicleUpdateTimer()
                }
            })
        }
        else
        {
            if (timerVechicleTrack != nil && timerVechicleTrack!.isValid)
            {
                timerVechicleTrack!.invalidate()
            }
        }
    }
    
    @objc func fetchBooking(_ bookingId : String, _ isFromBookingId : Bool)
    {
        self.del?.showProgressHud(show: true, status: "Fetching Trip Information")
        
        KTBookingManager().booking(bookingId as String, isFromBookingId) { (status, response) in
            
            self.del?.hideProgressHud()
            
            if status == Constants.APIResponseStatus.SUCCESS
            {
                let updatedBooking : KTBooking = response[Constants.ResponseAPIKey.Data] as! KTBooking

//                self.bookingUpdateTriggered(updatedBooking)
//                self.del?.showDriverInfoBox()
                
                self.booking = updatedBooking
                
                self.checkForRating()
                
                self.initializeViewWRTBookingStatus()
                
            }
        }
    }
    
    func showPickDropMarker() {
        showPickDropMarker(showOnlyPickup: false)
    }
    
    func showPickDropMarker(showOnlyPickup : Bool) {
        
        let bounds : GMSCoordinateBounds = GMSCoordinateBounds()
        
        if booking?.pickupLat != nil && booking?.pickupLon != nil && !(booking?.pickupLat.isZero)! && !(booking?.pickupLon.isZero)! {
            
            let location : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: (booking?.pickupLat)!,longitude: (booking?.pickupLon)!)
            del?.addPickupMarker(location: location)
            bounds.includingCoordinate(location)
        }
        
        if(!showOnlyPickup)
        {
            if booking?.dropOffLat != nil && booking?.dropOffLon != nil && !(booking?.dropOffLat.isZero)! && !(booking?.dropOffLon.isZero)! {
                
                let location : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: (booking?.dropOffLat)!,longitude: (booking?.dropOffLon)!)
                del?.addDropOffMarker(location: location)
                bounds.includingCoordinate(location)
            }
        }
        
        if bounds.isValid {
            del?.setMapCamera(bound: bounds)
        }
        else {
            if booking?.dropOffLat != nil && booking?.dropOffLon != nil && !(booking?.dropOffLat.isZero)! && !(booking?.dropOffLon.isZero)! {} else {
                del?.initializeMap(location: CLLocationCoordinate2D(latitude: (booking?.pickupLat)!,longitude: (booking?.pickupLon)!))
            }
        }
    }
    
    private func fetchRouteToPickupOrDropOff(vTrack ride: VehicleTrack, destinationLat lat: Double, destinationLong long: Double)
    {
        drawPath(encodedPath: ride.encodedPath,wayPoints: ride.wayPoints ,vTrack: ride)

//        if(Constants.DIRECTIONS_API_ENABLE)
//        {
//            let origin = "\(ride.position.latitude),\(ride.position.longitude)"
//            let destination = "\(lat),\(long)"
//
//
//            let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=\(Constants.GOOGLE_SNAPTOROAD_API_KEY)"
//
//            Alamofire.request(url).responseJSON { response in
//
//                do
//                {
//                    let json = try JSON(data: response.data!)
//                    let routes = json["routes"].arrayValue
//
//                    for route in routes
//                    {
//                        let routeOverviewPolyline = route["overview_polyline"].dictionary
//                        let points = routeOverviewPolyline?["points"]?.stringValue
//
//                        self.del?.showRouteOnMap(points: points!)
//                    }
//                } catch
//                {
//
//                }
//            }
//        }
//        else
//        {
//            drawPath(encodedPath: ride.encodedPath, vTrack: ride)
////            focusMarkers(vTrack: ride)
//        }
    }
    
    func drawPath(encodedPath: String, wayPoints: [WayPoints]) {

        drawPath(encodedPath: encodedPath, wayPoints: wayPoints, vTrack: nil)
    }
    
    func drawPath(encodedPath: String, wayPoints: [WayPoints] ,vTrack: VehicleTrack?) {

        (self.delegate as! KTBookingDetailsViewModelDelegate).addPointsOnMapWithWayPoints(encodedPath: encodedPath, wayPoints: wayPoints)
        
        if(vTrack != nil && booking?.dropOffLat == 0)
        {
            var pickDropMarkers = [GMSMarker]()

            let pickMarker = (delegate as! KTBookingDetailsViewModelDelegate).getMarkerOnMap(location:CLLocationCoordinate2D(latitude: booking!.pickupLat,longitude: booking!.pickupLon) , image: UIImage(named: "pin_pickup_map")!)

            let dropMarker = (delegate as! KTBookingDetailsViewModelDelegate).getMarkerOnMap(location:CLLocationCoordinate2D(latitude: (vTrack?.position.latitude)!,longitude: (vTrack?.position.longitude)!) , image: UIImage(named: "pin_dropoff_map")!)
            
            pickDropMarkers.append(dropMarker)
            pickDropMarkers.append(pickMarker)

            (delegate as! KTBookingDetailsViewModelDelegate).focusMapToShowAllMarkers(gmsMarker: pickDropMarkers)
        }
        else if(!isPickDropMarked)
        {
            let pickMarker = (delegate as! KTBookingDetailsViewModelDelegate).addAndGetMarkerOnMap(location:CLLocationCoordinate2D(latitude: booking!.pickupLat,longitude: booking!.pickupLon) , image: UIImage(named: "pin_pickup_map")!)

            var pickDropMarkers = [GMSMarker]()
            pickDropMarkers.append(pickMarker)

            if(booking!.dropOffLat != 0)
            {
                let dropMarker = (delegate as! KTBookingDetailsViewModelDelegate).addAndGetMarkerOnMap(location:CLLocationCoordinate2D(latitude: booking!.dropOffLat,longitude: booking!.dropOffLon) , image: UIImage(named: "pin_dropoff_map")!)
                pickDropMarkers.append(dropMarker)
            }

            (delegate as! KTBookingDetailsViewModelDelegate).focusMapToShowAllMarkers(gmsMarker: pickDropMarkers)

            isPickDropMarked = true
        }
    }
    
    func focusMarkers(vTrack: VehicleTrack)
    {
        var pickDropMarkers = [GMSMarker]()
        let pickMarker = (delegate as! KTBookingDetailsViewModelDelegate).getMarkerOnMap(location:CLLocationCoordinate2D(latitude: booking!.pickupLat,longitude: booking!.pickupLon) , image: UIImage(named: "pin_pickup_map")!)
        pickDropMarkers.append(pickMarker)

        if(booking!.dropOffLat == 0)
        {
            let dropMarker = (delegate as! KTBookingDetailsViewModelDelegate).getMarkerOnMap(location:CLLocationCoordinate2D(latitude: vTrack.position.latitude,longitude: vTrack.position.longitude) , image: UIImage(named: "pin_dropoff_map")!)
            pickDropMarkers.append(dropMarker)
        }

        (delegate as! KTBookingDetailsViewModelDelegate).focusMapToShowAllMarkers(gmsMarker: pickDropMarkers)
    }
    
    func focusMarkers()
    {
        var pickDropMarkers = [GMSMarker]()
        let pickMarker = (delegate as! KTBookingDetailsViewModelDelegate).getMarkerOnMap(location:CLLocationCoordinate2D(latitude: booking!.pickupLat,longitude: booking!.pickupLon) , image: UIImage(named: "pin_pickup_map")!)
        pickDropMarkers.append(pickMarker)

        if(booking!.dropOffLat == 0)
        {
            let dropMarker = (delegate as! KTBookingDetailsViewModelDelegate).getMarkerOnMap(location:CLLocationCoordinate2D(latitude: booking!.dropOffLat,longitude: booking!.dropOffLon) , image: UIImage(named: "pin_dropoff_map")!)
            pickDropMarkers.append(dropMarker)
        }

        (delegate as! KTBookingDetailsViewModelDelegate).focusMapToShowAllMarkers(gmsMarker: pickDropMarkers)
    }
    
    func parseVehicleTrack(track rtrack : [AnyHashable:Any]) -> VehicleTrack
    {
        let track : VehicleTrack = VehicleTrack()
        //track.vehicleNo = rtrack["VehicleNo"] as! String
        track.position = CLLocationCoordinate2D(latitude: (rtrack["Lat"] as? CLLocationDegrees)!, longitude: (rtrack["Lon"] as? CLLocationDegrees)!)
        //track.vehicleType = rtrack["VehicleType"] as! Int
        track.bearing = (rtrack["Bearing"] as! NSNumber).floatValue
        track.eta = rtrack["CurrentETA"] as! Int64
        track.status = rtrack["Status"] as! Int
        
//        track.encodedPath = (!self.isNsnullOrNil(object:rtrack["EncodedPath"] as AnyObject)) ? rtrack["EncodedPath"] as? String : ""
        if let encodedPath = rtrack["EncodedPath"] as? String
        {
            track.encodedPath = encodedPath
        }
        track.trackType = VehicleTrackType.vehicle
        
        if let waypoints = rtrack["Waypoints"] as? [[String: Any]] {
            
            track.wayPoints = [WayPoints]()
            
            for item in waypoints {
                let locationWayP = WayPointLocations(lat: ((item["Location"] as? [String: Double])?["lat"])!, lon: ((item["Location"] as? [String: Double])?["lon"])!)
                let wayP = WayPoints(Location: locationWayP, PickCount: item["PickCount"] as? Int ?? 0, DropCount: item["DropCount"] as? Int ?? 0)
                track.wayPoints.append(wayP)
            }
            
        }
        
        print(track.wayPoints)
        
        return track
        
    }
    
    func imgForTrackMarker() -> UIImage {
        
        var img : UIImage?
        switch booking?.vehicleType  {
        case VehicleType.KTAirportSpare.rawValue?, VehicleType.KTCityTaxi.rawValue?:
            img = UIImage(named:"BookingMapTaxiIco")
        case VehicleType.KTCityTaxi7Seater.rawValue?:
            img = UIImage(named: "BookingMap7Ico")
        case VehicleType.KTSpecialNeedTaxi.rawValue?:
        img = UIImage(named: "BookingMapSpecialNeedIco")
        case VehicleType.KTStandardLimo.rawValue?:
            img = UIImage(named: "BookingMapStandardIco")
        case VehicleType.KTBusinessLimo.rawValue?:
            img = UIImage(named: "BookingMapBusinessIco")
        case VehicleType.KTLuxuryLimo.rawValue?:
            img = UIImage(named: "BookingMapLuxuryIco")
        default:
            img = UIImage(named:"XpressMapIco")
        }
        return img!
    }
    
    func imgForVehicle() -> UIImage {
        
        var img : UIImage?
        switch booking?.vehicleType  {
        case VehicleType.KTAirportSpare.rawValue?, VehicleType.KTCityTaxi.rawValue?:
            img = UIImage(named:"icon-karwa-taxi")
        case VehicleType.KTCityTaxi7Seater.rawValue?:
            img = UIImage(named: "icon-family-taxi")
        case VehicleType.KTSpecialNeedTaxi.rawValue?:
        img = UIImage(named: "icon-accessible-taxi")
        case VehicleType.KTStandardLimo.rawValue?:
            img = UIImage(named: "icon-standard-limo")
        case VehicleType.KTBusinessLimo.rawValue?:
            img = UIImage(named: "icon-business-limo")
        case VehicleType.KTLuxuryLimo.rawValue?:
            img = UIImage(named: "icon-luxury-limo")
        default:
            img = UIImage(named:"icon-karwa-taxi")
        }
        return img!
    }
    
    var isPickDropMarked = false

    //MARK:- Bottom Bar buttons
    func updateBottomBarButtons() {
        
        var isDoneBooking = false

        if booking?.bookingStatus == BookingStatus.ARRIVED.rawValue || booking?.bookingStatus == BookingStatus.DISPATCHING.rawValue || booking?.bookingStatus == BookingStatus.PENDING.rawValue || booking?.bookingStatus == BookingStatus.CONFIRMED.rawValue {
            
            del?.updateLeftBottomBarButtom(title: "fareDetails".localized(), color: UIColor(hexString:"#129793"), tag: BottomBarBtnTag.FareBreakdown.rawValue)
            
            del?.updateRightBottomBarButtom(title: "cancelBooking".localized(), color: UIColor(hexString:"#E74C3C"), tag: BottomBarBtnTag.Cancel.rawValue)
        }
        else if booking?.bookingStatus == BookingStatus.COMPLETED.rawValue {
            del?.updateLeftBottomBarButtom(title: "tripEBill".localized(), color: UIColor(hexString:"#129793"), tag: BottomBarBtnTag.EBill.rawValue)
            
            del?.updateRightBottomBarButtom(title: "", color: UIColor(hexString:"#26ADF0"), tag: BottomBarBtnTag.Rebook.rawValue)
            
            isDoneBooking = true
        }
        else if booking?.bookingStatus == BookingStatus.CANCELLED.rawValue || booking?.bookingStatus == BookingStatus.TAXI_NOT_FOUND.rawValue || booking?.bookingStatus == BookingStatus.TAXI_UNAVAIALBE.rawValue || booking?.bookingStatus == BookingStatus.NO_TAXI_ACCEPTED.rawValue {
            
            del?.updateLeftBottomBarButtom(title: "", color: UIColor(hexString:"#129793"), tag: BottomBarBtnTag.FareBreakdown.rawValue)

            del?.updateRightBottomBarButtom(title: "", color: UIColor(hexString:"#26ADF0"), tag: BottomBarBtnTag.Rebook.rawValue)
            
            isDoneBooking = true
            
        }
        else if booking?.bookingStatus == BookingStatus.PICKUP.rawValue {
            del?.updateLeftBottomBarButtom(title: "fareDetails".localized(), color: UIColor(hexString:"#129793"), tag: BottomBarBtnTag.FareBreakdown.rawValue)
            del?.updateRightBottomBarButtom(title: "", color: UIColor(hexString:"#129793"), tag: BottomBarBtnTag.FareBreakdown.rawValue)
            
        }
        
        if(isDoneBooking)
        {
            del?.showMoreOptions()
        }
        else
        {
            del?.hideMoreOptions()
        }
    }
    
    func buttonTapped(withTag tag:Int) {
        if tag == BottomBarBtnTag.Cancel.rawValue {
            del?.showCancelBooking()
        }
        else if tag == BottomBarBtnTag.EBill.rawValue {
            del?.showEbill()
        }
        else if tag == BottomBarBtnTag.FareBreakdown.rawValue {
            del?.showFareBreakdown()
        }
        else if tag == BottomBarBtnTag.Rebook.rawValue {
            del?.moveToBooking()
        }
    }
    
    func cancelDoneSuccess()  {
        booking?.bookingStatus = BookingStatus.CANCELLED.rawValue
        KTBookingManager().saveInDb()
        initializeViewWRTBookingStatus()
//        del?.popViewController()
    }
    
    //MARK:- Ebill
    func ebillTitleTotal() -> String {
        return "Total Amount"
    }
    
    func eBillHeader() -> [KTKeyValue]?{
        
        return (booking?.toKeyValueHeader?.array as! [KTKeyValue])
    }
    
    func eBillBody() -> [KTKeyValue]?{

        return (booking?.toKeyValueBody?.array as! [KTKeyValue])
    }

    func eBillTitle() -> String {
        return "tripEBill".localized()
    }
    
    func eBillTotal() -> String {
        return booking?.totalFare ?? "QR 0"
    }
    
    //MARK: - Estimates
    func estimateTitle() -> String {
        return "str_fare_breakdown".localized()
    }
    
    func estimateTotal() -> String {
        guard let _ = booking?.estimatedFare  else {
            return ""
        }
        return (booking?.estimatedFare)!
    }
    
    func estimateTitleTotal() -> String {
        return "total_fare".localized()
    }
    func isEstimateAvailable() -> Bool {
        guard let _ : KTFareEstimate = booking?.bookingToEstimate else {
            return false
        }
        
        return true
    }
    
    func estimateHeader() -> [KTKeyValue]? {
        
        if isEstimateAvailable() {
            return (booking?.bookingToEstimate?.toKeyValueHeader?.array as! [KTKeyValue])
        }
        return nil
    }
    
    func estimateBody() -> [KTKeyValue]? {
        if isEstimateAvailable() {
            return (booking?.bookingToEstimate?.toKeyValueBody?.array as! [KTKeyValue])
        }
        return nil
    }
    
    //MARK: - Fare Details
    
    func fareDetailTitleTotal() -> String {
        return "str_starting_fare".localized()
    }
    
    func fareDetailTotal() -> String {
        
        let vType : KTVehicleType = KTVehicleTypeManager().vehicleType(typeId: (booking?.vehicleType)!)!
        return vType.typeBaseFare!
    }
    
    func totalFareOfTrip() -> String {
        
        if Device.getLanguage().contains("AR") {
            let numberStr: String = (booking?.fare?.components(separatedBy: " ")[0])!
            let formatter: NumberFormatter = NumberFormatter()
            formatter.locale = NSLocale(localeIdentifier: "EN") as Locale!
            let final = formatter.number(from: numberStr)
            let intNumber = Int(final!)
            print("\(intNumber)")
            
            let totalFare = Int(booking?.driverTip ?? 0) + intNumber
            
            let arformatter = NumberFormatter()
            arformatter.locale = Locale(identifier: "ar")
            if let localized = arformatter.string(from: NSNumber(value: totalFare)) {
               return "\(localized) \((booking?.fare?.components(separatedBy: " ")[1])!)"
            }
            return ""
        } else {
            let formatter: NumberFormatter = NumberFormatter()
            formatter.locale = NSLocale(localeIdentifier: "EN") as Locale!
            
            if (booking?.fare?.count ?? 0) > 0 {
                let final = formatter.number(from: (booking?.fare?.components(separatedBy: " ")[1])!)
                let totalFare = Int(booking?.driverTip ?? 0) + Int(final!)
                return (booking?.fare?.components(separatedBy: " ")[0])! + " " + String(totalFare)
            }
            
            return ""
            
        }
                
                
    }
    
    func fareDetailsHeader() -> [KTKeyValue]? {
        
        guard let _ = booking?.toKeyValueHeader else {
            return nil
        }
        return (booking?.toKeyValueHeader?.array as! [KTKeyValue])
        
    }
    
    func fareDetailsBody() -> [KTKeyValue]? {
        guard let _ = booking?.toKeyValueBody else {
            return nil
        }
        return (booking?.toKeyValueBody?.array as! [KTKeyValue])
    }
    
    //MARK:- Check for rating
    func checkForRating(){
        
        guard booking != nil, booking?.isRated == false else {
            return
        }
        if booking?.bookingStatus == BookingStatus.COMPLETED.rawValue {
            del?.showRatingScreen()
        }
    }
    
    // Triggered only when BookingDetails Controller is in focus
    func bookingUpdateTriggered(_ updatedBooking: KTBooking)
    {
        let bStatus = BookingStatus(rawValue: (updatedBooking.bookingStatus))
        if(bStatus == BookingStatus.ARRIVED || bStatus == BookingStatus.CONFIRMED)
        {
            print("Skipping instant update because of polling")
            del?.showHideShareButton(true)
        }
        else
        {
            self.booking = updatedBooking
            if booking!.bookingStatus == BookingStatus.ARRIVED.rawValue || booking?.bookingStatus == BookingStatus.PICKUP.rawValue
            {
                del?.updateBookingStatusOnCard(true)
                updateMap()
                updateBottomBarButtons()
                del?.showHideShareButton(true)
            }
            else if(booking?.bookingStatus == BookingStatus.CANCELLED.rawValue || booking?.bookingStatus == BookingStatus.TAXI_NOT_FOUND.rawValue || booking?.bookingStatus == BookingStatus.TAXI_UNAVAIALBE.rawValue || booking?.bookingStatus == BookingStatus.NO_TAXI_ACCEPTED.rawValue || booking?.bookingStatus == BookingStatus.COMPLETED.rawValue)
            {
                del?.clearMaps()
                initializeViewWRTBookingStatus()
                del?.showHideShareButton(false)
            }
        }
    }
    
    //KTLocationManager.sharedInstance.currentLocation.coordinate
    
    private func showCurrentLocationDot(location: CLLocationCoordinate2D) {
      
        if location.distance(from: CLLocationCoordinate2D(latitude: booking?.pickupLat ?? 0.0, longitude: booking?.pickupLon ?? 0.0)) <= 100 {
            del?.showCurrentLocationDot(show: true)
        }
      else {
        del?.showCurrentLocationDot(show: false)
        
      }
    }
    
}
