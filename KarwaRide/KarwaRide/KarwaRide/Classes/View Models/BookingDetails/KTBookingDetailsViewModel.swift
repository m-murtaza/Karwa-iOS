//
//  KTBookingDetailsViewModel.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 3/15/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON
import GoogleMaps


protocol KTBookingDetailsViewModelDelegate: KTViewModelDelegate {
    func initializeMap(location : CLLocationCoordinate2D)
    func showCurrentLocationDot(show: Bool)
    func showUpdateVTrackMarker(vTrack: VehicleTrack)
    func showPathOnMap(path: GMSPath)
    func updateBookingCard()
    func showPopupForCancelBooking()
    func popViewController()
    func updateBookingCardForCompletedBooking()
    func updateBookingCardForUnCompletedBooking()
    
    func addPickupMarker(location : CLLocationCoordinate2D)
    func addDropOffMarker(location : CLLocationCoordinate2D)
    func setMapCamera(bound : GMSCoordinateBounds)
    
    func updateAssignmentInfo()
    func hideDriverInfoBox()
    
    func updateEta(eta: String)
    func hideEtaView()
    
    func updateLeftBottomBarButtom(title: String, color: UIColor,tag: Int)
    func updateRightBottomBarButtom(title: String, color: UIColor, tag: Int)
}

enum BottomBarBtnTag : Int {
    case Cancel = 101
    case FareBreakdown = 102
    case Rebook = 103
    case EBill = 104
}

class KTBookingDetailsViewModel: KTBaseViewModel {

    var booking : KTBooking?
    var del : KTBookingDetailsViewModelDelegate?
    
    private var timerVechicleTrack : Timer = Timer()
    
    override func viewDidLoad() {
        del = self.delegate as? KTBookingDetailsViewModelDelegate
        initializeViewWRTBookingStatus()
    }
    
    func initializeViewWRTBookingStatus() {
    
        //Check for booking == nil
        guard let _ = booking else {
            return
        }
        
        updateMap()
        updateEta()
        updateBookingCard()
        updateAssignmentInfo()
        updateBottomBarButtons()
    }
    
    func bookingId() -> String {
        
        return (booking?.bookingId)!
    }
    
    func bookingStatii() -> Int32 {
        return (booking?.bookingStatus)!
    }
    
    
    //MARK:- ETA View
    func updateEta() {
        
        if booking?.bookingStatus == BookingStatus.CONFIRMED.rawValue || booking?.bookingStatus == BookingStatus.ARRIVED.rawValue {
            
            del?.updateEta(eta: "\(booking!.eta)")
        }
        else {
            del?.hideEtaView()
            
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
        if booking?.driverName != nil && !(booking?.driverName?.isEmpty)! {
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
    //MARK:- BookingCard
    func updateBookingCard() {
        del?.updateBookingCard()
        
        if booking?.bookingStatus == BookingStatus.COMPLETED.rawValue {
            
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
        
            return (booking!.pickupTime! as NSDate).dayOfMonth()
    }
    
    func pickupMonth() -> String{
        
        return (booking!.pickupTime! as NSDate).threeLetterMonth()
        
    }
    
    func pickupYear() -> String{
        
        return (booking!.pickupTime! as NSDate).year()
        
    }
    
    func pickupDayAndTime() -> String{
        
        let day = (booking!.pickupTime! as NSDate).dayOfWeek()
        let time = (booking!.pickupTime! as NSDate).timeWithAMPM()
        
        let dayAndTime = "\(day), \(time)"
        
        return dayAndTime
    }
    
    func vehicleType() -> String {
        
        var type : String = ""
        switch booking!.vehicleType {
        case VehicleType.KTCityTaxi.rawValue, VehicleType.KTAiportTaxi.rawValue, VehicleType.KTAirportSpare.rawValue, VehicleType.KTAiport7Seater.rawValue,VehicleType.KTSpecialNeedTaxi.rawValue:
            type = "TAXI"
            
        case VehicleType.KTStandardLimo.rawValue:
            type = "STANDARD"
            
        case VehicleType.KTBusinessLimo.rawValue:
            type = "Business"
            
        case VehicleType.KTLuxuryLimo.rawValue:
            type = "Luxury"
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
        var estimate : String = ""
        if booking!.estimatedFare != nil {
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
        if  bStatus == BookingStatus.ARRIVED || bStatus == BookingStatus.CONFIRMED || bStatus == BookingStatus.PICKUP {
            del?.initializeMap(location: CLLocationCoordinate2D(latitude: (booking?.pickupLat)!,longitude: (booking?.pickupLon)!))
            del?.showCurrentLocationDot(show: true)
            startVechicleTrackTimer()
        }
        else if bStatus == BookingStatus.COMPLETED {
            if booking?.tripTrack != nil && booking?.tripTrack?.isEmpty == false {
                del?.initializeMap(location: CLLocationCoordinate2D(latitude: (booking?.pickupLat)!,longitude: (booking?.pickupLon)!))
                snapTrackToRoad(track: (booking?.tripTrack)!)
            }
        }
        else if bStatus ==  BookingStatus.CANCELLED || bStatus == BookingStatus.EXCEPTION || bStatus ==  BookingStatus.NO_TAXI_ACCEPTED || bStatus == BookingStatus.TAXI_NOT_FOUND || bStatus == BookingStatus.TAXI_UNAVAIALBE {
            
            showPickDropMarker()
        }
        else {
            del?.initializeMap(location: CLLocationCoordinate2D(latitude: (booking?.pickupLat)!,longitude: (booking?.pickupLon)!))
        }
    }
    
    func startVechicleTrackTimer() {
        timerVechicleTrack = Timer.scheduledTimer(timeInterval: 3, target: self,   selector: (#selector(self.fetchTaxiForTracking)), userInfo: nil, repeats: true)
        
    }
    
    func showPickDropMarker() {
        
        let bounds : GMSCoordinateBounds = GMSCoordinateBounds()
        
        if booking?.pickupLat != nil && booking?.pickupLon != nil && !(booking?.pickupLat.isZero)! && !(booking?.pickupLon.isZero)! {
            
            let location : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: (booking?.pickupLat)!,longitude: (booking?.pickupLon)!)
            del?.addPickupMarker(location: location)
            bounds.includingCoordinate(location)
        }
        
        if booking?.dropOffLat != nil && booking?.dropOffLon != nil && !(booking?.dropOffLat.isZero)! && !(booking?.dropOffLon.isZero)! {
            
            let location : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: (booking?.dropOffLat)!,longitude: (booking?.dropOffLon)!)
            del?.addDropOffMarker(location: location)
            bounds.includingCoordinate(location)
        }
        
        if bounds.isValid {
            del?.setMapCamera(bound: bounds)
        }
        else {
            del?.initializeMap(location: CLLocationCoordinate2D(latitude: (booking?.pickupLat)!,longitude: (booking?.pickupLon)!))
        }
        
    }
    
    @objc func fetchTaxiForTracking() {
        
        //TODO: Fetch booking data again may be after 10 sec
        let bStatus = BookingStatus(rawValue: (booking?.bookingStatus)!)
        if  bStatus == BookingStatus.ARRIVED || bStatus == BookingStatus.CONFIRMED || bStatus == BookingStatus.PICKUP {
            KTBookingManager().trackVechicle(jobId: (booking?.bookingId)!,vehicleNumber: (booking?.vehicleNo)!, completion: {
                (status, response) in
                if status == Constants.APIResponseStatus.SUCCESS {
                    let vtrack : VehicleTrack = self.parseVehicleTrack(track: response)
                    self.del?.showUpdateVTrackMarker(vTrack: vtrack)
                }
            })
        }
        else {
            
            if timerVechicleTrack.isValid {
                timerVechicleTrack.invalidate()
                //TODO: Update UI.
            }
        }
    }
    
    func parseVehicleTrack(track rtrack : [AnyHashable:Any]) -> VehicleTrack {
        
        let track : VehicleTrack = VehicleTrack()
        //track.vehicleNo = rtrack["VehicleNo"] as! String
        track.position = CLLocationCoordinate2D(latitude: (rtrack["Lat"] as? CLLocationDegrees)!, longitude: (rtrack["Lon"] as? CLLocationDegrees)!)
        //track.vehicleType = rtrack["VehicleType"] as! Int
        track.bearing = rtrack["Bearing"] as! Float
        track.trackType = VehicleTrackType.vehicle
        return track
    }
    
    func imgForTrackMarker() -> UIImage {
        
        var img : UIImage?
        switch booking?.vehicleType  {
            case VehicleType.KTAiportTaxi.rawValue?, VehicleType.KTAirportSpare.rawValue?, VehicleType.KTCityTaxi.rawValue?,VehicleType.KTSpecialNeedTaxi.rawValue?,VehicleType.KTAiport7Seater.rawValue? :
                img = UIImage(named:"BookingMapTaxiIco")
        
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
    
    //MARK:- Bottom Bar buttons
    func updateBottomBarButtons() {
        
        if booking?.bookingStatus == BookingStatus.ARRIVED.rawValue || booking?.bookingStatus == BookingStatus.DISPATCHING.rawValue || booking?.bookingStatus == BookingStatus.PENDING.rawValue || booking?.bookingStatus == BookingStatus.CONFIRMED.rawValue {
            
            del?.updateLeftBottomBarButtom(title: "FARE DETAILS", color: UIColor(hexString:"#129793"), tag: BottomBarBtnTag.FareBreakdown.rawValue)
            
            del?.updateRightBottomBarButtom(title: "CANCEL BOOKING", color: UIColor(hexString:"#E74C3C"), tag: BottomBarBtnTag.Cancel.rawValue)
        }
        else if booking?.bookingStatus == BookingStatus.COMPLETED.rawValue {
            del?.updateLeftBottomBarButtom(title: "TRIP E-BILL", color: UIColor(hexString:"#129793"), tag: BottomBarBtnTag.FareBreakdown.rawValue)
            
            del?.updateRightBottomBarButtom(title: "BOOK AGAIN", color: UIColor(hexString:"#26ADF0"), tag: BottomBarBtnTag.Rebook.rawValue)
        }
        else if booking?.bookingStatus == BookingStatus.CANCELLED.rawValue || booking?.bookingStatus == BookingStatus.TAXI_NOT_FOUND.rawValue || booking?.bookingStatus == BookingStatus.TAXI_UNAVAIALBE.rawValue || booking?.bookingStatus == BookingStatus.NO_TAXI_ACCEPTED.rawValue {
            
            del?.updateLeftBottomBarButtom(title: "", color: UIColor(hexString:"#129793"), tag: BottomBarBtnTag.FareBreakdown.rawValue)
            
            del?.updateRightBottomBarButtom(title: "BOOK AGAIN", color: UIColor(hexString:"#26ADF0"), tag: BottomBarBtnTag.Rebook.rawValue)
            
        }
    }
    
    func buttonTapped(withTag tag:Int) {
        //if tag == BottomBarBtnTag.Cancel.rawValue {
           del?.showPopupForCancelBooking()
        //}
    }
    
    func cancelBooking() {
    
        KTBookingManager().cancelBooking(bookingId: (booking?.bookingId)!) { (status, response) in
            self.del?.popViewController()
        }
    }
    
}
