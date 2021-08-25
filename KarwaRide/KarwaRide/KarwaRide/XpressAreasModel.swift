//
//  XpressAreasModel.swift
//  KarwaRide
//
//  Created by Satheesh Speed Mac on 25/05/21.
//  Copyright © 2021 Karwa. All rights reserved.
//

import Foundation

// MARK: - Area
struct Area: Hashable {
    var code, vehicleType: Int?
    var name: String?
    var parent: Int?
    var bound, type: String?
    var isActive: Bool?
}

// MARK: - Destination
struct Destination: Codable, Hashable {
    let source, destination: Int?
    let isActive: Bool?

    enum CodingKeys: String, CodingKey {
        case source = "Source"
        case destination = "Destination"
        case isActive = "IsActive"
    }
}

struct RideInfo: Codable {
    
    var rides = [RideVehiceInfo]()
    var expirySeconds: Int?
    
    enum CodingKeys: String, CodingKey {
        case rides = "Rides"
        case expirySeconds = "ExpirySeconds"
    }
}


struct RideVehiceInfo: Codable {
    
    var drop: LocationInfo?
    var eta: Int?
    var id: String?
    var pick: LocationInfo?
    var vehicleNo: String?
    
    enum CodingKeys: String, CodingKey {
        case drop = "Drop"
        case eta = "ETA"
        case id = "Id"
        case pick = "Pick"
        case vehicleNo = "VehicleNo"
    }
    
}

struct LocationInfo: Codable {
    var lat: Double?
    var lon: Double?
}
