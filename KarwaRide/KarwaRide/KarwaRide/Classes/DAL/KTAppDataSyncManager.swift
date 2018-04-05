//
//  KTAppDataSyncManager.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 4/4/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

class KTAppDataSyncManager: KTDALManager {
    
    func syncApplicationData()  {
        self.syncVechicleTypes()
        self.syncCancelReasons()
    }
    
    private func syncVechicleTypes() {
        
        KTVehicleTypeManager().fetchBasicTariffFromServer { (status, response) in
            print(response)
        }
    }
    
    private func syncCancelReasons() {
    
        KTCancelBookingManager().fetchCancelReasons { (status, response) in
            print(response)
        }
    }
}
