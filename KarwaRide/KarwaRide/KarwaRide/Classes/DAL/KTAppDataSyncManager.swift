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
        sanitizeSyncTimesIfRequired()
        self.syncProfile()
        self.syncVechicleTypes()
        self.fetchBookmarks()
        self.fetchOperatingArea()
        self.syncBookings()
        self.syncCancelReasons()
        self.syncRatingReason()
        self.syncComplaints()
        self.syncPaymentMethods()
        self.removeNotificaiton()
    }
    
    private func sanitizeSyncTimesIfRequired()
    {
        if(SharedPrefUtil.isLanguageChanged())
        {
            resetSyncTime(forKey: BOOKING_SYNC_TIME)
            resetSyncTime(forKey: RATING_REASON_SYNC_TIME)
            resetSyncTime(forKey: COMPLAINTS_SYNC_TIME)
            SharedPrefUtil.setLanguageChanged(setLanguage: Device.language())
        }
    }
    
    private func syncProfile()
    {
        KTUserManager().syncUserProfile {(status, response) in
            print("Profile synced")
        }
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
        KTComplaintsManager().fetchComplaintsFromServer{(status, response) in
            print("All Complaints synced")
        }
    }
    
    private func syncPaymentMethods()
    {
        KTPaymentManager().fetchPaymentsFromServer{(status, response) in
            print("All Payments synced")
        }
    }
    
    private func removeNotificaiton() {
        KTNotificationManager().deleteOldNotifications()
    }
    
    func fetchOperatingArea() {
        
        KTXpressBookingManager().getZoneWithSync { (string, response) in
                                
        }
    }
}
