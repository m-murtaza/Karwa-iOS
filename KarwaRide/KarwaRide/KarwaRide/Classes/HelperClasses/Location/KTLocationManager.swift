//
//  KTLocationManager.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 1/15/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
import CoreLocation

class KTLocationManager: NSObject,CLLocationManagerDelegate {
    
    let locManager = CLLocationManager()
    var currentLocation : CLLocation?
    
    //MARK: - Singleton
    private override init()
    {
        super.init()
    }
    
    static let sharedInstance = KTLocationManager()
    
    func setUp() {
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        
        locManager.requestWhenInUseAuthorization()
    }
    func start() {
        
        locManager.startUpdatingLocation()
    }
    
    func stop() {
        locManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations[0]
    }
    
    
}
