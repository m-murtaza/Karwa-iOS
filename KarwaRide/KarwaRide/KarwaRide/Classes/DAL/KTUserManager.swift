//
//  KTLoginManager.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 11/28/17.
//  Copyright © 2017 Karwa. All rights reserved.
//

import UIKit
import MagicalRecord
import Alamofire

class KTUserManager: KTDALManager {

    // MARK: - CRUD DB Operations
    func saveUserInfoInDBFromAppSession()
    {
        MagicalRecord.save({(_ localContext: NSManagedObjectContext) -> Void in
            
            let user : KTUser = KTUser.mr_createEntity()!
            user.customerType = KTAppSessionInfo.currentSession.customerType!.rawValue
            //user.name = KTAppSessionInfo.currentSession.
            user.countryCode = KTAppSessionInfo.currentSession.countryCode
            user.phone = KTAppSessionInfo.currentSession.phone
            //user.email = "ualeem@faad.com"
            
        }, completion: {(_ success: Bool, _ error: Error?) -> Void in
           
        })
    }
    
    func saveUserInfoInDB(_ response: [AnyHashable: Any], completion:@escaping (Bool) -> Void )
    {
        MagicalRecord.save({(_ localContext: NSManagedObjectContext) -> Void in
           _ = KTUser.mr_truncateAll(in: localContext)
            let user : KTUser = KTUser.mr_createEntity(in: localContext)! //KTUser.mr_createEntity()!
            user.customerType = response[Constants.LoginResponseAPIKey.CustomerType] as! Int32
            user.name = response[Constants.LoginResponseAPIKey.Name] as? String
            user.countryCode = response[Constants.LoginResponseAPIKey.CountryCode] as? String
            user.phone = response[Constants.LoginResponseAPIKey.Phone] as? String
            user.email = response[Constants.LoginResponseAPIKey.Email] as? String
            user.sessionId = response[Constants.LoginResponseAPIKey.SessionID] as? String
            user.isEmailVerified = response[Constants.LoginResponseAPIKey.IsEmailVerified] as! Bool
        }, completion: {(_ success: Bool, _ error: Error?) -> Void in
            completion(success)
        })
    }
    
    func loginUserInfo() -> KTUser? {
        guard NSManagedObjectContext.mr_default() != nil else {
            return nil
        }
        
        var user : KTUser? = nil
        var users: [NSManagedObject]!
        users = KTUser.mr_findAll(in: NSManagedObjectContext.mr_default())
        if users.count > 0 {
            user = users[0] as? KTUser
        }
        return user
    }
    
    // MARK: - Check Login
    
    func isUserLogin(completion:@escaping (Bool) -> Void)
    {
//        completion(false)
//        return
//            //-- Remove above two lines.
        
        if runFirstTimeAfterMajorUpdate() {
            //Is running first time after Major Update
            userLoginInOldApplication(completion: completion)
        }
        else
        {
            //Login check in current version.
            isUserAlreadyLogin(completion : completion)
        }
    }
    // Mark: - Login User in new Application
    private func isUserAlreadyLogin(completion: @escaping (Bool) -> Void)
    {
        let loginUser : KTUser? = loginUserInfo()
        guard (loginUser != nil) else {
            
            completion(false)
            return
        }
        KTAppSessionInfo.currentSession.customerType = CustomerType(rawValue: (loginUser?.customerType)!)
        KTAppSessionInfo.currentSession.phone = loginUser?.phone
        KTAppSessionInfo.currentSession.sessionId = loginUser?.sessionId
        completion(true)
        
    }
    func login(params : NSMutableDictionary,url : String?,completion completionBlock: @escaping KTDALCompletionBlock)  {
        
        params[Constants.LoginParams.DeviceType] = Constants.DeviceTypes.iOS
        if (KTAppSessionInfo.currentSession.pushToken != nil)
        {
            if (KTAppSessionInfo.currentSession.pushToken?.count)! > 40
            {
                params[Constants.LoginParams.DeviceToken] = [KTAppSessionInfo.currentSession.pushToken]
            }
        }
        
        print(params)

        self.post(url: url!, param: params as! [String : Any], completion: completionBlock) { (response,  cBlock) in
            
            self.saveUserInSessionInfo(response)
            
            self.saveUserInfoInDB(response,completion: {(success:Bool) -> Void in
                completionBlock(Constants.APIResponseStatus.SUCCESS, response)
            })
        }
    }
    
    func login(countryCodey: String, phone: String, password: String,completion completionBlock:@escaping KTDALCompletionBlock)
    {
        let params : NSMutableDictionary = [Constants.LoginParams.CountryCode : countryCodey,
                                            Constants.LoginParams.Phone : phone,
                                            Constants.LoginParams.Password: password]
        
        self.login(params: params,url: Constants.APIURL.Login, completion: completionBlock)
        
    }
    
    
    func loadAppSessionFromDB() {
        
        let user : KTUser? = loginUserInfo()
        if user != nil {
            KTAppSessionInfo.currentSession.sessionId = user?.sessionId
            KTAppSessionInfo.currentSession.phone = user?.phone
            KTAppSessionInfo.currentSession.customerType = CustomerType(rawValue:(user?.customerType)!)
            
        }
    }
    
    func saveUserInSessionInfo(_ response:[AnyHashable: Any]) {
        
        KTAppSessionInfo.currentSession.customerType =  CustomerType(rawValue: (response[Constants.LoginResponseAPIKey.CustomerType] as! Int32))
        KTAppSessionInfo.currentSession.countryCode = response[Constants.LoginResponseAPIKey.CountryCode] as? String
        KTAppSessionInfo.currentSession.phone = response[Constants.LoginResponseAPIKey.Phone] as? String
        KTAppSessionInfo.currentSession.sessionId = response[Constants.LoginResponseAPIKey.SessionID] as? String
    }
    
    
    // Mark: - Login User in old Application
    private let appRunBeforeAfterMajorUpdateKey : String = "appRunBeforeAfterMajorUpdate"
    private func runFirstTimeAfterMajorUpdate() -> Bool
    {
        let appRunBeforeAfterMajorUpdate : Bool = UserDefaults.standard.bool(forKey: appRunBeforeAfterMajorUpdateKey)
        
        UserDefaults.standard.set(true, forKey: appRunBeforeAfterMajorUpdateKey)
        guard appRunBeforeAfterMajorUpdate else {
            return true         //appRunBeforeAfterMajorUpdate= false or not found
        }
        
        return false
    }
    
    private let KTPhoneKey = "KSSessionPhone"
    private let KTSessionIdKey = "KSSessionID"
    private let KTCustomerTypeKey = "KSCustomerType"
    
    //If User was login in older version then this function will populate KTAppSessionInfo class and return true.
    //else return false.
    private func userLoginInOldApplication(completion: @escaping (Bool) -> Void)
    {
        let sessionId : String? = UserDefaults.standard.string(forKey: KTSessionIdKey)
        if (sessionId ?? "").isEmpty {
            completion(false)
        }
        else
        {
            KTAppSessionInfo.currentSession.sessionId = sessionId
            KTAppSessionInfo.currentSession.phone = UserDefaults.standard.string(forKey: KTPhoneKey)!
            KTAppSessionInfo.currentSession.customerType = CustomerType(rawValue: Int32(UserDefaults.standard.integer(forKey: KTCustomerTypeKey)))
            
            self.fetchUserInfoFromServer(completion: completion)
            
        }
    }
    
    // Mark: API User Info
    func fetchUserInfoFromServer(completion:@escaping (Bool) -> Void) {
        KTWebClient.sharedInstance.get(uri: Constants.APIURL.GetUserInfo, param: nil, completion: { (status, response) in
            if status != true {
                //Its web API status, Not API success
                completion(false)
            }
            else
            {
                print("User info ***********************")
                print(response[Constants.ResponseAPIKey.Data])
                print("***********************")

                if response[Constants.ResponseAPIKey.Status] as! String == Constants.APIResponseStatus.SUCCESS
                {
                    
                    self.saveUserInfoInDB(response[Constants.ResponseAPIKey.Data] as! [AnyHashable : Any],completion: completion)
                }
                else
                {
                    
                    completion(false)
                }
            }
        })
    }
    
    func openAppStore() {
        let appStoreLink = "https://itunes.apple.com/us/app/karwa-ride/id1050410517?mt=8"

        /* First create a URL, then check whether there is an installed app that can
         open it on the device. */
        if let url = URL(string: appStoreLink), UIApplication.shared.canOpenURL(url) {
            // Attempt to open the URL.
            UIApplication.shared.open(url, options: [:], completionHandler: {(success: Bool) in
                if success {
                    print("Launching \(url) was successful")
//                    AnalyticsUtil.trackBehavior(event: "Rate-App")
                }})
        }
    }
    
    // Mark: API User Info
    func fetchVersion() {
        
        KTWebClient.sharedInstance.get(uri: Constants.APIURL.VersionCheck, param: nil, completion: { (status, response) in
            
            print(response)
            
            print(response["D"] as? [String:[String:Any]])
            
            if let dataResponse = response["D"] as? [String:Any] {
                
                print("dataResponse version", dataResponse["Version"] as! Int)
                
                if let latestBuildNumber = dataResponse["Version"] as? Int {
                    if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                        if latestBuildNumber > Int(build) ?? 0 {
                            
                            if let isCritical = dataResponse["IsCritical"] as? Bool, isCritical == true {
                                let alertController = UIAlertController(title: "", message: "str_update_req".localized(), preferredStyle: .alert)
                                let okAction = UIAlertAction(title: "str_update".localized(), style: .default) { (UIAlertAction) in
                                    self.openAppStore()
                                }
                                alertController.addAction(okAction)
                                let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                                appDelegate.showAlter(alertController: alertController)
                                
                            } else {
                                
                                if optionalUpdateCancelButtonPressed == false {
                                    let alertController = UIAlertController(title: "", message: "str_update_req".localized(), preferredStyle: .alert)
                                    
                                    let okAction = UIAlertAction(title: "str_update".localized(), style: .default) { (UIAlertAction) in
                                        self.openAppStore()
                                    }
                                    let cancelAction = UIAlertAction(title: "str_later".localized(), style: .default) { (UIAlertAction) in
                                        optionalUpdateCancelButtonPressed = true
                                    }
                                    alertController.addAction(okAction)
                                    alertController.addAction(cancelAction)
                                    let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                                    appDelegate.showAlter(alertController: alertController)
                                }
                                
                            }
                            
                        }
                    }
                }
                
                
            }
            
           
        })
    }
}


class VersionCheck {
  
  public static let shared = VersionCheck()
  
  func isUpdateAvailable(callback: @escaping (Bool)->Void) {
    let bundleId = Bundle.main.infoDictionary!["CFBundleIdentifier"] as! String
      
      print("bundleId", bundleId)
      
    Alamofire.request("https://itunes.apple.com/lookup?bundleId=\(bundleId)").responseJSON { response in
      if let json = response.result.value as? NSDictionary, let results = json["results"] as? NSArray, let entry = results.firstObject as? NSDictionary, let versionStore = entry["version"] as? String, let versionLocal = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
          
          print(json)
          
        let arrayStore = versionStore.split(separator: ".").compactMap { Int($0) }
        let arrayLocal = versionLocal.split(separator: ".").compactMap { Int($0) }

        if arrayLocal.count != arrayStore.count {
          callback(true) // different versioning system
          return
        }

        // check each segment of the version
        for (localSegment, storeSegment) in zip(arrayLocal, arrayStore) {
          if localSegment < storeSegment {
            callback(true)
            return
          }
        }
      }
      callback(false) // no new version or failed to fetch app store version
    }
  }
  
}
