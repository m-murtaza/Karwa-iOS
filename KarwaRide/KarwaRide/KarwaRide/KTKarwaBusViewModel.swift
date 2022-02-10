//
//  KTKarwaBusViewModel.swift
//  KarwaRide
//
//  Created by Apple on 19/01/22.
//  Copyright © 2022 Karwa. All rights reserved.
//

import Foundation
import CoreLocation

var suggestedRoutes = KarwaBusRoute()

class KTKarwaBusViewModel: KTBaseViewModel {

    static var askedToTurnOnLocaiton : Bool = false
    var rideInfo = RideInfo()
    var rideLocationData = RideSerivceLocationData()

    func fetchJourneyPlannerRoutes() {
        KTKarwaBusBookingManager().getRoutesWithSync(requestParameter: RequestParameters()) { [weak self] (status, response) in
            
            self?.delegate?.hideProgressHud()

            do {
                
                print(mockRoute.json)
                
                let jsonObjectData = Data(mockRoute.json.utf8)//mockRoute.json.data(using: .utf8)!
                // Decode the json data to a Candidate struct
                suggestedRoutes = try! JSONDecoder().decode(KarwaBusRoute.self, from: jsonObjectData)
                print(suggestedRoutes)
               
            } catch {
                print(error.localizedDescription)
            }
            
            print(response)
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


extension Dictionary {
    var json: String {
        let invalidJson = "Not a valid JSON"
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            return String(bytes: jsonData, encoding: String.Encoding.utf8) ?? invalidJson
        } catch {
            return invalidJson
        }
    }
    
    func printJson() {
        print(json)
    }
}
