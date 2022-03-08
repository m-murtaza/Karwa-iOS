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
    func addMarkerForServerPickUpLocation(coordinate: CLLocationCoordinate2D, dropCoordinate: CLLocationCoordinate2D)
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
    let operationGroup = DispatchGroup()

    var rideServicePickDropOffData: RideSerivceLocationData? = nil
    
    var booking : KTBooking = KTBookingManager().booking()
    var currentBookingStep : BookingStep = BookingStep.step1  //Booking will strat with step 1
    var isFirstZoomDone = false
    static var askedToTurnOnLocaiton : Bool = false
    var selectedRide: RideVehiceInfo?
    
    var rideInfo: RideInfo?
    var timer: Timer!
    public var selectedBooking : KTBooking?
    
    var destinationForPickUp = [Area]()
    var selectedPickupZone:Area?
    var selectedPickupStop:Area?
    var selectedPickupStation:Area?
    var stopsOFPickupStations = [Area]()
    
    var selectedDropOfZone: Area?
    var selectedDropOfStop:Area?
    var selectedDropOfStation:Area?
    var stopsOFDropOfStations = [Area]()

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
    
    fileprivate func callRideService() {
        
        self.delegate?.showProgressHud(show: true, status: "str_finding".localized())

        KTXpressBookingManager().getRideService(rideData: rideServicePickDropOffData!) { [weak self] (status, response) in
            
            self?.delegate?.hideProgressHud()
            
            guard let strongSelf = self else{
                return
            }
            
            print("ridedata", response)
            
            strongSelf.rideInfo?.rides.removeAll()
            
            var ridesVehicleInfoList = [RideVehiceInfo]()
            
            //            if String == "FAILED" {
            //                (strongSelf.delegate as! KTXpressRideCreationViewModelDelegate).showAlertForFailedRide(message: "txt_ride_not_found".localized())
            //            }
            
            guard let rides = response["Rides"] as? [[String : Any]] else {
                if let message = response["M"] as? String {
                    (strongSelf.delegate as! KTXpressRideCreationViewModelDelegate).showAlertForFailedRide(message: message)
                } else if let res = response["E"] as? [String : String] {
                    if let message = res["M"] {
                        (strongSelf.delegate as! KTXpressRideCreationViewModelDelegate).showAlertForFailedRide(message: message)
                    }
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
            (strongSelf.delegate as? KTXpressRideCreationViewModelDelegate)?.addMarkerForServerPickUpLocation(coordinate: CLLocationCoordinate2D(latitude: (strongSelf.rideInfo?.rides[0].pick?.lat)!, longitude: (strongSelf.rideInfo?.rides[0].pick?.lon)!), dropCoordinate: CLLocationCoordinate2D(latitude: (strongSelf.rideInfo?.rides[0].drop?.lat)!, longitude: (strongSelf.rideInfo?.rides[0].drop?.lon)!))
            
            
            (strongSelf.delegate as? KTXpressRideCreationViewModelDelegate)?.updateUI()
            
        }
    }
    
    func fetchRideService() {
        
        self.delegate?.showProgressHud(show: true, status: "str_finding".localized())
        
        if self.rideServicePickDropOffData?.pickUpStop == nil && self.rideServicePickDropOffData?.pickUpStation == nil && self.rideServicePickDropOffData?.pickUpZone != nil {
            KTBookingManager().address(forLocation: (self.rideServicePickDropOffData?.pickUpCoordinate!)!, Limit: 1) { (status, response) in
                self.delegate?.hideProgressHud()
              if status == Constants.APIResponseStatus.SUCCESS && response[Constants.ResponseAPIKey.Data] != nil && (response[Constants.ResponseAPIKey.Data] as! [KTGeoLocation]).count > 0 {
                let pAddress : KTGeoLocation = (response[Constants.ResponseAPIKey.Data] as! [KTGeoLocation])[0]
                  self.rideServicePickDropOffData?.pickUpZoneAddress = pAddress.name ?? ""
                  self.callRideService()
              }
            }
        } else if self.rideServicePickDropOffData?.dropOffStop == nil && self.rideServicePickDropOffData?.dropOfSftation == nil && self.rideServicePickDropOffData?.dropOffZone != nil {
            KTBookingManager().address(forLocation: (self.rideServicePickDropOffData?.dropOffCoordinate!)!, Limit: 1) { (status, response) in
                self.delegate?.hideProgressHud()
              if status == Constants.APIResponseStatus.SUCCESS && response[Constants.ResponseAPIKey.Data] != nil && (response[Constants.ResponseAPIKey.Data] as! [KTGeoLocation]).count > 0 {
                let pAddress : KTGeoLocation = (response[Constants.ResponseAPIKey.Data] as! [KTGeoLocation])[0]
                  self.rideServicePickDropOffData?.dropOffZoneAddress = pAddress.name ?? ""
                  self.callRideService()
              }
            }
        }

        
        
    }
    
    //execute the order api repeatedly when nextstep as Retry
    
    @objc func fetchRideOrderStatus() {
        
        self.delegate?.showProgressHud(show: true, status: "please_dialog_msg_booking_creation".localized())

        KTXpressBookingManager().getOrderStatus(vehicleInfo: selectedRide!) { [weak self] (String, response) in
            guard let strongSelf = self else{
                return
            }
            
            if let nextStep = response["NextStep"] as? String, nextStep == "CHECK_STATUS" {
                if String.lowercased() == "SUCCESS".lowercased() {
                    strongSelf.timer = Timer.scheduledTimer(timeInterval: 3.0, target: strongSelf, selector: #selector(strongSelf.fetchRideOrderPollingStatus), userInfo: nil, repeats: true)
                } else {
                    strongSelf.delegate?.hideProgressHud()
                    (strongSelf.delegate as! KTXpressRideCreationViewModelDelegate).showAlertForFailedRide(message: "Ride Expired")
                }
            } else if let nextStep = response["NextStep"] as? String, nextStep.lowercased() == "retry"  {
                if String.lowercased() == "SUCCESS".lowercased() {
                    strongSelf.fetchRideOrderStatus()
                } else {
                    strongSelf.delegate?.hideProgressHud()
                    (strongSelf.delegate as! KTXpressRideCreationViewModelDelegate).showAlertForFailedRide(message: "Ride Expired")
                }
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
        
        let minString = ((self.rideInfo?.rides[index].eta ?? 0)/60) > 1 ? "str_mins".localized() : "str_min".localized()
        
        if let attributedString = createAttributedString(stringArray: ["str_arrives".localized(), " \((self.rideInfo?.rides[index].eta ?? 0)/60) " + minString], attributedPart: 1, attributes: [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font:  UIFont(name: "MuseoSans-700", size: 14.0)!]) {
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
        (self.delegate as? KTXpressRideCreationViewModelDelegate)?.addMarkerForServerPickUpLocation(coordinate: CLLocationCoordinate2D(latitude: (self.rideInfo?.rides[index].pick?.lat)!, longitude: (self.rideInfo?.rides[index].pick?.lon)!), dropCoordinate: CLLocationCoordinate2D(latitude: (self.rideInfo?.rides[index].drop?.lat)!, longitude: (self.rideInfo?.rides[index].drop?.lon)!))
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
    
    func getDestinationForPickUp() {
        
        destinationForPickUp.removeAll()
        selectedPickupZone = nil
        selectedPickupStation = nil
        stopsOFPickupStations.removeAll()
        
        for item in zones {
            
            let coordinates = (item.bound?.components(separatedBy: ";").map{$0.components(separatedBy: ",")}.map{$0.map({Double($0)!})}.map { (value) -> CLLocationCoordinate2D in
                return CLLocationCoordinate2D(latitude: value[0], longitude: value[1])
            })!
            
            if  CLLocationCoordinate2D(latitude: xpressRebookPickUpCoordinates.latitude, longitude: xpressRebookPickUpCoordinates.longitude).contained(by: coordinates) {
                selectedPickupZone = item
                break
            }
            
        }
        
        if let stationsOfPickupZone = zonalArea.filter{$0["zone"]?.first!.code == selectedPickupZone!.code}.first?["stations"] {
            if stationsOfPickupZone.count == 0 {
                for item in stops {
                    let station = areas.filter({$0.code! == item.parent!}).first!
                    let coordinates = (station.bound?.components(separatedBy: ";").map{$0.components(separatedBy: ",")}.map{$0.map({Double($0)!})}.map { (value) -> CLLocationCoordinate2D in
                        return CLLocationCoordinate2D(latitude: value[0], longitude: value[1])
                    })!
                    
                    if  CLLocationCoordinate2D(latitude: xpressRebookPickUpCoordinates.latitude, longitude: xpressRebookPickUpCoordinates.longitude).contained(by: coordinates) {
                        selectedPickupStation = station
                        selectedPickupStop = item
                        break
                    }
                }
            } else {
                
                for item in stationsOfPickupZone {
                    
                    let coordinates = (item.bound?.components(separatedBy: ";").map{$0.components(separatedBy: ",")}.map{$0.map({Double($0)!})}.map { (value) -> CLLocationCoordinate2D in
                        return CLLocationCoordinate2D(latitude: value[0], longitude: value[1])
                    })!
                    
                    if  CLLocationCoordinate2D(latitude: xpressRebookPickUpCoordinates.latitude, longitude: xpressRebookPickUpCoordinates.longitude).contained(by: coordinates) {
                        selectedPickupStation = item
                        break
                    }
                    
                }
            }

        }
        
        print(selectedPickupZone)
                        
        if selectedPickupStation != nil {
            print("it's inside station")
        } else {
            print("it's inside a zone")
        }
        
        var customDestinationsCode = [Int]()
        
        if selectedPickupStation != nil {
            if selectedPickupStop == nil {
                stopsOFPickupStations.append(contentsOf: areas.filter{$0.parent! == selectedPickupStation!.code!})
                _ = (selectedPickupStation!.bound?.components(separatedBy: ";").map{$0.components(separatedBy: ",")}.map{$0.map({Double($0)!})}.map { (value) -> CLLocationCoordinate2D in
                    return CLLocationCoordinate2D(latitude: value[0], longitude: value[1])
                })!
                if customDestinationsCode.count == 0{
                    customDestinationsCode = destinations.filter{$0.source! == selectedPickupStation?.code!}.map{$0.destination!}
                }
                if customDestinationsCode.count == 0 {
                    
                    if stopsOFPickupStations.count > 1 {
                        for item in stopsOFPickupStations {
                            if destinations.filter({$0.source! == item.code!}).map({$0.destination!}).count != 0 {
                                customDestinationsCode.append(contentsOf: destinations.filter{$0.source! == item.code!}.map{$0.destination!})
//                                selectedPickupStop = item
                            }
                        }
                    } else {
                        selectedPickupStop = stopsOFPickupStations.first!
                    }
                    
                }
                for item in customDestinationsCode {
                    destinationForPickUp.append(contentsOf: areas.filter{$0.code! == item})
                }
                
                if stopsOFPickupStations.count == 1 {
                    selectedPickupStop = stopsOFPickupStations.first!
                }
                
                print("destinationForPickUp", destinationForPickUp)
            }
        } else {
            customDestinationsCode = destinations.filter{$0.source == selectedPickupZone?.code}.map{$0.destination!}
            for item in customDestinationsCode {
                destinationForPickUp.append(contentsOf: areas.filter{$0.code! == item})
            }
            print(destinationForPickUp)
        }
        
    }
    
    func getDestination() {
        
        selectedDropOfZone = nil
        selectedDropOfStation = nil
        stopsOFDropOfStations.removeAll()
        
        let stations = destinationForPickUp.filter{$0.type != "Zone"}

        if stations.count == 1 {
            if stations.first!.type == "MetroStop" || stations.first!.type == "TramStop" {
                selectedDropOfStation = areas.filter({$0.code! == stations.first!.parent!}).first!
                selectedDropOfStop = stations.first!
            } else {
                selectedDropOfStation = stations.first!
            }
            
        } else {
            for item in stations {
                
                if item.type == "MetroStop" || item.type == "TramStop" {
                    let dropOfStation = areas.filter({$0.code! == item.parent!}).first!
                    let coordinates = (dropOfStation.bound?.components(separatedBy: ";").map{$0.components(separatedBy: ",")}.map{$0.map({Double($0)!})}.map { (value) -> CLLocationCoordinate2D in
                        return CLLocationCoordinate2D(latitude: value[0], longitude: value[1])
                    })!
                    if  CLLocationCoordinate2D(latitude: xpressRebookDropOffCoordinates.latitude, longitude: xpressRebookDropOffCoordinates.longitude).contained(by: coordinates) {
                        selectedDropOfStation = dropOfStation
                        selectedDropOfStop = item
                        break
                    }
                }

                let coordinates = (item.bound?.components(separatedBy: ";").map{$0.components(separatedBy: ",")}.map{$0.map({Double($0)!})}.map { (value) -> CLLocationCoordinate2D in
                    return CLLocationCoordinate2D(latitude: value[0], longitude: value[1])
                })!
                if  CLLocationCoordinate2D(latitude: xpressRebookDropOffCoordinates.latitude, longitude: xpressRebookDropOffCoordinates.longitude).contained(by: coordinates) {
                    selectedDropOfStation = item
                    break
                }
            }
        }
        
        
        if selectedDropOfStation != nil {
            selectedDropOfZone = areas.filter{$0.code == selectedDropOfStation!.parent}.first!
        } else {
            
            let zones = destinationForPickUp.filter{$0.type == "Zone"}
            
            if zones.count == 1 {
                selectedDropOfZone = zones.first!
            } else {
                for item in zones {
                    let coordinates = (item.bound?.components(separatedBy: ";").map{$0.components(separatedBy: ",")}.map{$0.map({Double($0)!})}.map { (value) -> CLLocationCoordinate2D in
                        return CLLocationCoordinate2D(latitude: value[0], longitude: value[1])
                    })!
                    if  CLLocationCoordinate2D(latitude: xpressRebookDropOffCoordinates.latitude, longitude: xpressRebookDropOffCoordinates.longitude).contained(by: coordinates) {
                        selectedDropOfZone = item
                        break
                    }
                }
            }
            
            if selectedDropOfZone  != nil {
                let stationsOfDropOfZone = zonalArea.filter{$0["zone"]?.first!.code == selectedDropOfZone!.code}.first!["stations"]
                for item in stationsOfDropOfZone! {
                    let coordinates = (item.bound?.components(separatedBy: ";").map{$0.components(separatedBy: ",")}.map{$0.map({Double($0)!})}.map { (value) -> CLLocationCoordinate2D in
                        return CLLocationCoordinate2D(latitude: value[0], longitude: value[1])
                    })!
                    if  CLLocationCoordinate2D(latitude: xpressRebookDropOffCoordinates.latitude, longitude: xpressRebookDropOffCoordinates.longitude).contained(by: coordinates) {
                        selectedDropOfStation = item
                        break
                    }
                }
            }
                        
        }
        
        if selectedDropOfStation != nil && selectedDropOfStop == nil {
            print("it's inside station")
            stopsOFDropOfStations.append(contentsOf: stops.filter{$0.parent! == selectedDropOfStation!.code!})
            if stopsOFDropOfStations.count == 1 {
                selectedDropOfStop = stopsOFDropOfStations.first!
            }
        } else {
            print("it's inside a zone")
        }
        
        print(selectedDropOfZone)
        print(selectedDropOfStation)
        
        if stopsOFPickupStations.count > 1 {
            for item in stopsOFPickupStations {
                let customDestination = destinations.filter({$0.source! == item.code!}).map({$0.destination!})
                if customDestination.count != 0 {
                    for des in customDestination {
                        if selectedDropOfZone?.code! == des {
                            selectedPickupStop = item
                            print("selectedPickupStop", selectedPickupStop)
                        }
                    }
                }
            }
        }
        
        rideServicePickDropOffData = RideSerivceLocationData(pickUpZone: self.selectedPickupZone, pickUpStation: self.selectedPickupStation, pickUpStop: self.selectedPickupStop, dropOffZone: self.selectedDropOfZone, dropOfSftation: self.selectedDropOfStation, dropOffStop: self.selectedDropOfStop, pickUpCoordinate: xpressRebookPickUpCoordinates, dropOffCoordinate: xpressRebookDropOffCoordinates, passsengerCount: xpressRebookNumberOfPassenger)
        
        
    }
}


