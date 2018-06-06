//
//  CLLocationCoordinate2D +Utils.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 2/4/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import Foundation
import CoreLocation

extension CLLocationCoordinate2D {
    
    /// Compare two coordinates
    /// - parameter coordinate: another coordinate to compare
    /// - return: bool value
    func isEqual(to coordinate: CLLocationCoordinate2D) -> Bool {
        
        if self.latitude != coordinate.latitude &&
            self.longitude != coordinate.longitude {
            return false
        }
        return true
    }
    
    /// check the coordinate is empty or default
    /// return Bool value
    var isZeroCoordinate: Bool {
        
        if self.latitude == 0.0 && self.longitude == 0.0 {
            return true
        }
        return false
    }
    
    //distance in meters, as explained in CLLoactionDistance definition
    func distance(from: CLLocationCoordinate2D) -> CLLocationDistance {
        let destination=CLLocation(latitude:from.latitude,longitude:from.longitude)
        return CLLocation(latitude: latitude, longitude: longitude).distance(from: destination)
    }
}
