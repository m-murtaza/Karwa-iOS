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
}

class KTXpressRideCreationViewModel: KTBaseViewModel {
    
    var operationArea = [Area]()
    
    var rideServicePickDropOffData: RideSerivceLocationData? = nil
    
    var booking : KTBooking = KTBookingManager().booking()
    var currentBookingStep : BookingStep = BookingStep.step1  //Booking will strat with step 1
    var isFirstZoomDone = false
    static var askedToTurnOnLocaiton : Bool = false
    
    var rideInfo: RideInfo?

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
        
        KTXpressBookingManager().getRideService(rideData: rideServicePickDropOffData!) { [self] (String, response) in
                        
            print("ridedata", response)
                        
            self.rideInfo?.rides.removeAll()
            
            var ridesVehicleInfoList = [RideVehiceInfo]()
            
            guard let rides = response["Rides"] as? [[String : Any]] else {
                return
            }
            
            for item in rides {
                
                var vehicleInfo = RideVehiceInfo()
                var dropLocationInfo = LocationInfo()
                var pickUplocationInfo = LocationInfo()
                
                vehicleInfo.eta = item["Eta"] as? Int
                vehicleInfo.id = item["Id"] as? String
                vehicleInfo.vehicleNo = item["VehicleNo"] as? String
                dropLocationInfo.lat = Double((item["Drop"] as?[String:String])?["lat"] ?? "0.0")
                dropLocationInfo.lon = Double((item["Drop"] as?[String:String])?["lon"] ?? "0.0")
                pickUplocationInfo.lat = Double((item["Pick"] as?[String:String])?["lat"] ?? "0.0")
                pickUplocationInfo.lon = Double((item["Pick"] as?[String:String])?["lon"] ?? "0.0")
                vehicleInfo.drop = dropLocationInfo
                vehicleInfo.pick = pickUplocationInfo
            
                ridesVehicleInfoList.append(vehicleInfo)

            }
            
            self.rideInfo = RideInfo(rides: ridesVehicleInfoList, expirySeconds: response["ExpirySeconds"] as! Int)
            
            print(self.rideInfo)
            
            (self.delegate as? KTXpressRideCreationViewModelDelegate)?.showHideRideServiceView(show: true)
            (self.delegate as? KTXpressRideCreationViewModelDelegate)?.setProgressViewCounter(countDown: self.rideInfo?.expirySeconds ?? 0)
            
            (self.delegate as? KTXpressRideCreationViewModelDelegate)?.updateUI()
            
        }
        
    }
    
    func getVehicleNo(index: Int) -> String {
        return self.rideInfo?.rides[index].vehicleNo ?? ""
    }
    
    func getEstimatedTime(index: Int) -> String {
        return  "Arrives" + "\(self.rideInfo?.rides[index].eta ?? 0) Mins"
    }
    
    func getPickUpCoordinateFromServer(index: Int) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: (self.rideInfo?.rides[index].pick?.lat)!, longitude: (self.rideInfo?.rides[index].pick?.lon))
    }
    
    
}


