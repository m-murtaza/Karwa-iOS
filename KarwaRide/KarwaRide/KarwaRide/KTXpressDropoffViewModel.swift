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

struct RideSerivceLocationData {
    
    var pickUpZone: Area?
    var pickUpStation: Area?
    var pickUpStop: Area?
    
    var dropOffZone: Area?
    var dropOfSftation: Area?
    var dropOffStop: Area?
    
    var pickUpCoordinate: CLLocationCoordinate2D?
    var dropOffCoordinate: CLLocationCoordinate2D?
    
    var passsengerCount: Int? = 1

}

protocol KTXpressDropoffViewModelDelegate: KTViewModelDelegate {
    func showAlertForLocationServerOn()
    func updateLocationInMap(location:CLLocation)
    func updateLocationInMap(location: CLLocation, shouldZoomToDefault withZoom : Bool)
    func setDropOff(pick: String?)
    func showStopAlertViewController(stops: [Area], selectedStation: Area)
    func showRideServiceViewController(rideLocationData: RideSerivceLocationData?)
}

class KTXpressDropoffViewModel: KTBaseViewModel {
    
    var booking : KTBooking = KTBookingManager().booking()
    var currentBookingStep : BookingStep = BookingStep.step1  //Booking will strat with step 1
    var isFirstZoomDone = false
    static var askedToTurnOnLocaiton : Bool = false
    
    var operationArea = [Area]()
    var destinationsForPickUp = [Area]()
    var pickUpZone: Area?
    var pickUpStation: Area?
    var pickUpStop: Area?
    var countOfPassenger = 1

    var dropOffLocation: Area?
    var picupRect = GMSMutablePath()
    var pickUpCoordinate: CLLocationCoordinate2D?
    var selectedCoordinate: CLLocationCoordinate2D?
    var stopsOFStations = [Area]()
    var selectedStop:Area?
    var selectedStation: Area?
    var selectedZone: Area?
    var zonalArea = [[String : [Area]]]()

    override func viewWillAppear() {
        
//        setupCurrentLocaiton()
        
        super.viewWillAppear()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.LocationManagerLocaitonUpdate(notification:)), name: Notification.Name(Constants.Notification.XpressLocationManager), object: nil)
    
    }

    func setupCurrentLocaiton() {
      if KTLocationManager.sharedInstance.locationIsOn() {
    
      }
      else if KTXpressDropoffViewModel.askedToTurnOnLocaiton == false{
        (delegate as! KTXpressPickUpViewModelDelegate).showAlertForLocationServerOn()
        KTXpressDropoffViewModel.askedToTurnOnLocaiton = true
        
      }
    }
    
    @objc func LocationManagerLocaitonUpdate(notification: Notification)
    {
          let location : CLLocation = notification.userInfo!["location"] as! CLLocation
        self.fetchLocationName(forGeoCoordinate: location.coordinate)
    }
    
    private func fetchLocationName(forGeoCoordinate coordinate: CLLocationCoordinate2D) {
      
      KTBookingManager().address(forLocation: coordinate, Limit: 1) { (status, response) in
        if status == Constants.APIResponseStatus.SUCCESS && response[Constants.ResponseAPIKey.Data] != nil && (response[Constants.ResponseAPIKey.Data] as! [KTGeoLocation]).count > 0{
          
          
          let pAddress : KTGeoLocation = (response[Constants.ResponseAPIKey.Data] as! [KTGeoLocation])[0]
          DispatchQueue.main.async {
            //self.delegate?.userIntraction(enable: true)
            if self.delegate != nil {
              (self.delegate as! KTXpressDropoffViewModelDelegate).setDropOff(pick: pAddress.name)
            }
          }
        }
      }
    }
    
    func showStopAlert() {
        
        stopsOFStations.removeAll()
        
        defer {
            if stopsOFStations.count > 1 {
                selectedStop = stopsOFStations.first!
                (delegate as! KTXpressDropoffViewModelDelegate).showStopAlertViewController(stops: stopsOFStations, selectedStation: selectedStation!)
            }
        }

        if selectedStation != nil {
            stopsOFStations.append(contentsOf: self.operationArea.filter{$0.parent! == selectedStation!.code!})
            if stopsOFStations.count == 1 {
                selectedStop = stopsOFStations.first!
            }
        } else {
            selectedStop = nil
        }
        

    }
    
    func didTapMarker(location: CLLocation) {
        let selectedArea = self.destinationsForPickUp.filter{$0.bound?.components(separatedBy: ";").first?.components(separatedBy: ",").first! == String(format: "%.5f", location.coordinate.latitude)}
         
         print(selectedArea)
        
        if selectedArea.count > 0 {
            self.selectedStation = selectedArea.first!
            (self.delegate as! KTXpressDropoffViewModelDelegate).setDropOff(pick: selectedArea.first?.name ?? "")
            
        } else {
//            let name = "LocationManagerNotificationIdentifier"
//            NotificationCenter.default.post(name: Notification.Name(name), object: nil, userInfo: ["location": location as Any, "updateMap" : false])
//            KTLocationManager.sharedInstance.setCurrentLocation(location: location)
        }
        
    }
    
    func didTapSetDropOffButton() {
                
        defer {
            
            if selectedStop == nil && selectedStation != nil{
                stopsOFStations.append(contentsOf: self.operationArea.filter{$0.parent! == selectedStation!.code!})
                selectedStop = stopsOFStations.first!
            }
            

            let rideLocationData = RideSerivceLocationData(pickUpZone: pickUpZone, pickUpStation: pickUpStation, pickUpStop: pickUpStop, dropOffZone: selectedZone, dropOfSftation: selectedStation, dropOffStop: selectedStop, pickUpCoordinate: pickUpCoordinate, dropOffCoordinate: selectedCoordinate, passsengerCount: countOfPassenger)
            
            (delegate as! KTXpressDropoffViewModelDelegate).showRideServiceViewController(rideLocationData: rideLocationData)
        }

        
        getDestination()

    }
    
    func getDestination() {
        
        selectedZone = nil
        selectedStation = nil
        stopsOFStations.removeAll()
        
        let stations = destinationsForPickUp.filter{$0.type != "Zone"}
                
        for item in stations {
            
                let coordinates = (item.bound?.components(separatedBy: ";").map{$0.components(separatedBy: ",")}.map{$0.map({Double($0)!})}.map { (value) -> CLLocationCoordinate2D in
                    return CLLocationCoordinate2D(latitude: value[0], longitude: value[1])
                })!
                
                if  CLLocationCoordinate2D(latitude: selectedCoordinate?.latitude ?? 0.0, longitude: selectedCoordinate?.longitude ?? 0.0).contained(by: coordinates) {
                    selectedStation = item
                    break
                }
            
        }
        
        let zones = destinationsForPickUp.filter{$0.type == "Zone"}
        
        if zones.count > 0 {
            
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
        }
        
        if selectedStation != nil {
            print("it's inside station")
        } else {
            print("it's inside a zone")
        }
                
        if selectedStation != nil {
                        
            let coordinates = (selectedStation!.bound?.components(separatedBy: ";").map{$0.components(separatedBy: ",")}.map{$0.map({Double($0)!})}.map { (value) -> CLLocationCoordinate2D in
                return CLLocationCoordinate2D(latitude: value[0], longitude: value[1])
            })!
            
            selectedCoordinate = coordinates.first!
            
        } else {
            
//            let coordinates = (selectedZone!.bound?.components(separatedBy: ";").map{$0.components(separatedBy: ",")}.map{$0.map({Double($0)!})}.map { (value) -> CLLocationCoordinate2D in
//                return CLLocationCoordinate2D(latitude: value[0], longitude: value[1])
//            })!
//            
//            selectedCoordinate = coordinates.first!
//        
        }
        
        
    }
    
}


