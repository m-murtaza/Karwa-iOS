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

protocol KTXpressRideTrackingViewModelDelegate: KTViewModelDelegate {
    func showAlertForLocationServerOn()
    func updateLocationInMap(location:CLLocation)
    func updateLocationInMap(location: CLLocation, shouldZoomToDefault withZoom : Bool)
    func setDropOff(pick: String?)
    func setPickup(pick: String?)
    func updateUI()
}

class KTXpressRideTrackingViewModel: KTBaseViewModel {
    
    var operationArea = [Area]()
    
    var rideServicePickDropOffData: RideSerivceLocationData? = nil
    
    var booking : KTBooking = KTBookingManager().booking()
    var currentBookingStep : BookingStep = BookingStep.step1  //Booking will strat with step 1
    var isFirstZoomDone = false
    static var askedToTurnOnLocaiton : Bool = false
    var selectedRide: RideVehiceInfo?
    
    var rideInfo: RideInfo?
    var timer: Timer!


    override func viewWillAppear() {
                
        super.viewWillAppear()
                    
//        //Check the drop of address name
        if self.rideServicePickDropOffData?.dropOffStop == nil && self.rideServicePickDropOffData?.dropOfSftation == nil{
            self.fetchLocationName(forGeoCoordinate: (self.rideServicePickDropOffData?.dropOffCoordinate)!, type: "Drop")
        } else {
            if self.rideServicePickDropOffData?.dropOffStop == nil {
                (delegate as? KTXpressRideTrackingViewModelDelegate)?.setDropOff(pick: self.rideServicePickDropOffData?.dropOfSftation?.name ?? "")
            } else {
                (delegate as? KTXpressRideTrackingViewModelDelegate)?.setDropOff(pick: self.rideServicePickDropOffData?.dropOffStop?.name ?? "")
            }
        }
        
        //Check the pickup address name
        if self.rideServicePickDropOffData?.pickUpStop == nil && self.rideServicePickDropOffData?.pickUpStation == nil {
            self.fetchLocationName(forGeoCoordinate: (self.rideServicePickDropOffData?.pickUpCoordinate)!, type: "Pick")
        } else {
            if  self.rideServicePickDropOffData?.pickUpStop == nil {
                (delegate as? KTXpressRideTrackingViewModelDelegate)?.setPickup(pick: self.rideServicePickDropOffData?.pickUpStation?.name ?? "")
            } else {
                (delegate as? KTXpressRideTrackingViewModelDelegate)?.setPickup(pick: self.rideServicePickDropOffData?.pickUpStop?.name ?? "")
            }
        }
//        
    
    }
    
    private func fetchLocationName(forGeoCoordinate coordinate: CLLocationCoordinate2D, type: String) {
        
        KTBookingManager().address(forLocation: coordinate, Limit: 1) { (status, response) in
            if status == Constants.APIResponseStatus.SUCCESS && response[Constants.ResponseAPIKey.Data] != nil && (response[Constants.ResponseAPIKey.Data] as! [KTGeoLocation]).count > 0{
                
                let pAddress : KTGeoLocation = (response[Constants.ResponseAPIKey.Data] as! [KTGeoLocation])[0]
                
                DispatchQueue.main.async {
                    if self.delegate != nil {
                        if type == "Drop" {
                            (self.delegate as? KTXpressRideTrackingViewModelDelegate)?
                                .setDropOff(pick: pAddress.name)
                        } else {
                            (self.delegate as? KTXpressRideTrackingViewModelDelegate)?.setPickup(pick: pAddress.name)
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
        
    
    
    func getVehicleNo(index: Int) -> String {
        return self.rideInfo?.rides[index].vehicleNo ?? ""
    }
    
    func getEstimatedTime(index: Int) -> String {
        return  "str_arrives".localized() + "\((self.rideInfo?.rides[index].eta ?? 0)/60) Mins"
    }
    
    func getBookingData() {
        KTBookingManager().syncXpressBookings(orderId: selectedRide?.id ?? "") { (status, response) in
            
            print(response)
            
//            if(response[Constants.ResponseAPIKey.Data] != nil)
//            {
//                let deltaBookings: [KTBooking] = response[Constants.ResponseAPIKey.Data] as! [Any] as! [KTBooking]
//
//                print(deltaBookings)
//
//            }
        }
        

    }
}


