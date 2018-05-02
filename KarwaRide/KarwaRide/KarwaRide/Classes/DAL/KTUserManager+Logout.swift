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
        KTWebClient.sharedInstance.post(uri: Constants.APIURL.Logout, param: nil) { (status, response) in
            
            completionBlock(Constants.APIResponseStatus.SUCCESS, response)  //No need to send
        }
    }
    
    func removeUserData()  {
        KTAppSessionInfo.currentSession.removeCurrentSession()
        //do {
            KTUser.mr_truncateAll(in: NSManagedObjectContext.mr_default())
            KTBooking.mr_truncateAll(in: NSManagedObjectContext.mr_default())
            NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()

//        }
//        catch _{
//            
//            print("Unable to logout")
//        }
    }
}
