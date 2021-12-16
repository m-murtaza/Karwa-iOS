//
//  PromotionModel.swift
//  KarwaRide
//
//  Created by Piecyfer on 19/11/2021.
//  Copyright © 2021 Karwa. All rights reserved.
//

import Foundation

struct PromotionModel: Codable {
    var id: Int?
    var name: String?
    var description: String?
    var moreInfo: String?
    var code: String?
    var icon: String?
    
    var isShowMore: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
        case description = "Description"
        case moreInfo = "MoreInfo"
        case code = "Code"
    }
}

struct PromotionParams {
    var pickupLat: Double?
    var pickupLong: Double?
    var dropoffLat: Double?
    var dropoffLong: Double?
    var dateTime: String?
}
