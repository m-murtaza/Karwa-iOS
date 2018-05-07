//
//  KTNotificationManager.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 4/30/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

class KTNotificationManager: KTDALManager {

    func saveNotificaiton(serverNotification userInfo: [AnyHashable: Any], booking: KTBooking) {
        
        let notificaiton : KTNotification = KTNotification.mr_createEntity(in: NSManagedObjectContext.mr_default())!
        notificaiton.message = (userInfo[Constants.NotificationKey.RootNotificationKey] as! [AnyHashable: Any])[Constants.NotificationKey.Message] as! String
        
        notificaiton.bookingStatusWhenReceive =  Int32(userInfo[Constants.NotificationKey.BookingStatus] as! String)!
        notificaiton.receiveDate = Date()
        
        notificaiton.notificationToBooking = booking
        booking.bookingToNotification = (booking.bookingToNotification?.adding(notificaiton) as! NSSet)
        
        do {
            
            try NSManagedObjectContext.mr_default().save()
        }
        catch _{
            
            print("Unable to save notification")
            //completion(false,[])
        }
    }
    
    func allNotifications() -> [KTNotification] {
        
        return KTNotification.mr_findAllSorted(by: "receiveDate", ascending: true) as! [KTNotification]
    }
}
