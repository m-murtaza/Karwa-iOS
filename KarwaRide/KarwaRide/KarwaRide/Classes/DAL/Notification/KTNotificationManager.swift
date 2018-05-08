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
        notificaiton.receiveDate = Date(timeIntervalSince1970: Double(userInfo[Constants.NotificationKey.NotificationTime] as! String)!)
        
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
    
    func deleteNotification(forBooking booking: KTBooking)  {
        guard booking.bookingToNotification != nil else {
            return
        }
        
        for notification in  booking.bookingToNotification! {
            (notification as! KTNotification).mr_deleteEntity()
        }
        booking.bookingToNotification = nil
    }
    
    func deleteOldNotifications()  {
        let date :  Date = Date().addingTimeInterval(-3600*24)
        let predicate : NSPredicate = NSPredicate(format: "receiveDate < %@", date as CVarArg)
        let notifications : [KTNotification] = KTNotification.mr_findAll(with: predicate) as! [KTNotification]
        
        for notification in notifications {
            notification.mr_deleteEntity()
        }
    }
}
