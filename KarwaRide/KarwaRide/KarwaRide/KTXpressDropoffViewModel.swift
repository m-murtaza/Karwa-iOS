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

protocol KTXpressDropoffViewModelDelegate: KTViewModelDelegate {
    func showAlertForLocationServerOn()
    func updateLocationInMap(location:CLLocation)
    func updateLocationInMap(location: CLLocation, shouldZoomToDefault withZoom : Bool)
    func setDropOff(pick: String?)
}

class KTXpressDropoffViewModel: KTBaseViewModel {
    
    var booking : KTBooking = KTBookingManager().booking()
    var currentBookingStep : BookingStep = BookingStep.step1  //Booking will strat with step 1
    var isFirstZoomDone = false
    static var askedToTurnOnLocaiton : Bool = false

    override func viewWillAppear() {
        
//        setupCurrentLocaiton()
        
        super.viewWillAppear()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.LocationManagerLocaitonUpdate(notification:)), name: Notification.Name(Constants.Notification.LocationManager), object: nil)
    
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
          self.booking.pickupLocationId = pAddress.locationId
          self.booking.pickupAddress = pAddress.name
          self.booking.pickupLat = pAddress.latitude
          self.booking.pickupLon = pAddress.longitude
          DispatchQueue.main.async {
            //self.delegate?.userIntraction(enable: true)
            if self.delegate != nil {
              (self.delegate as! KTXpressDropoffViewModelDelegate).setDropOff(pick: self.booking.pickupAddress)
            }
          }
        }
      }
    }
    
    
    
}


