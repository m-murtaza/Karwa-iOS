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
    let code, vehicleType: Int?
    let name: String?
    let parent: Int?
    let bound, type: String?
    let isActive: Bool?
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
