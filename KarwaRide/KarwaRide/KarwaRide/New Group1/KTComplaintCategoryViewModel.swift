//
//  KTComplaintCategoryViewModel.swift
//  KarwaRide
//
//  Created by Sam Ash on 10/9/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import Foundation

protocol KTComplaintCategoryViewModelDelegate: KTViewModelDelegate
{
    func reloadTableData()
    func showDetail()
}

class KTComplaintCategoryViewModel: KTBaseViewModel
{
    var complaintsCategories : [ComplaintCategoryModel] = []
    var lostItemsCategories : [ComplaintCategoryModel] = []
    var del : KTComplaintCategoryViewModelDelegate?
    var selectedBooking :KTBooking?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        del = self.delegate as? KTComplaintCategoryViewModelDelegate
        fetchnComplaintsCategories()
    }
    
    func numberOfRows() -> Int
    {
        print("Count is: \(complaintsCategories.count)")
        return complaintsCategories.count
    }
    
    func categoryName(forCellIdx idx: Int) -> String
    {
        print(String("Name: " + complaintsCategories[idx].title))
        return complaintsCategories[idx].title
    }
    
    func description(forCellIdx idx: Int) -> String
    {
        print(String("Desc: " + complaintsCategories[idx].desc))
        return complaintsCategories[idx].desc
    }
    
    func notificationIcon(forCellIdx idx: Int) -> UIImage
    {
        print(String("Image: " + complaintsCategories[idx].image))
        return UIImage(named: complaintsCategories[idx].image)!
    }
    
    func fetchnComplaintsCategories()
    {
        getComplaintsCategories()
        self.del?.reloadTableData()
    }
    
    func getComplaintsCategories()
    {
        complaintsCategories.append(ComplaintCategoryModel(12, "ico_vehicle", "VEHICLE ISSUES", "Cleanliness, A/C, Printer not working, etc"))
        complaintsCategories.append(ComplaintCategoryModel(14, "ico_driver", "DRIVER ISSUES", "Mis-behaved, Speaking negatively, Smoking, etc"))
        complaintsCategories.append(ComplaintCategoryModel(15, "ico_fare", "FARE ISSUES", "Tampering, Long route, Meter not working, etc"))
        complaintsCategories.append(ComplaintCategoryModel(13, "ico_safety", "SAFETY ISSUES", "Lane discipline, Over speeding, Poor driving, etc"))
        complaintsCategories.append(ComplaintCategoryModel(-1, "ico_other", "I HAVE DIFFERENT ISSUES", "Some feedback, quality improvements, etc"))
    }
    
    func getLostAndFoundCategories() -> [ComplaintCategoryModel]
    {
        lostItemsCategories.append(ComplaintCategoryModel(1, "ico_personal_items", "PERSONAL ITEMS", "Handbag, Keys, Luggage, Clothes, etc"))
        lostItemsCategories.append(ComplaintCategoryModel(2, "ico_appliances", "APPLIANCES", "LED TV, Heater, Microwave, Speakers, etc"))
        lostItemsCategories.append(ComplaintCategoryModel(3, "ico_electronics", "ELECTRONICS", "Mobile, Camera, Tablet, Laptop, etc"))
        lostItemsCategories.append(ComplaintCategoryModel(4, "ico_documents", "DOCUMENTS", "ertificates, Books, Passport, etc"))
        lostItemsCategories.append(ComplaintCategoryModel(10, "ico_valuables", "VALUABLES", "Gold, Cash, Silver Jewelry, etc"))
        lostItemsCategories.append(ComplaintCategoryModel(18, "ico_cards", "CARDS", "QID, Driving license, ATM, Credit Card, etc"))
        lostItemsCategories.append(ComplaintCategoryModel(20, "ico_sports", "SPORTS ITEMS", "Football, Cricket, Tennis, Badminton, etc"))
        lostItemsCategories.append(ComplaintCategoryModel(-1, "ico_others", "OTHERS", "I have lost something else"))
        
        return lostItemsCategories;
    }

    func rowSelected(atIndex idx: Int)
    {
//        guard let notification : KTNotification = complaintsCategory[idx], let booking = notification.notificationToBooking else {
//            return
//        }
//        selectedBooking = booking
//        del?.showDetail()
    }
}
