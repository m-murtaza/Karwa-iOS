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
    var eta : Int64
    var etaText : String
    var status : Int
    var trackType : VehicleTrackType
    var encodedPath : String
    var wayPoints: [WayPoints]
    
     override init() {
        
        position = CLLocationCoordinate2DMake(0.0, 0.0)
        vehicleNo  = ""
        vehicleType = 1
        bearing = 0.0
        eta = 0
        etaText = ""
        status = 1
        trackType = VehicleTrackType.vehicle
        encodedPath = ""
        wayPoints = [WayPoints]()
        super.init()
    }
    
}
