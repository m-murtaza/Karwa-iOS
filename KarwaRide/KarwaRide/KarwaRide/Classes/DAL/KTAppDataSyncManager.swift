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
        self.fetchBookmarks()
        self.syncBookings()
        self.syncCancelReasons()
        self.syncRatingReason()
        self.syncComplaints()
        self.removeNotificaiton()
        
    }
    
    private func syncBookings()
    {
        KTBookingManager().syncBookings {(status, response) in
            print("All Bookings synced")
        }
    }
    
    private func syncVechicleTypes() {
        
        KTVehicleTypeManager().fetchBasicTariffFromServer { (status, response) in
            print("Sync Vechile Type - " + status )
            print(response)
        }
    }
    
    private func fetchBookmarks() {
        
        KTBookmarkManager().fetchHomeWork { (status, response) in
            print("Fetch Bookmarks - " + status )
            print(response)
        }
    }
    
    private func syncCancelReasons() {
    
        KTCancelBookingManager().fetchCancelReasons { (status, response) in
            print("Sync Cancel Reasons - " + status )
            print(response)
        }
    }
    
    private func syncRatingReason() {
        KTRatingManager().fetchRatingReasons { (status, response) in
            print("Sync Rating Reasons - " + status )
            print(response)
        }
    }
    
    private func syncComplaints()
    {
        KTComplaintsManager().fetchComplaints{(status, response) in
            print("All Complaints synced")
        }
    }
    
    private func removeNotificaiton() {
        KTNotificationManager().deleteOldNotifications()
    }
}
