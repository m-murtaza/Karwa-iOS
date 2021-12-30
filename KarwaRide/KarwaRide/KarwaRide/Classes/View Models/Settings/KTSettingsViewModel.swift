//
//  KTSettingsViewModel.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 2/27/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
import StoreKit

protocol KTSettingsViewModelDelegate {
    func showLogoutConfirmAlt()
    func reloadTable()
}
class KTSettingsViewModel: KTBaseViewModel {

    private var userInfo : KTUser?
    override func viewDidLoad() {
        
    }
    
    override func viewWillAppear() {
        userInfo = KTUserManager().loginUserInfo()
        (delegate as! KTSettingsViewModelDelegate).reloadTable()
        KTUserManager().fetchUserInfoFromServer { _ in
            self.reloadData()
        }
    }
    
    func reloadData()
    {
        userInfo = KTUserManager().loginUserInfo()
        (delegate as! KTSettingsViewModelDelegate).reloadTable()
    }
    
    func userName() -> String {
        var name = ""
        if userInfo != nil && userInfo?.name != nil {
            name = (userInfo?.name)!
        }
        return name
    }
    
    func userPhone() -> String {
        var phone = ""
        var countryCode = "+974"

        if userInfo != nil && userInfo?.phone != nil {
            phone = (userInfo?.phone)!
        }
        
        if userInfo != nil && userInfo?.countryCode != nil {
            countryCode = (userInfo?.countryCode)!
        }

        return countryCode + phone
    }
    
    func isEmailVerified() -> Bool
    {
        return userInfo?.isEmailVerified ?? false
    }
    
    func percentageCompletion() -> Int {

        var completeness: Int = 0

        if userInfo != nil && userInfo?.name != nil
        {
            completeness += 20
        }
        if userInfo != nil && userInfo?.phone != nil
        {
            completeness += 20
        }
        if userInfo != nil && userInfo?.email != nil
        {
            completeness += 30
        }
        if userInfo != nil && userInfo?.dob != nil
        {
            completeness += 15
        }
        if userInfo != nil && userInfo?.gender != nil && userInfo?.gender != 0
        {
            completeness += 15
        }
        
        return completeness
    }
    
    func appVersion() -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        
        return "str_version ".localized() + version! + " (" + build! + ")"
    }
    
    // Mark: - Logout
    func startLogoutProcess()  {
        lastSelectedIndexPath = IndexPath.init(row: 0, section: 0)
        (delegate as! KTSettingsViewModelDelegate).showLogoutConfirmAlt()
    }
    
    func logout() {
        KTUserManager().logout { (status, response) in
            print("Logout on server " + status)
            KTUserManager().removeUserData()
            KTPaymentManager().removeAllPaymentData()
            PreviousSelectedPayment.shared.selectedPaymentMethod = nil
            PreviousSelectedPayment.shared.rebook = false
            self.showLogin()
        }
    }

    func showLogin()  {
        (UIApplication.shared.delegate as! AppDelegate).showLogin()
    }
    
    //MARK:- Rate Applicaiton
    func rateApplication() {
        
        SKStoreReviewController.requestReview()
        
//        // App Store URL.
//        let appStoreLink = "https://itunes.apple.com/us/app/karwa-ride/id1050410517?mt=8"
//
//        /* First create a URL, then check whether there is an installed app that can
//         open it on the device. */
//        if let url = URL(string: appStoreLink), UIApplication.shared.canOpenURL(url) {
//            // Attempt to open the URL.
//            UIApplication.shared.open(url, options: [:], completionHandler: {(success: Bool) in
//                if success {
//                    print("Launching \(url) was successful")
//                    AnalyticsUtil.trackBehavior(event: "Rate-App")
//                }})
//        }
    }
    
}
