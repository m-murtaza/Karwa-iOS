//
//  KTTrackTripViewModel.swift
//  KarwaRide
//
//  Created by Sam Ash on 11/28/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON
import GoogleMaps
import AVFoundation

//MARK: - Protocols
protocol KTTrackTripViewModelDelegate: KTViewModelDelegate {
    func initializeMap(location : CLLocationCoordinate2D)
    func showCurrentLocationDot(show: Bool)
    func showUpdateVTrackMarker(vTrack: VehicleTrack)
    func showPathOnMap(path: GMSPath)
    func updateBookingCard()
    func updateCallerId()
    func hidePhoneButton()
    
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
    
    func showRouteOnMap(points pointsStr: String)
    
    func updateMapCamera()
    func getTrackTripId() -> String
    func updateBookingStatusOnCard(_ withAnimation: Bool)
    
}

class KTTrackTripViewModel: KTBaseViewModel {
    
    var booking : KTBooking?
    var del : KTTrackTripViewModelDelegate?
    
    final let VEHICLE_STATUS_HIRED : Int = 4
    var isHiredShown = false
    
    private var timerVechicleTrack : Timer? = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        del = self.delegate as? KTTrackTripViewModelDelegate
        
        KTUserManager.init().isUserLogin { (login:Bool) in
            if login == true
            {
                self.fetchBooking((self.del?.getTrackTripId())!, false)
            }
            else
            {
                (UIApplication.shared.delegate as! AppDelegate).showLogin()
            }
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
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
    }
    
    func bookingId() -> String {
        
        return (booking?.bookingId)!
    }
    
    func bookingStatii() -> Int32 {
        return (booking?.bookingStatus)!
    }
    
    
    //MARK:- ETA View
    func updateEta() {
        
        if booking?.bookingStatus == BookingStatus.CONFIRMED.rawValue || booking?.bookingStatus == BookingStatus.ARRIVED.rawValue
        {
            del?.updateEta(eta: formatedETA(eta: booking!.eta))
        }
        else {
            del?.hideEtaView()
            
        }
    }
    
    func formatedETA(eta: Int64) -> String {
        //        if eta/60 < 60 {
        //
        //            return "1 min"
        //        }
        
        let formatedEta : Double = Double(eta)/60
        return "\(Int(ceil(Double(formatedEta)))) min"
        
    }
    
    override func viewWillDisappear()
    {
        stopVehicleUpdateTimer()
        deleteTemporaryBooking()
    }
    
    func deleteTemporaryBooking()
    {
        if(booking != nil)
        {
            booking!.mr_deleteEntity()
        }
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
        if(booking?.bookingStatus == BookingStatus.CANCELLED.rawValue)
        {
            del?.hideDriverInfoBox()
        }
        else if booking?.driverName != nil && !(booking?.driverName?.isEmpty)!
        {
            //del?.hideDriverInfoBox()
            del?.updateAssignmentInfo()
        }
        else {
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
        return (booking?.callerId)!
    }
    
    //MARK:- BookingCard
    func updateBookingCard() {
        del?.updateBookingCard()
        
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
            msg = "(\((booking?.pickupMessage!)!))"
        }
        return msg
    }
    
    func pickAddress() -> String{
        
        return  (booking?.pickupAddress!)!
    }
    
    func dropAddress() -> String{
        var dropAdd : String?
        
        
        dropAdd = booking?.dropOffAddress
        if dropAdd == nil || (dropAdd?.isEmpty)! {
            
            dropAdd = "No Destination Set"
        }
        
        return dropAdd!
    }
    
    func cellBGColor() -> UIColor{
        var color : UIColor = UIColor.white
        
        switch booking?.bookingStatus {
        case BookingStatus.CONFIRMED.rawValue?,  BookingStatus.ARRIVED.rawValue?,BookingStatus.PICKUP.rawValue?:
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
    
    func pickupDateOfMonth() -> String{
        
        return booking!.pickupTime!.dayOfMonth()
    }
    
    func pickupMonth() -> String{
        
        return booking!.pickupTime!.threeLetterMonth()
        
    }
    
    func pickupYear() -> String{
        
        return booking!.pickupTime!.year()
        
    }
    
    func pickupDayAndTime() -> String{
        
        let day = booking!.pickupTime!.dayOfWeek()
        let time = booking!.pickupTime!.timeWithAMPM()
        
        let dayAndTime = "\(day), \(time)"
        
        return dayAndTime
    }
    
    func paymentMethod() -> String
    {
        var paymentMethod = "Cash"
        let bookingStatus = bookingStatii()
        if(bookingStatus == BookingStatus.PICKUP.rawValue || bookingStatus == BookingStatus.ARRIVED.rawValue || bookingStatus == BookingStatus.CONFIRMED.rawValue || bookingStatus == BookingStatus.PENDING.rawValue || bookingStatus == BookingStatus.DISPATCHING.rawValue)
        {
            //Skipping the payment method because the booking hasn't been completed yet, so sticking to cash, it will be changed once we work for pre-paid payment
        }
        else if(!(booking!.lastFourDigits == "Cash" || booking!.lastFourDigits == "" || booking!.lastFourDigits == "CASH" || booking!.lastFourDigits == nil))
        {
            paymentMethod = "**** " +  booking!.lastFourDigits!
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
        case VehicleType.KTCityTaxi.rawValue, VehicleType.KTAirportSpare.rawValue, VehicleType.KTAiport7Seater.rawValue,VehicleType.KTSpecialNeedTaxi.rawValue:
            type = "TAXI"
            
        case VehicleType.KTCityTaxi7Seater.rawValue:
            type = "7 SEATER"
            
        case VehicleType.KTStandardLimo.rawValue:
            type = "STANDARD"
            
        case VehicleType.KTBusinessLimo.rawValue:
            type = "BUSINESS"
            
        case VehicleType.KTLuxuryLimo.rawValue:
            type = "LUXURY"
        default:
            type = ""
        }
        return type
    }
    
    func bookingStatusImage() -> UIImage? {
        
        var img : UIImage?
        switch booking!.bookingStatus {
            
        case BookingStatus.COMPLETED.rawValue:
            img = UIImage(named:"MyTripsCompleted")
        case BookingStatus.ARRIVED.rawValue:
            img = UIImage(named:"MyTripsArrived")
        case BookingStatus.CONFIRMED.rawValue:
            img = UIImage(named:"MyTripsAssigned")
        case BookingStatus.CANCELLED.rawValue:
            img = UIImage(named:"MyTripsCancelled")
        case BookingStatus.PENDING.rawValue, BookingStatus.DISPATCHING.rawValue:
            img = UIImage(named:"MyTripsScheduled")
        case BookingStatus.TAXI_NOT_FOUND.rawValue, BookingStatus.TAXI_UNAVAIALBE.rawValue, BookingStatus.NO_TAXI_ACCEPTED.rawValue:
            img = UIImage(named:"MyTripNoRideFound")
        case BookingStatus.PICKUP.rawValue:
            img = UIImage.gifImageWithName("MyTripHired")
        default:
            img = UIImage()
            print("Do nothing")
            
        }
        
        return img
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
            del?.showCurrentLocationDot(show: false)
            showPickDropMarker(showOnlyPickup: true)
        }
        else if bStatus ==  BookingStatus.CANCELLED || bStatus == BookingStatus.EXCEPTION || bStatus ==  BookingStatus.NO_TAXI_ACCEPTED || bStatus == BookingStatus.TAXI_NOT_FOUND || bStatus == BookingStatus.TAXI_UNAVAIALBE
        {
            del?.clearMaps()
            showPickDropMarker()
        }
        else if(bStatus == BookingStatus.PICKUP)
        {
            del?.initializeMap(location: CLLocationCoordinate2D(latitude: (booking?.pickupLat)!,longitude: (booking?.pickupLon)!))
            del?.showCurrentLocationDot(show: false)
            startVechicleTrackTimer()
        }
        else if  bStatus == BookingStatus.ARRIVED || bStatus == BookingStatus.CONFIRMED
        {
            del?.initializeMap(location: CLLocationCoordinate2D(latitude: (booking?.pickupLat)!,longitude: (booking?.pickupLon)!))
            del?.showCurrentLocationDot(show: false)
            showPickDropMarker(showOnlyPickup: true)
            startVechicleTrackTimer()
        }
        else if bStatus == BookingStatus.COMPLETED
        {
            del?.clearMaps()
            showPickDropMarker(showOnlyPickup: false)

            if booking?.tripTrack != nil && booking?.tripTrack?.isEmpty == false
            {
                del?.initializeMap(location: CLLocationCoordinate2D(latitude: (booking?.pickupLat)!,longitude: (booking?.pickupLon)!))
                snapTrackToRoad(track: (booking?.tripTrack)!)
            }
        }
        else
        {
            del?.initializeMap(location: CLLocationCoordinate2D(latitude: (booking?.pickupLat)!,longitude: (booking?.pickupLon)!))
        }
    }
    
    @objc func fetchBooking(_ bookingId : String, _ isFromBookingId : Bool)
    {
        self.del?.showProgressHud(show: true, status: "Fetching Trip Information")

        //TODO: Show expired link here
        
        KTBookingManager().booking(bookingId as String, isFromBookingId) { (status, response) in
            
                self.del?.hideProgressHud()

                if status == Constants.APIResponseStatus.SUCCESS
                {
                    let updatedBooking : KTBooking = response[Constants.ResponseAPIKey.Data] as! KTBooking
                    self.bookingUpdateTriggered(updatedBooking)
                    self.del?.showDriverInfoBox()
                }
                else
                {
                    self.del?.showErrorBanner("   ", response["M"] as! String)
//                    let expiredAlt = UIAlertController(title: response["T"] as! String, message: response["M"] as! String, preferredStyle: UIAlertControllerStyle.alert)
//
//                    expiredAlt.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.destructive, handler: { (action) in
//
//                        (self.viewModel as! KTSettingsViewModel).logout()
//                    }))
//
//                    self.present(expiredAlt, animated: true, completion: nil)
                }
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
            del?.initializeMap(location: CLLocationCoordinate2D(latitude: (booking?.pickupLat)!,longitude: (booking?.pickupLon)!))
        }
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
                    self.del?.showUpdateVTrackMarker(vTrack: vtrack)
                    
                    if(vtrack.status == self.VEHICLE_STATUS_HIRED && !self.isHiredShown)
                    {
                        self.booking?.bookingStatus = BookingStatus.PICKUP.rawValue
                        self.isHiredShown = true
                        self.del?.updateBookingStatusOnCard(true)
                        self.del?.hideEtaView()
                        self.del?.showSuccessBanner("  ", "Trip has been started")
                    }
                    
                    if(bStatus != BookingStatus.PICKUP)
                    {
                        self.del?.updateMapCamera()
                    }
                    
                    self.del?.updateEta(eta: self.formatedETA(eta: vtrack.eta))
                    
                    if bStatus == BookingStatus.ARRIVED || bStatus == BookingStatus.CONFIRMED
                    {
                        self.fetchRouteToPickupOrDropOff(vTrack: vtrack, destinationLat: (self.booking?.pickupLat)!, destinationLong: (self.booking?.pickupLon)!)
                    }
                    else if(bStatus == BookingStatus.PICKUP && self.booking?.dropOffLat != nil && self.booking?.dropOffLon != nil)
                    {
                        self.fetchRouteToPickupOrDropOff(vTrack: vtrack, destinationLat: (self.booking?.dropOffLat)!, destinationLong: (self.booking?.dropOffLon)!)
                    }
                }
                else
                {
                    self.stopVehicleUpdateTimer()
                    self.del?.showSuccessBanner("  ", "Trip status has been updated")
                    self.fetchBooking((self.booking?.bookingId)!, true)
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
    
    private func fetchRouteToPickupOrDropOff(vTrack ride: VehicleTrack, destinationLat lat: Double, destinationLong long: Double)
    {
        let origin = "\(ride.position.latitude),\(ride.position.longitude)"
        let destination = "\(lat),\(long)"
        
        
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=\(Constants.GOOGLE_SNAPTOROAD_API_KEY)"
        
        Alamofire.request(url).responseJSON { response in
            
            do
            {
                let json = try JSON(data: response.data!)
                let routes = json["routes"].arrayValue
                
                for route in routes
                {
                    let routeOverviewPolyline = route["overview_polyline"].dictionary
                    let points = routeOverviewPolyline?["points"]?.stringValue
                    
                    self.del?.showRouteOnMap(points: points!)
                }
            } catch
            {
                
            }
        }
    }
    
    func parseVehicleTrack(track rtrack : [AnyHashable:Any]) -> VehicleTrack {
        
        let track : VehicleTrack = VehicleTrack()
        //track.vehicleNo = rtrack["VehicleNo"] as! String
        track.position = CLLocationCoordinate2D(latitude: (rtrack["Lat"] as? CLLocationDegrees)!, longitude: (rtrack["Lon"] as? CLLocationDegrees)!)
        //track.vehicleType = rtrack["VehicleType"] as! Int
        track.bearing = (rtrack["Bearing"] as! NSNumber).floatValue
        track.eta = rtrack["CurrentETA"] as! Int64
        track.status = rtrack["Status"] as! Int
        track.trackType = VehicleTrackType.vehicle
        return track
    }
    
    func imgForTrackMarker() -> UIImage {
        
        var img : UIImage?
        switch booking?.vehicleType  {
        case VehicleType.KTAirportSpare.rawValue?, VehicleType.KTCityTaxi.rawValue?,VehicleType.KTSpecialNeedTaxi.rawValue?:
            img = UIImage(named:"BookingMapTaxiIco")
            
        case VehicleType.KTCityTaxi7Seater.rawValue?:
            img = UIImage(named: "BookingMap7Ico")
            
        case VehicleType.KTStandardLimo.rawValue?:
            img = UIImage(named: "BookingMapStandardIco")
        case VehicleType.KTBusinessLimo.rawValue?:
            img = UIImage(named: "BookingMapBusinessIco")
            
        case VehicleType.KTLuxuryLimo.rawValue?:
            img = UIImage(named: "BookingMapLuxuryIco")
        default:
            img = UIImage(named:"BookingMapTaxiIco")
        }
        return img!
    }
    
    
    func snapTrackToRoad(track : String) {
        let url = "https://roads.googleapis.com/v1/snapToRoads?path=\(track)&interpolate=true&key=\(Constants.GOOGLE_SNAPTOROAD_API_KEY)"
        //let url = "https://maps.googleapis.com/maps/api/directions/json?origin=25.269500,51.533400&destination=25.269900,51.532800&mode=driving&key=AIzaSyCcK4czilOp9CMilAGmbq47i6HQk18q7Tw"
        
        //let url = "https://roads.googleapis.com/v1/snapToRoads?path=-35.27801,149.12958|-35.28032,149.12907|-35.28099,149.12929|-35.28144,149.12984|-35.28194,149.13003|-35.28282,149.12956|-35.28302,149.12881|-35.28473,149.12836&interpolate=true&key=AIzaSyCcK4czilOp9CMilAGmbq47i6HQk18q7Tw"
        
        
        let encodedUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        Alamofire.request(encodedUrl!, method: .get, parameters: nil, headers: nil).responseJSON { (response:DataResponse<Any>) in
            print(response)
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
                    do {
                        guard response.result.isSuccess else {
                            return
                        }
                        guard response.response?.statusCode == 200 else {
                            return
                        }
                        let json = try JSON(data: response.data!)
                        let path = GMSMutablePath()
                        
                        for p in json["snappedPoints"].object as! [ Dictionary<String,Any>] {
                            path.add(CLLocationCoordinate2D(latitude: (p["location"] as! [AnyHashable: Any])["latitude"] as! CLLocationDegrees, longitude: (p["location"] as! [AnyHashable: Any])["longitude"] as! CLLocationDegrees))
                        }
                        
                        self.del?.showPathOnMap(path: path)
                        //print(json)
                        /*let routes = json["routes"].arrayValue
                         
                         for route in routes
                         {
                         let routeOverviewPolyline = route["overview_polyline"].dictionary
                         let points = routeOverviewPolyline?["points"]?.stringValue
                         
                         (self.delegate as! KTCreateBookingViewModelDelegate).addPointsOnMap(points: points!)
                         }*/
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
    
    // Triggered only when BookingDetails Controller is in focus
    func bookingUpdateTriggered(_ updatedBooking: KTBooking)
    {
        self.booking = updatedBooking

        if booking!.bookingStatus == BookingStatus.ARRIVED.rawValue || booking?.bookingStatus == BookingStatus.PICKUP.rawValue || booking?.bookingStatus == BookingStatus.CONFIRMED.rawValue
        {
            initializeViewWRTBookingStatus()
            del?.updateBookingStatusOnCard(false)
        }
        else if(booking?.bookingStatus == BookingStatus.CANCELLED.rawValue || booking?.bookingStatus == BookingStatus.TAXI_NOT_FOUND.rawValue || booking?.bookingStatus == BookingStatus.TAXI_UNAVAIALBE.rawValue || booking?.bookingStatus == BookingStatus.NO_TAXI_ACCEPTED.rawValue || booking?.bookingStatus == BookingStatus.COMPLETED.rawValue)
        {
//            del?.clearMaps()
//            del?.hideEtaView()
            initializeViewWRTBookingStatus()
            del?.updateBookingStatusOnCard(false)
        }
    }
}
