//
//  KTXpressLocationSetUpViewModel.swift
//  KarwaRide
//
//  Created by Apple on 31/10/21.
//  Copyright © 2021 Karwa. All rights reserved.
//

import Foundation
import CoreLocation

var areas = [Area]()
var metroStopsArea = [Area]()
var metroStations = [Area]()
var tramStations = [Area]()
var tramStopsArea = [Area]()
var zones = [Area]()
var zonalArea = [[String : [Area]]]()
var destinations = [Destination]()
var stops = [Area]()
var pickUpArea = [Area]()
var dropOffArea = [Area]()
var selectedRSPickUpCoordinate: CLLocationCoordinate2D?
var selectedRSDropOffCoordinate: CLLocationCoordinate2D?
var selectedRSDropZone: Area?
var selectedRSPickZone: Area?
var selectedRSPickStation: Area?
var selectedRSDropStation: Area?
var selectedRSPickStop: Area?
var selectedRSDropStop: Area?

protocol KTXpressLocationViewModelDelegate: KTViewModelDelegate {
    func showAlertForLocationServerOn()
    func setPickUp(pick: String?)
    func setPickUpPolygon()
    func setDropOffPolygon()
    func addPickUpLocations()
    func showDropOffViewController(destinationForPickUp: [Area], pickUpStation: Area?, pickUpStop: Area?, pickUpzone: Area?, coordinate: CLLocationCoordinate2D, zonalArea: [[String : [Area]]])
    func showStopAlertViewController(stops: [Area], selectedStation: Area)
    func showAlertForStation()
}


class KTXpressLocationSetUpViewModel: KTBaseViewModel {

    static var askedToTurnOnLocaiton : Bool = false

    func fetchOperatingArea() {

        KTXpressBookingManager().getZoneWithSync { (string, response) in

            self.delegate?.hideProgressHud()

            if let totalOperatingResponse = response["Response"] as? [String: Any] {

                print(totalOperatingResponse)

                if let totalAreas = totalOperatingResponse["Areas"] as? [[String:Any]] {

                    print(totalAreas)

                    areas.removeAll()

                    for item in totalAreas {

                        print(item)

                        let area = Area(code: (item["Code"] as? Int) ?? 0, vehicleType:(item["VehicleType"] as? Int) ?? -1, name: (item["Name"] as? String) ?? "", parent: (item["Parent"] as? Int) ?? -1, bound: (item["Bound"] as? String) ?? "", type: (item["Type"] as? String) ?? "", isActive: (item["IsActive"] as? Bool) ?? false)

                        areas.append(area)

                    }

                    if self.delegate != nil {
                      (self.delegate as! KTXpressLocationViewModelDelegate).setPickUpPolygon()
                    }

                }
                zones.removeAll()
                metroStopsArea.removeAll()
                metroStations.removeAll()
                tramStopsArea.removeAll()
                tramStations.removeAll()

                zones = areas.filter{$0.type == "Zone"}
                metroStopsArea = areas.filter{$0.type! == "MetroStop"}
                metroStations = areas.filter{$0.type! == "MetroStation"}
                tramStopsArea = areas.filter{$0.type! == "TramStop"}
                tramStations = areas.filter{$0.type! == "TramStation"}

                for zone in zones {

                    var z  = [String: [Area]]()
                    z["zone"] = [zone]
                    var stations = metroStations.filter{$0.parent! == zone.code!}
                    stations.append(contentsOf: tramStations.filter{$0.parent! == zone.code!})
                    z["stations"] = stations
                    zonalArea.append(z)

                }

                for item in zonalArea {
                    print("Zonal Area", item)
                }

                destinations.removeAll()

                if let totalDestinations = totalOperatingResponse["Destinations"] as? [[String:Any]] {

                    for item in totalDestinations {

                        let destination = Destination(source: (item["Source"] as? Int)!, destination: (item["Destination"] as? Int)!, isActive: (item["IsActive"] as? Bool)!)

                        destinations.append(destination)

                    }

                }

                for item in metroStations {

                    if let pickUpLocation = destinations.filter({$0.source! == item.code!}).first {
                        if pickUpArea.contains(where: {$0.code! == pickUpLocation.source }) {

                        } else {
                            pickUpArea.append(item)
                        }
                    }

                }
                
//                for item in metroStopsArea {
//
//                    if let pickUpLocation = destinations.filter({$0.source! == item.parent!}).first {
//                        if pickUpArea.contains(where: {$0.parent! == pickUpLocation.source }) {
//
//                        } else {
//                            pickUpArea.append(item)
//                        }
//                    }
//
//                }

                var localPickUpArea = [Area]()

                for item in tramStations {

                    if let pickUpLocation = destinations.filter({$0.source! == item.code!}).first {
                        if localPickUpArea.contains(where: {$0.code! == pickUpLocation.source }) {

                        } else {
                            localPickUpArea.append(item)
                        }
                    }

                }


                let set1: Set<Area> = Set(pickUpArea)
                let set2: Set<Area> = Set(localPickUpArea)

                pickUpArea = Array(set1.union(set2))

                stops.removeAll()
                
                stops = Array(set1.union(set2))
                
                print(pickUpArea)

                if self.delegate != nil {
                  (self.delegate as! KTXpressLocationViewModelDelegate).addPickUpLocations()
                }

            }

        }
    }
    
    func fetchLocationName(forGeoCoordinate coordinate: CLLocationCoordinate2D) {
      KTBookingManager().address(forLocation: coordinate, Limit: 1) { (status, response) in
        if status == Constants.APIResponseStatus.SUCCESS && response[Constants.ResponseAPIKey.Data] != nil && (response[Constants.ResponseAPIKey.Data] as! [KTGeoLocation]).count > 0 {
          let pAddress : KTGeoLocation = (response[Constants.ResponseAPIKey.Data] as! [KTGeoLocation])[0]
            DispatchQueue.main.async {
              //self.delegate?.userIntraction(enable: true)
              if self.delegate != nil {
                (self.delegate as! KTXpressLocationViewModelDelegate).setPickUp(pick: pAddress.name)
              }
            }
        }
      }
    }
    
    func setupCurrentLocaiton() {
      if KTLocationManager.sharedInstance.locationIsOn() {
        if KTLocationManager.sharedInstance.isLocationAvailable {
        }
        else {
          KTLocationManager.sharedInstance.start()
        }
      }
      else if KTXpressLocationSetUpViewModel.askedToTurnOnLocaiton == false{
        (delegate as! KTXpressPickUpViewModelDelegate).showAlertForLocationServerOn()
          KTXpressLocationSetUpViewModel.askedToTurnOnLocaiton = true
      }
    }
    
    
    
}


extension UIViewController {
    
    func checkLatLonInside(location: CLLocation) -> Bool {
        if let string = areas.filter({$0.type! == "OperatingArea"}).first?.bound {
            
            let operatingArea = string.components(separatedBy: "|")

            var latLonInside = false
            
            for item in operatingArea {
                
                let coordinates = item.components(separatedBy: ";").map{$0.components(separatedBy: ",")}.map{$0.map({Double($0)!})}.map { (value) -> CLLocationCoordinate2D in
                    return CLLocationCoordinate2D(latitude: value[0], longitude: value[1])
                }
                if CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude).contained(by: coordinates) {
                    latLonInside = true
                    break
                } else {
                    print("it wont contains")
                    latLonInside = false
                }
                
            }
                        
          return latLonInside
            
        } else {
            print("it wont contains")
            return false

        }

    }
}
