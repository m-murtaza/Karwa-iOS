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
}
class KTCreateBookingViewModel: KTBaseViewModel {
    
    weak var delegate: KTCreateBookingViewModelDelegate?
    var vehicleType : KTVehicleType = KTVehicleType.KTBusinessLimo
    
    init(del: Any) {
        super.init()
        delegate = del as? KTCreateBookingViewModelDelegate
        
        KTLocationManager.sharedInstance.start()
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("LocationManagerNotificationIdentifier"), object: nil)
    }
    
    @objc func methodOfReceivedNotification(notification: Notification){
        //print(notification.userInfo!["location"] as Any)
        let location : CLLocation = notification.userInfo!["location"] as! CLLocation
        self.delegate?.updateLocationInMap(location: location)
        
        KTBookingManager.init().vehiclesNearCordinate(coordinate: location.coordinate, vehicleType: KTVehicleType(rawValue: 50)!, completion:{
            (status,response) in
            
            
        })

    }
    
    func fetchVehiclesNearCordinates(location:CLLocation) {
        
    }
}


