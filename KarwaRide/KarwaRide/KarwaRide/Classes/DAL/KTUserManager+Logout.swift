//
//  KTUserManager+Logout.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 2/28/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import Foundation
extension KTUserManager
{
    
    func logout() {
        
        let alertController = UIAlertController(title: "Session Expired", message: "Please login again", preferredStyle: .alert)
        
        //let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
            
            self.logout { (status, response) in
                print("Logout on server " + status)
                self.removeUserData()
                self.removeNotification()
                (UIApplication.shared.delegate as! AppDelegate).showLogin()
                
            }
        }
        alertController.addAction(okAction)
        
        let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.showAlter(alertController: alertController)
    }
    
    func logout(completion completionBlock:@escaping KTDALCompletionBlock)
    {
        
        //Do not call self.post as we don't need to handle error and self.post will handle error
        KTWebClient.sharedInstance.get(uri: Constants.APIURL.Logout, param: nil) { (status, response) in
            
            completionBlock(Constants.APIResponseStatus.SUCCESS, response)  //No need to send
        }
    }
    
    func removeNotification() {
        KTNotificationManager().deleteAllNotifications()
    }
    
    func removeUserData()  {
        KTDALManager().removeSyncTime(forKey: BOOKING_SYNC_TIME)
        KTDALManager().removeSyncTime(forKey: USER_PREF_SYNC_TIME)

        KTAppSessionInfo.currentSession.removeCurrentSession()
        
        KTUser.mr_truncateAll(in: NSManagedObjectContext.mr_default())
        KTBooking.mr_truncateAll(in: NSManagedObjectContext.mr_default())
        KTNotification.mr_truncateAll(in: NSManagedObjectContext.mr_default())
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
        

    }
}
