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
        
        let notificaiton : KTNotification = KTNotification.mr_createEntity()!
        notificaiton.message = (userInfo[Constants.NotificationKey.RootNotificationKey] as! [AnyHashable: Any])[Constants.NotificationKey.Message] as! String
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
}
