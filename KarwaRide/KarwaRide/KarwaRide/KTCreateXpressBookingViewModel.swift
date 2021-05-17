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

protocol KTCreateXpressBookingViewModelDelegate: KTViewModelDelegate {
    func showAlertForLocationServerOn()
    func updateLocationInMap(location:CLLocation)
    func updateLocationInMap(location: CLLocation, shouldZoomToDefault withZoom : Bool)
    func setPickUp(pick: String?)
}

class KTCreateXpressBookingViewModel: KTBaseViewModel {
    
    var booking : KTBooking = KTBookingManager().booking()
    var currentBookingStep : BookingStep = BookingStep.step1  //Booking will strat with step 1
    var isFirstZoomDone = false
    
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
      else if KTCreateBookingViewModel.askedToTurnOnLocaiton == false{
        (delegate as! KTCreateXpressBookingViewModelDelegate).showAlertForLocationServerOn()
        KTCreateBookingViewModel.askedToTurnOnLocaiton = true
        
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
                      (self.delegate as! KTCreateXpressBookingViewModelDelegate).updateLocationInMap(location: location, shouldZoomToDefault: false)
                  }
                  else
                  {
                      (self.delegate as! KTCreateXpressBookingViewModelDelegate).updateLocationInMap(location: location, shouldZoomToDefault: true)
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
        
//        (self.delegate as! KTCreateXpressBookingViewModelDelegate).updateLocationInMap(location: location, shouldZoomToDefault: false)
//
//        (self.delegate as! KTCreateXpressBookingViewModelDelegate).setPickUp(pick: booking.pickupAddress!)

         
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
              (self.delegate as! KTCreateXpressBookingViewModelDelegate).setPickUp(pick: self.booking.pickupAddress)
            }
          }
        }
      }
    }
    
    
    
}


