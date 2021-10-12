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
                                    
            if let totalOperatingResponse = response["Response"] as? [String: Any] {
                
                print(totalOperatingResponse)
                
                if let totalAreas = totalOperatingResponse["Areas"] as? [[String:Any]] {
                    
                    print(totalAreas)
                    
                    areas.removeAll()

                    for item in totalAreas {
                        
                        print(item)
                        
                        let area = Area(code: (item["Code"] as? Int) ?? 0, vehicleType:(item["VehicleType"] as? Int) ?? -1, name: (item["Name"] as? String) ?? "", parent: (item["Parent"] as? Int) ?? -1, bound: (item["Bound"] as? String) ?? "", type: (item["Type"] as? String) ?? "", isActive: (item["IsActive"] as? Bool) ?? false)
                        
                        areas.append(area)
                                                
                    }
                
                                                            
                }
                zones.removeAll()
                metroStopsArea.removeAll()
                metroStations.removeAll()
                tramStopsArea.removeAll()
                tramStations.removeAll()
                
                zones = areas.filter{$0.type == "Zone"}
                metroStopsArea = areas.filter{$0.type! == "MetroStop"}
                metroStations = areas.filter{$0.type! == "MetroStation"}
                tramStopsArea = areas.filter{$0.type! == "TramStop"}
                tramStations = areas.filter{$0.type! == "TramStation"}

                for zone in zones {
                    
                    var z  = [String: [Area]]()
                    z["zone"] = [zone]
                    var stations = metroStations.filter{$0.parent! == zone.code!}
                    stations.append(contentsOf: tramStations.filter{$0.parent! == zone.code!})
                    z["stations"] = stations
                    zonalArea.append(z)
                    
                }
                
                for item in zonalArea {
                    print("Zonal Area", item)
                }
                
                destinations.removeAll()
                
                if let totalDestinations = totalOperatingResponse["Destinations"] as? [[String:Any]] {

                    for item in totalDestinations {
                        
                        let destination = Destination(source: (item["Source"] as? Int)!, destination: (item["Destination"] as? Int)!, isActive: (item["IsActive"] as? Bool)!)
                        
                        destinations.append(destination)
                                                
                    }
                                
                }
                                                
                var localPickUpArea = [Area]()
                
                for item in tramStopsArea {
                    
                    if let pickUpLocation = destinations.filter({$0.source! == item.parent!}).first {
                        if localPickUpArea.contains(where: {$0.parent! == pickUpLocation.source }) {
                            
                        } else {
                            localPickUpArea.append(item)
                        }
                    }
                    
                }
                
                let set1: Set<Area> = Set(metroStopsArea)
                let set2: Set<Area> = Set(tramStopsArea)

                stops.removeAll()
                    
                stops = Array(set1.union(set2))

            }
            
        }
    }
}
