//
//  VehicleTrack.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 1/21/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import Foundation
import CoreLocation

enum VehicleTrackType {
    case vehicle
    case user
}

class VehicleTrack: NSObject {
    var position : CLLocationCoordinate2D
    var vehicleNo: String
    var vehicleType: Int
    var bearing : Float
    var trackType : VehicleTrackType
    
     override init() {
        
        position = CLLocationCoordinate2DMake(0.0, 0.0)
        vehicleNo  = ""
        vehicleType = 1
        bearing = 0.0
        trackType = VehicleTrackType.vehicle
        super.init()
    }
    
}
