//
//  KTNotificationViewModel.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 4/30/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

protocol KTNotificationViewModelDelegate: KTViewModelDelegate {
    func reloadTableData()
    func showDetail()
}

class KTNotificationViewModel: KTBaseViewModel {

    var notifications : [KTNotification] = []
    var del : KTNotificationViewModelDelegate?
    var selectedBooking :KTBooking?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        del = self.delegate as? KTNotificationViewModelDelegate
        fetchnNotifications()
    }
    
    func fetchnNotifications() {
        notifications = KTNotificationManager().allNotifications()
        //for n in notifications {
            
            self.del?.reloadTableData()
        //}
    }
    
    func numberOfRows() -> Int {
        
        return notifications.count
    }
    
    func message(forCellIdx idx: Int) -> String {
        
        return notifications[idx].message! 
    }
    
    func dateTime(forCellIdx idx: Int) -> String {
        
        return formatedDateForNotification(date: notifications[idx].receiveDate!)
    }
    
    func formatedDateForNotification(date: Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, dd MMM, YYYY 'at' HH:mm a"
        return dateFormatter.string(from: date)
    }
    
    func  agoTime(forCellIdx idx: Int) -> String {
        return (notifications[idx].receiveDate?.getElapsedInterval())!
    }
    
    func notificationIcon(forCellIdx idx: Int) -> UIImage {
        
        var img : UIImage = UIImage(named: "ic_arrived")!
        switch notifications[idx].bookingStatusWhenReceive {
        case BookingStatus.ARRIVED.rawValue:
            img = UIImage(named: "ic_arrived")!
            break
        case BookingStatus.CONFIRMED.rawValue:
            img = UIImage(named: "ic_confirmed")!
            break
        case BookingStatus.PICKUP.rawValue:
            img = UIImage(named: "ic_hired")!
            break
        case BookingStatus.COMPLETED.rawValue:
            img = UIImage(named: "ic_rating")!
            break
        case BookingStatus.TAXI_NOT_FOUND.rawValue, BookingStatus.TAXI_UNAVAIALBE.rawValue, BookingStatus.NO_TAXI_ACCEPTED.rawValue:
            img = UIImage(named: "ic_notfound")!
            break
        default:
            img = UIImage(named: "ic_generic")!
            break
        }
        return img
    }
    
    func rowSelected(atIndex idx: Int) {
        
        guard let notification : KTNotification = notifications[idx], let booking = notification.notificationToBooking else {
            return
        }
        selectedBooking = booking
        del?.showDetail()
    }
}
