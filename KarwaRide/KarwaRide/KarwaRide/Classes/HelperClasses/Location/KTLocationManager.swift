//
//  KTLocationManager.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 1/15/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
import CoreLocation

//protocol KTLocationManagerDelegate {
//    func didUpdateLocations(currentLocation: CLLocation)
//}

class KTLocationManager: NSObject,CLLocationManagerDelegate {
    
//    var delegate : KTLocationManagerDelegate?
    let locManager = CLLocationManager()
    var currentLocation : CLLocation = CLLocation(latitude: 0.0,longitude: 0.0)
    var baseLocation : CLLocation = CLLocation(latitude: 0.0,longitude: 0.0)
    
    var isLocationAvailable: Bool {
        if currentLocation.coordinate.isZeroCoordinate {
         
            return false
        }
        return true
    }
    
    //MARK: - Singleton
    private override init()
    {
        super.init()
    }
    
    static let sharedInstance = KTLocationManager()
    
    func locationIsOn() -> Bool {
        var locationOn = true
        
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                locationOn = false
            case .authorizedAlways, .authorizedWhenInUse:
                locationOn = true
            }
        } else {
            locationOn = false
        }
        return locationOn
    }
    
    func setUp() {
        
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        
        locManager.requestWhenInUseAuthorization()
        locManager.distanceFilter = 5.0
    }
    
    /*func showAlertForLocaiton() {
        
        let alertController = UIAlertController(title: NSLocalizedString("Enter your title here", comment: ""), message: NSLocalizedString("Enter your message here.", comment: ""), preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        let settingsAction = UIAlertAction(title: NSLocalizedString("Settings", comment: ""), style: .default) { (UIAlertAction) in
            UIApplication.shared.openURL(NSURL(string: UIApplicationOpenSettingsURLString)! as URL)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        //KTLocationManager.sharedInstance.present(alertController, animated: true, completion: nil)
    }*/
    func start() {
        
        locManager.startUpdatingLocation()
        //locManager.startMonitoringSignificantLocationChanges()
    }
    
    func stop() {
        locManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        baseLocation = locations[0]
        NotificationCenter.default.post(name: Notification.Name("LocationManagerNotificationIdentifier"), object: nil, userInfo: ["location":currentLocation as Any])
    }
    
    func setCurrentLocation(location: CLLocation)
    {
        currentLocation = location
    }
}
