//
//  KSSideDrawerModel.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 11/22/17.
//  Copyright © 2017 Karwa. All rights reserved.
//

import UIKit

struct KTMenuItems {
    var title : String = ""
    var image : UIImage = UIImage(named: "LMStartBooking")!
    var color : UIColor = UIColor.red
    var isNew : Bool = false
    
    init(title t: String, image i:UIImage, color c:UIColor, isNew n: Bool) {
        title = t
        image = i
        color = c
        isNew = n
    }
}

protocol KTLeftMenuDelegate : KTViewModelDelegate {
    
    func updateUserName (name : String)
    func updatePhoneNumber(phone: String)
    func reloadTable()
}

class KTLeftMenuModel: KTBaseViewModel {

    var drawerOptions = [KTMenuItems]()
    
    override func viewDidLoad() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.userLogin(notification:)), name:Notification.Name(Constants.Notification.UserLogin) , object: nil)
        
        setMenuItems()
    }
    
    override func viewWillAppear() {
        updateUserInfo()
    }
    
    @objc func userLogin(notification: Notification) {
        
        updateUserInfo()
    }
    
    func updateUserInfo() {

        guard let user:KTUser = KTUserManager().loginUserInfo() else {
            return
        }
        
        let phone = (user.phone != nil) ? (user.phone!) : "No Phone"
        let countryCode = (user.countryCode != nil) ? (user.countryCode!) : "+974"
        
        (delegate as! KTLeftMenuDelegate).updateUserName(name: (user.name != nil) ? (user.name!) : "No Name")
        (delegate as! KTLeftMenuDelegate).updatePhoneNumber(phone: countryCode + phone)
    }
    
    func isEmailVerified(idx: Int) -> Bool
    {
        if(drawerOptions[idx].title == "Settings")
        {
            guard let user:KTUser = KTUserManager().loginUserInfo() else {
                return false
            }
            return user.isEmailVerified
        }
        
        return true
    }
    
    func reloadData()
    {
        updateUserInfo()
        (delegate as! KTLeftMenuDelegate).reloadTable()
    }
    
    func setMenuItems() {
      let menuItem1 : KTMenuItems = KTMenuItems(title: "txt_get_a_ride".localized(), image: UIImage(named:"icon-get-a-ride")!, color: UIColor(hexString: "#006170"), isNew: false)
        drawerOptions.append(menuItem1)
        
      let menuItem2 : KTMenuItems = KTMenuItems(title: "txt_ride_hist".localized(), image: UIImage(named:"icon-ride-history")!, color: UIColor(hexString: "#006170"), isNew: false)
        drawerOptions.append(menuItem2)
        
        let menuItem3 : KTMenuItems = KTMenuItems(title: "str_wallet".localized(), image: UIImage(named:"menu_ico_wallet")!, color: UIColor(hexString: "#006170"), isNew: true)
        drawerOptions.append(menuItem3)
        
        //str_wallet
        let menuItem4 : KTMenuItems = KTMenuItems(title: "str_promotions".localized(), image: UIImage(named:"LMpromotions")!, color: UIColor(hexString: "#006170"), isNew: false)
        drawerOptions.append(menuItem4)

        let menuItem5 : KTMenuItems = KTMenuItems(title: "txt_scan_n_pay".localized(), image: UIImage(named:"qrcode")!, color: UIColor(hexString: "#006170"), isNew: false)
        drawerOptions.append(menuItem5)

        let menuItem6 : KTMenuItems = KTMenuItems(title: "txt_feedback".localized(), image: UIImage(named:"feedback")!, color: UIColor(hexString: "#006170"), isNew: false)
        drawerOptions.append(menuItem6)

        let menuItem7 : KTMenuItems = KTMenuItems(title: "str_notifications".localized(), image: UIImage(named:"LMNotification")!, color: UIColor(hexString: "#006170"), isNew: false)
        drawerOptions.append(menuItem7)

        let menuItem8 : KTMenuItems = KTMenuItems(title: "txt_help".localized(), image: UIImage(named:"help")!, color: UIColor(hexString: "#006170"), isNew: false)
        drawerOptions.append(menuItem8)
        
        if !KTConfiguration.sharedInstance.checkRSEnabled() {
            let menuItem9 : KTMenuItems = KTMenuItems(title: "txt_settings".localized(), image: UIImage(named:"LMSetting")!, color: UIColor(hexString: "#006170"), isNew: false)
            drawerOptions.append(menuItem9)
        }
    }
    
    func numberOfRowsInSection() -> Int
    {
        return drawerOptions.count as Int
    }
    
    func textInCell(idx : Int) -> String {
        return drawerOptions[idx].title
    }
    
    func ImgTypeInCell(idx : Int) -> UIImage {
        return drawerOptions[idx].image
    }
    
    func colorInCell(idx : Int) -> UIColor {
        
        return drawerOptions[idx].color
    }
    
    func isNew(idx : Int) -> Bool {
        
        return drawerOptions[idx].isNew
    }
    
    func segueIdentifireForIdxPath(idx: Int) -> String
    {
        var segueIdentifire: String?
        switch idx
        {
        case 0:
            segueIdentifire = "segueDrawerToBookingNav"
        case 1:
            segueIdentifire = "segueDrawerToSecNav"
        default:
            segueIdentifire = "segueDrawerToBookingNav"
        }
        return segueIdentifire!
    }
}
