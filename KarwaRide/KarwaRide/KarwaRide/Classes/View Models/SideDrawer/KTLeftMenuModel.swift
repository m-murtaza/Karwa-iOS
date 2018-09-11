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
    
    init(title t: String, image i:UIImage, color c:UIColor) {
        title = t
        image = i
        color = c
    }
}

protocol KTLeftMenuDelegate : KTViewModelDelegate {
    
    func updateUserName (name : String)
    func updatePhoneNumber(phone: String)
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
        (delegate as! KTLeftMenuDelegate).updateUserName(name: (user.name != nil) ? (user.name!) : "No Name")
        (delegate as! KTLeftMenuDelegate).updatePhoneNumber(phone: (user.phone != nil) ? (user.phone!) : "No Phone")
    
    }
    
    func setMenuItems() {
        
        let menuItem1 : KTMenuItems = KTMenuItems(title: "Start a Booking", image: UIImage(named:"LMStartBooking")!, color: UIColor(hexString: "#25AAF1"))
        drawerOptions.append(menuItem1)
        
        let menuItem2 : KTMenuItems = KTMenuItems(title: "My Trips", image: UIImage(named:"LMMyTrips")!, color: UIColor(hexString: "#9FB067"))
        drawerOptions.append(menuItem2)
        
        let menuItem3 : KTMenuItems = KTMenuItems(title: "Notifications", image: UIImage(named:"LMNotification")!, color: UIColor(hexString: "#9B9B9B"))
        drawerOptions.append(menuItem3)
        
        let menuItem4 : KTMenuItems = KTMenuItems(title: "Fare Details", image: UIImage(named:"LMFareBreakdown")!, color: UIColor(hexString: "#1BB4B4"))
        drawerOptions.append(menuItem4)
        
//        let menuItem5 : KTMenuItems = KTMenuItems(title: "Payment Methods", image: UIImage(named:"LMPayment")!, color: UIColor(hexString: "#778F5F"))
//        drawerOptions.append(menuItem5)
        
        let menuItem5 : KTMenuItems = KTMenuItems(title: "Settings", image: UIImage(named:"LMSetting")!, color: UIColor(hexString: "#F56458"))
        drawerOptions.append(menuItem5)
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
