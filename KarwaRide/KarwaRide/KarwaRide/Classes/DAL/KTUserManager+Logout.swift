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
    
    func logout(completion completionBlock:@escaping KTDALCompletionBlock)
    {
        /*self.get(url: Constants.APIURL.Logout, param: nil ) { (status, response) in
            
            completionBlock(Constants.APIResponseStatus.SUCCESS, response)  //No need to send
            
        }*/
        
        KTWebClient.sharedInstance.post(uri: Constants.APIURL.ForgotPass, param: nil) { (status, response) in
            
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
