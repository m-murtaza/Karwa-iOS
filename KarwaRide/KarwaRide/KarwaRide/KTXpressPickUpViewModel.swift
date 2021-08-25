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

protocol KTXpressPickUpViewModelDelegate: KTViewModelDelegate {
    func showAlertForLocationServerOn()
    func updateLocationInMap(location:CLLocation)
    func updateLocationInMap(location: CLLocation, shouldZoomToDefault withZoom : Bool)
    func setPickUp(pick: String?)
    func setPolygon()
    func addPickUpLocations()
    func showDropOffViewController(destinationForPickUp: [Area], pickUpStation: Area?, pickUpStop: Area?, pickUpzone: Area?, coordinate: CLLocationCoordinate2D, zonalArea: [[String : [Area]]])
    func showStopAlertViewController(stops: [Area], selectedStation: Area)
}

class KTXpressPickUpViewModel: KTBaseViewModel {
    
    var booking : KTBooking = KTBookingManager().booking()
    var currentBookingStep : BookingStep = BookingStep.step1  //Booking will strat with step 1
    var isFirstZoomDone = false
    static var askedToTurnOnLocaiton : Bool = false
    
    var areas = [Area]()
    var destinations = [Destination]()
    var pickUpArea = [Area]()
    var metroStopsArea = [Area]()
    var metroStations = [Area]()
    var tramStations = [Area]()
    var tramStopsArea = [Area]()
    var destinationForPickUp = [Area]()
    var selectedCoordinate: CLLocationCoordinate2D?

    var zones = [Area]()
    var zonalArea = [[String : [Area]]]()
    
    var selectedZone:Area?
    var selectedStop:Area?
    var selectedStation:Area?
    var stopsOFStations = [Area]()

    override func viewWillAppear() {
        setupCurrentLocaiton()
        super.viewWillAppear()
    }
    
    override func viewDidAppear() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.LocationManagerLocaitonUpdate(notification:)), name: Notification.Name(Constants.Notification.XpressLocationManager), object: nil)
    }

    func setupCurrentLocaiton() {
      if KTLocationManager.sharedInstance.locationIsOn() {
        if KTLocationManager.sharedInstance.isLocationAvailable {
          var notification : Notification = Notification(name: Notification.Name(rawValue: Constants.Notification.LocationManager))
          var userInfo : [String :Any] = [:]
          userInfo["location"] = KTLocationManager.sharedInstance.baseLocation
          
          notification.userInfo = userInfo
          //notification.userInfo!["location"] as! CLLocation
          LocationManagerLocaitonUpdate(notification: notification)
        }
        else {
          KTLocationManager.sharedInstance.start()
        }
      }
      else if KTXpressPickUpViewModel.askedToTurnOnLocaiton == false{
        (delegate as! KTXpressPickUpViewModelDelegate).showAlertForLocationServerOn()
        KTXpressPickUpViewModel.askedToTurnOnLocaiton = true
        
      }
    }
    
    @objc func LocationManagerLocaitonUpdate(notification: Notification) {
        let location : CLLocation = notification.userInfo!["location"] as! CLLocation
        self.fetchLocationName(forGeoCoordinate: location.coordinate)
    }
    
    func fetchLocationName(forGeoCoordinate coordinate: CLLocationCoordinate2D) {
      KTBookingManager().address(forLocation: coordinate, Limit: 1) { (status, response) in
        if status == Constants.APIResponseStatus.SUCCESS && response[Constants.ResponseAPIKey.Data] != nil && (response[Constants.ResponseAPIKey.Data] as! [KTGeoLocation]).count > 0 {
          let pAddress : KTGeoLocation = (response[Constants.ResponseAPIKey.Data] as! [KTGeoLocation])[0]
            DispatchQueue.main.async {
              //self.delegate?.userIntraction(enable: true)
              if self.delegate != nil {
                (self.delegate as! KTXpressPickUpViewModelDelegate).setPickUp(pick: pAddress.name)
              }
            }
        }
      }
    }
    
    func checkLatLonInside(location: CLLocation) -> Bool {
        if let string = self.areas.filter({$0.type! == "OperatingArea"}).first?.bound {
            let coordinates = string.components(separatedBy: ";").map{$0.components(separatedBy: ",")}.map{$0.map({Double($0)!})}.map { (value) -> CLLocationCoordinate2D in
                return CLLocationCoordinate2D(latitude: value[0], longitude: value[1])
            }
            if CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude).contained(by: coordinates) {
                return true
            } else {
                print("it wont contains")
                return false
            }
        } else {
            print("it wont contains")
            return false

        }

    }
    
    func fetchOperatingArea() {
        
        KTXpressBookingManager().getZoneWithSync { (string, response) in
                        
            if let totalOperatingResponse = response["Response"] as? [String: Any] {
                
                print(totalOperatingResponse)
                
                if let totalAreas = totalOperatingResponse["Areas"] as? [[String:Any]] {

                    for item in totalAreas {
                        
                        let area = Area(code: (item["Code"] as? Int)!, vehicleType:(item["VehicleType"] as? Int)!, name: (item["Name"] as? String)!, parent: (item["Parent"] as? Int)!, bound: (item["Bound"] as? String)!, type: (item["Type"] as? String)!, isActive: (item["IsActive"] as? Bool)!)
                        
                        self.areas.append(area)
                                                
                    }
                    
                    if self.delegate != nil {
                      (self.delegate as! KTXpressPickUpViewModelDelegate).setPolygon()
                    }
                                                            
                }
                
                self.zones = self.areas.filter{$0.type == "Zone"}
                self.metroStopsArea = self.areas.filter{$0.type! == "MetroStop"}
                self.metroStations = self.areas.filter{$0.type! == "MetroStation"}
                self.tramStopsArea = self.areas.filter{$0.type! == "TramStop"}
                self.tramStations = self.areas.filter{$0.type! == "TramStation"}

                for zone in self.zones {
                    
                    var z  = [String: [Area]]()
                    z["zone"] = [zone]
                    var stations = self.metroStations.filter{$0.parent! == zone.code!}
                    stations.append(contentsOf: self.tramStations.filter{$0.parent! == zone.code!})
                    z["stations"] = stations
                    self.zonalArea.append(z)
                    
                }
                
                for item in self.zonalArea {
                    print("Zonal Area", item)
                }
                
                if let totalDestinations = totalOperatingResponse["Destinations"] as? [[String:Any]] {

                    for item in totalDestinations {
                        
                        let destination = Destination(source: (item["Source"] as? Int)!, destination: (item["Destination"] as? Int)!, isActive: (item["IsActive"] as? Bool)!)
                        
                        self.destinations.append(destination)
                                                
                    }
                                
                }
                                
                for item in self.metroStopsArea {
                    
                    if let pickUpLocation = self.destinations.filter({$0.source! == item.parent!}).first {
                        if self.pickUpArea.contains(where: {$0.parent! == pickUpLocation.source }) {
                            
                        } else {
                            self.pickUpArea.append(item)
                        }
                    }
                                        
                }
                
                var localPickUpArea = [Area]()
                
                for item in self.tramStopsArea {
                    
                    if let pickUpLocation = self.destinations.filter({$0.source! == item.parent!}).first {
                        if localPickUpArea.contains(where: {$0.parent! == pickUpLocation.source }) {
                            
                        } else {
                            localPickUpArea.append(item)
                        }
                    }
                    
                }
                
                
                let set1: Set<Area> = Set(self.pickUpArea)
                let set2: Set<Area> = Set(localPickUpArea)
                
                self.pickUpArea = Array(set1.union(set2))
                
                print(self.pickUpArea)

                
                if self.delegate != nil {
                  (self.delegate as! KTXpressPickUpViewModelDelegate).addPickUpLocations()
                }
                    
            }
            
        }
    }
    
    func didTapMarker(location: CLLocation) {
        let selectedArea = self.areas.filter{$0.bound?.components(separatedBy: ";").first?.components(separatedBy: ",").first! == String(format: "%.5f", location.coordinate.latitude)}
         
         print(selectedArea)
        
        if selectedArea.count > 0 {
            (self.delegate as! KTXpressPickUpViewModelDelegate).setPickUp(pick: selectedArea.first?.name ?? "")
        } else {
            let name = "XpressLocationManagerNotificationIdentifier"
            NotificationCenter.default.post(name: Notification.Name(name), object: nil, userInfo: ["location": location as Any, "updateMap" : false])
            self.fetchLocationName(forGeoCoordinate: location.coordinate)
        }
        
    }
    
    func showStopAlert() {
        
        defer {
            if stopsOFStations.count > 1 {
                (delegate as! KTXpressPickUpViewModelDelegate).showStopAlertViewController(stops: stopsOFStations, selectedStation: selectedStation!)
            }
        }
        
        selectedStop = nil
        self.getDestinationForPickUp()

    }
    
    func didTapSetPickUpButton() {
                
        defer {
            
            if self.destinationForPickUp.count > 0 {
                (delegate as! KTXpressPickUpViewModelDelegate).showDropOffViewController(destinationForPickUp: destinationForPickUp, pickUpStation: selectedStation, pickUpStop: selectedStation == nil ? nil : selectedStop, pickUpzone: selectedZone, coordinate: selectedCoordinate!, zonalArea: self.zonalArea)
            } else {
                
            }
            
        }
        
        self.getDestinationForPickUp()

    }
    
    func getDestinationForPickUp() {
        
        destinationForPickUp.removeAll()
        selectedZone = nil
        selectedStation = nil
        stopsOFStations.removeAll()
        
        for item in zones {
            
            let coordinates = (item.bound?.components(separatedBy: ";").map{$0.components(separatedBy: ",")}.map{$0.map({Double($0)!})}.map { (value) -> CLLocationCoordinate2D in
                return CLLocationCoordinate2D(latitude: value[0], longitude: value[1])
            })!
            
            if  CLLocationCoordinate2D(latitude: selectedCoordinate?.latitude ?? 0.0, longitude: selectedCoordinate?.longitude ?? 0.0).contained(by: coordinates) {
                selectedZone = item
                break
            }
            
        }
        
        let stationsOfZone = self.zonalArea.filter{$0["zone"]?.first!.code == selectedZone!.code}.first!["stations"]
        
        print(selectedZone)
        print(stationsOfZone)
        
        for item in stationsOfZone! {
            
            let coordinates = (item.bound?.components(separatedBy: ";").map{$0.components(separatedBy: ",")}.map{$0.map({Double($0)!})}.map { (value) -> CLLocationCoordinate2D in
                return CLLocationCoordinate2D(latitude: value[0], longitude: value[1])
            })!
            
            if  CLLocationCoordinate2D(latitude: selectedCoordinate?.latitude ?? 0.0, longitude: selectedCoordinate?.longitude ?? 0.0).contained(by: coordinates) {
                selectedStation = item
                break
            }
            
        }
        
        if selectedStation != nil {
            print("it's inside station")
        } else {
            print("it's inside a zone")
        }
                
//        for item in stationsOfZone! {
//            stopsOFStations.append(contentsOf: self.areas.filter{$0.parent! == item.code!})
//
//        }
        
        var customDestinationsCode = [Int]()
        
        if selectedStation != nil {
            
            stopsOFStations.append(contentsOf: self.areas.filter{$0.parent! == selectedStation!.code!})
            
            let coordinates = (selectedStation!.bound?.components(separatedBy: ";").map{$0.components(separatedBy: ",")}.map{$0.map({Double($0)!})}.map { (value) -> CLLocationCoordinate2D in
                return CLLocationCoordinate2D(latitude: value[0], longitude: value[1])
            })!
            
            selectedCoordinate = coordinates.first!
            
//
//            for stop in self.stopsOFStations {
//                customDestinationsCode = self.destinations.filter{$0.source == stop.code!}.map{$0.destination!}
//            }
//
            if customDestinationsCode.count == 0{
                customDestinationsCode = self.destinations.filter{$0.source == selectedStation?.code!}.map{$0.destination!}
            }
            
            
            for item in customDestinationsCode {
                
                destinationForPickUp.append(contentsOf: self.areas.filter{$0.code! == item})
                
            }
            
            print("destinationForPickUp", destinationForPickUp)
            
            selectedStop = stopsOFStations.first!
        
        } else {
            
//            let coordinates = (selectedZone!.bound?.components(separatedBy: ";").map{$0.components(separatedBy: ",")}.map{$0.map({Double($0)!})}.map { (value) -> CLLocationCoordinate2D in
//                return CLLocationCoordinate2D(latitude: value[0], longitude: value[1])
//            })!
            
//            selectedCoordinate = coordinates.first!
            
            customDestinationsCode = self.destinations.filter{$0.source == selectedZone?.code}.map{$0.destination!}
            
            for item in customDestinationsCode {
                destinationForPickUp.append(contentsOf: self.areas.filter{$0.code! == item})
            }
            
            print(destinationForPickUp)
        
        }
        
        
    }
    
    
}


