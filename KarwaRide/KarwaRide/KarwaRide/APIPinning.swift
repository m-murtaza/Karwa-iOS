//
//  APIPinning.swift
//  KarwaRide
//
//  Created by Sam Ash on 9/8/20.
//  Copyright © 2020 Karwa. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class APIPinning {

    private static let NetworkManager = KPNetworkManager()

    public static func getManager() -> SessionManager {
        return NetworkManager.Manager!
    }
 }
