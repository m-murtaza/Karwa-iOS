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

    override func viewWillAppear() {
        
        setupCurrentLocaiton()
        
        super.viewWillAppear()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.LocationManagerLocaitonUpdate(notification:)), name: Notification.Name(Constants.Notification.LocationManager), object: nil)
    
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
    
    @objc func LocationManagerLocaitonUpdate(notification: Notification)
    {
          let location : CLLocation = notification.userInfo!["location"] as! CLLocation
          var updateMap = true

          if let info = notification.userInfo, let check = info["updateMap"] as? Bool
          {
            updateMap = check
//            del?.setETAString(etaString: "")
          }
          
          //Show user Location on map
          if currentBookingStep == BookingStep.step1
          {
               if updateMap
               {
                  if(isFirstZoomDone)
                  {
                      (self.delegate as! KTXpressPickUpViewModelDelegate).updateLocationInMap(location: location, shouldZoomToDefault: false)
                  }
                  else
                  {
                      (self.delegate as! KTXpressPickUpViewModelDelegate).updateLocationInMap(location: location, shouldZoomToDefault: true)
                      isFirstZoomDone = true
                  }
               }

              booking.pickupLocationId = -1
              booking.pickupAddress = UNKNOWN
              booking.pickupLat = location.coordinate.latitude
              booking.pickupLon = location.coordinate.longitude

              //Fetch location name (from Server) for current location.

          }
        
        self.fetchLocationName(forGeoCoordinate: location.coordinate)
        
    }
    
    private func fetchLocationName(forGeoCoordinate coordinate: CLLocationCoordinate2D) {
      
      KTBookingManager().address(forLocation: coordinate, Limit: 1) { (status, response) in
        if status == Constants.APIResponseStatus.SUCCESS && response[Constants.ResponseAPIKey.Data] != nil && (response[Constants.ResponseAPIKey.Data] as! [KTGeoLocation]).count > 0{
          
          
          let pAddress : KTGeoLocation = (response[Constants.ResponseAPIKey.Data] as! [KTGeoLocation])[0]
          self.booking.pickupLocationId = pAddress.locationId
          self.booking.pickupAddress = pAddress.name
          self.booking.pickupLat = pAddress.latitude
          self.booking.pickupLon = pAddress.longitude
          DispatchQueue.main.async {
            //self.delegate?.userIntraction(enable: true)
            if self.delegate != nil {
              (self.delegate as! KTXpressPickUpViewModelDelegate).setPickUp(pick: self.booking.pickupAddress)
            }
          }
        }
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
                
                if let totalDestinations = totalOperatingResponse["Destinations"] as? [[String:Any]] {

                    for item in totalDestinations {
                        
                        let destination = Destination(source: (item["Source"] as? Int)!, destination: (item["Destination"] as? Int)!, isActive: (item["IsActive"] as? Bool)!)
                        
                        self.destinations.append(destination)
                                                
                    }
                                        
                                
                }
                
                self.metroStopsArea = self.areas.filter{$0.type! == "MetroStop"}
                
                for item in self.metroStopsArea {
                    
                    if let pickUpLocation = self.destinations.filter({$0.source! == item.parent!}).first {
                        if self.pickUpArea.contains(where: {$0.parent! == pickUpLocation.source }) {
                            
                        } else {
                            self.pickUpArea.append(item)
                        }
                    }
                    
                    
                    
                }
                
                print(self.pickUpArea)
                
                if self.delegate != nil {
                  (self.delegate as! KTXpressPickUpViewModelDelegate).addPickUpLocations()
                }
                    
            }
            
        }
    }
    
    
}


