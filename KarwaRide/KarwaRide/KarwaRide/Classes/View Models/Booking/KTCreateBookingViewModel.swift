//
//  KTCreateBookingViewModel.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 1/16/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
import CoreLocation


protocol KTCreateBookingViewModelDelegate: KTViewModelDelegate {
    func updateLocationInMap(location:CLLocation)
    func addMarkerOnMap(vTrack:Array<VehicleTrack>)
}
class KTCreateBookingViewModel: KTBaseViewModel {
    
    weak var delegate: KTCreateBookingViewModelDelegate?
    var vehicleType : KTVehicleType = KTVehicleType.KTBusinessLimo
    
    init(del: Any) {
        super.init()
        delegate = del as? KTCreateBookingViewModelDelegate
        
        KTLocationManager.sharedInstance.start()
        NotificationCenter.default.addObserver(self, selector: #selector(self.LocationManagerLocaitonUpdate(notification:)), name: Notification.Name("LocationManagerNotificationIdentifier"), object: nil)
    }
    
    @objc func LocationManagerLocaitonUpdate(notification: Notification){
        //print(notification.userInfo!["location"] as Any)
        let location : CLLocation = notification.userInfo!["location"] as! CLLocation
        self.delegate?.updateLocationInMap(location: location)
        
        
        self.fetchVehiclesNearCordinates(location: location)
//        KTBookingManager.init().vehiclesNearCordinate(coordinate: location.coordinate, vehicleType: KTVehicleType(rawValue: 50)!, completion:{
//            (status,response) in
//            
//            
//        })

    }
    
    var oneTimeCheck : Bool = true
    func fetchVehiclesNearCordinates(location:CLLocation) {
        if oneTimeCheck {
            //Righ now allow only one time.
            oneTimeCheck = false
            KTBookingManager.init().vehiclesNearCordinate(coordinate: location.coordinate, vehicleType: KTVehicleType(rawValue: 50)!, completion:{
            (status,response) in
               var vTrack: Array<VehicleTrack> = self.parseVehicleTrack(response)
                self.delegate?.addMarkerOnMap(vTrack: vTrack)
            
            })
        }
    }
    
    func parseVehicleTrack(_ respons: [AnyHashable: Any]) -> Array<VehicleTrack> {
        var vTrack: Array<VehicleTrack> = Array()
        
        var responseArray: Array<[AnyHashable: Any]> = respons[Constants.ResponseAPIKey.Data] as! Array<[AnyHashable: Any]>
        //respons[Constants.ResponseAPIKey.Data] as! [AnyHashable: Any].forEach { track in
        responseArray.forEach { rtrack in
            var track : VehicleTrack = VehicleTrack()
            track.vehicleNo = rtrack["VehicleNo"] as? String
            track.position = CLLocationCoordinate2D(latitude: (rtrack["Lat"] as? CLLocationDegrees)!, longitude: (rtrack["Lon"] as? CLLocationDegrees)!)
            track.vehicleType = rtrack["VehicleType"] as? Int
            track.bearing = rtrack["Bearing"] as? Float
            vTrack.append(track)
        }
        return vTrack
    }
}


