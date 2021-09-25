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

protocol KTXpressRideCreationViewModelDelegate: KTViewModelDelegate {
    func showAlertForLocationServerOn()
    func updateLocationInMap(location:CLLocation)
    func updateLocationInMap(location: CLLocation, shouldZoomToDefault withZoom : Bool)
    func setDropOff(pick: String?)
    func setPickup(pick: String?)
    func setProgressViewCounter(countDown: Int)
    func showHideRideServiceView(show: Bool)
    func updateUI()
    func addMarkerForServerPickUpLocation(coordinate: CLLocationCoordinate2D)
    func showRideTrackViewController()
    func showAlertForTimeOut()
    func showAlertForFailedRide(message: String)
    func showHideNavigationBar(status: Bool)

}

public func createAttributedString(stringArray: [String], attributedPart: Int, attributes: [NSAttributedString.Key: Any]) -> NSMutableAttributedString? {
    let finalString = NSMutableAttributedString()
    for i in 0 ..< stringArray.count {
        var attributedString = NSMutableAttributedString(string: stringArray[i], attributes: nil)
        if i == attributedPart {
            attributedString = NSMutableAttributedString(string: attributedString.string, attributes: attributes)
            finalString.append(attributedString)
        } else {
            finalString.append(attributedString)
        }
    }
    return finalString
}


class KTXpressRideCreationViewModel: KTBaseViewModel {
    
    var operationArea = [Area]()
    
    var rideServicePickDropOffData: RideSerivceLocationData? = nil
    
    var booking : KTBooking = KTBookingManager().booking()
    var currentBookingStep : BookingStep = BookingStep.step1  //Booking will strat with step 1
    var isFirstZoomDone = false
    static var askedToTurnOnLocaiton : Bool = false
    var selectedRide: RideVehiceInfo?
    
    var rideInfo: RideInfo?
    var timer: Timer!
    public var selectedBooking : KTBooking?

    override func viewWillAppear() {
                
        super.viewWillAppear()
            
        //Check the drop of address name
        if self.rideServicePickDropOffData?.dropOffStop == nil && self.rideServicePickDropOffData?.dropOfSftation == nil{
            self.fetchLocationName(forGeoCoordinate: (self.rideServicePickDropOffData?.dropOffCoordinate)!, type: "Drop")
        } else {
            if self.rideServicePickDropOffData?.dropOffStop == nil {
                (delegate as! KTXpressRideCreationViewModelDelegate).setDropOff(pick: self.rideServicePickDropOffData?.dropOfSftation?.name ?? "")
            } else {
                (delegate as! KTXpressRideCreationViewModelDelegate).setDropOff(pick: self.rideServicePickDropOffData?.dropOffStop?.name ?? "")
            }
        }

        
        (delegate as! KTXpressRideCreationViewModelDelegate).showHideNavigationBar(status: true)
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
    
    func fareDetailsHeader() -> [KTKeyValue]? {
        
        guard let _ = booking.toKeyValueHeader else {
            return nil
        }
        return (booking.toKeyValueHeader?.array as! [KTKeyValue])
        
    }
    
    func fareDetailsBody() -> [KTKeyValue]? {
        guard let _ = booking.toKeyValueBody else {
            return nil
        }
        return (booking.toKeyValueBody?.array as! [KTKeyValue])
    }
    
    func fetchRideService() {
        
        self.delegate?.showProgressHud(show: true)
        
        KTXpressBookingManager().getRideService(rideData: rideServicePickDropOffData!) { [weak self] (String, response) in
            
            self?.delegate?.hideProgressHud()
            
            guard let strongSelf = self else{
                return
            }
            
            print("ridedata", response)
                        
            strongSelf.rideInfo?.rides.removeAll()
            
            var ridesVehicleInfoList = [RideVehiceInfo]()
            
            guard let rides = response["Rides"] as? [[String : Any]] else {
                if let message = response["M"] as? String {
                    (strongSelf.delegate as! KTXpressRideCreationViewModelDelegate).showAlertForFailedRide(message: message)
                }
                return
            }
            
            for item in rides {
                
                var vehicleInfo = RideVehiceInfo()
                var dropLocationInfo = LocationInfo()
                var pickUplocationInfo = LocationInfo()
                
                vehicleInfo.eta = item["Eta"] as? Int
                vehicleInfo.id = item["Id"] as? String
                vehicleInfo.vehicleNo = item["VehicleNo"] as? String
                dropLocationInfo.lat = (item["Drop"] as?[String:Double])?["lat"] ?? 0.0
                dropLocationInfo.lon = (item["Drop"] as?[String:Double])?["lon"] ?? 0.0
                pickUplocationInfo.lat = ((item["Pick"] as?[String:Double])?["lat"] ?? 0.0)
                pickUplocationInfo.lon = ((item["Pick"] as?[String:Double])?["lon"] ?? 0.0)
                vehicleInfo.drop = dropLocationInfo
                vehicleInfo.pick = pickUplocationInfo
            
                ridesVehicleInfoList.append(vehicleInfo)

            }
            
            strongSelf.rideInfo = RideInfo(rides: ridesVehicleInfoList, expirySeconds: (response["ExpirySeconds"] as! Int))
            
            print(strongSelf.rideInfo)
            
            (strongSelf.delegate as? KTXpressRideCreationViewModelDelegate)?.showHideRideServiceView(show: true)
            (strongSelf.delegate as? KTXpressRideCreationViewModelDelegate)?.setProgressViewCounter(countDown: strongSelf.rideInfo?.expirySeconds ?? 0)
            (strongSelf.delegate as? KTXpressRideCreationViewModelDelegate)?.addMarkerForServerPickUpLocation(coordinate: CLLocationCoordinate2D(latitude: (strongSelf.rideInfo?.rides[0].pick?.lat)!, longitude: (strongSelf.rideInfo?.rides[0].pick?.lon)!))

            
            (strongSelf.delegate as? KTXpressRideCreationViewModelDelegate)?.updateUI()
            
        }
        
    }
    
    //execute the order api repeatedly when nextstep as Retry
    
    @objc func fetchRideOrderStatus() {
        
        self.delegate?.showProgressHud(show: true, status: "str_fetching_data".localized())

        KTXpressBookingManager().getOrderStatus(vehicleInfo: selectedRide!) { [weak self] (String, response) in
            guard let strongSelf = self else{
                return
            }
            if String.lowercased() == "SUCCESS".lowercased() {
                strongSelf.timer = Timer.scheduledTimer(timeInterval: 3.0, target: strongSelf, selector: #selector(strongSelf.fetchRideOrderPollingStatus), userInfo: nil, repeats: true)
            } else {
                strongSelf.delegate?.hideProgressHud()
                (strongSelf.delegate as! KTXpressRideCreationViewModelDelegate).showAlertForFailedRide(message: "Ride Expired")
            }
        }
    }
    
    @objc func fetchRideOrderPollingStatus() {
        KTXpressBookingManager().getOrderPollingStatus(vehicleInfo: selectedRide!) { (String, response) in

            print("polling", (response["DispatchStatus"] as? String) ?? "")
            if let dispatchStatus = (response["DispatchStatus"] as? String), dispatchStatus == "COMPLETED" {
                self.timer.invalidate()
                self.getBookingData()
            }
            print("status", String)
            if String.contains("FAILED") {
                self.delegate?.hideProgressHud()
                (self.delegate as! KTXpressRideCreationViewModelDelegate).showAlertForFailedRide(message: "We were unable to find a ride for you. Please try again.")
                self.timer.invalidate()
            }
        }
    }
    
    func getVehicleNo(index: Int) -> String {
        return self.rideInfo?.rides[index].vehicleNo ?? ""
    }
    
    func getEstimatedTime(index: Int) -> NSAttributedString {
        if let attributedString = createAttributedString(stringArray: ["str_arrives".localized(), " \((self.rideInfo?.rides[index].eta ?? 0)/60) "+"str_mins".localized()], attributedPart: 1, attributes: [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font:  UIFont(name: "MuseoSans-700", size: 14.0)!]) {
              return attributedString
        } else {
            return NSAttributedString()
        }
    }
    
    func getRide(index: Int) {
        if let vehicleInfo = self.rideInfo?.rides[index] {
            self.selectedRide = vehicleInfo
//            return self.selectedRide
//            fetchRideOrderStatus()
        }
//        return nil
    }
    
    func setPickUpLocationForXpressRide(index: Int) {
        (self.delegate as? KTXpressRideCreationViewModelDelegate)?.addMarkerForServerPickUpLocation(coordinate: CLLocationCoordinate2D(latitude: (self.rideInfo?.rides[index].pick?.lat)!, longitude: (self.rideInfo?.rides[index].pick?.lon)!))
    }
    
    func didTapBookButton() {
//        let rideLocationData = RideSerivceLocationData(pickUpZone: pickUpZone, pickUpStation: pickUpStation, pickUpStop: pickUpStop, dropOffZone: selectedZone, dropOfSftation: selectedStation, dropOffStop: selectedStop, pickUpCoordinate: pickUpCoordinate, dropOffCoordinate: selectedCoordinate)

        self.fetchRideOrderStatus()
//        (self.delegate as! KTXpressRideCreationViewModelDelegate).showRideTrackViewController()


    }
    
    
    func getBookingData() {
        KTBookingManager().syncXpressBookings(orderId: selectedRide?.id ?? "") { (status, response) in
            
            print(response["D"])
            self.fetchBookingsFromDB()
            self.delegate?.hideProgressHud()
            
            self.selectedBooking = response["D"] as? KTBooking
            
            (self.delegate as! KTXpressRideCreationViewModelDelegate).showRideTrackViewController()

        }
    }
    
    private func fetchBookingsFromDB() {
        
        let pendingBooking : [KTBooking] = KTBookingManager().pendingXpressBookings()
        //bookings = pendingBooking
//        for b in bookings! {
//            print((b as KTBooking).callerId)
//        }
    }
}


