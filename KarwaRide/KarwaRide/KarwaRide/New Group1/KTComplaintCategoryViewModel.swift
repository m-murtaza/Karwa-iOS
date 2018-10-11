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
    func showIssueSelectionScene()
    func toggleTab(showSecondTab isComplaintsVisible : Bool)
}

class KTComplaintCategoryViewModel: KTBaseViewModel
{
    var categories : [ComplaintCategoryModel] = []
    var del : KTComplaintCategoryViewModelDelegate?
    var isComplaintsShowing = true

    var bookingId = String()
    var selectedCategory = ComplaintCategoryModel()

    override func viewDidLoad()
    {
        super.viewDidLoad()
        del = self.delegate as? KTComplaintCategoryViewModelDelegate
        fetchnComplaintsCategories()
    }
    
    func numberOfRows() -> Int
    {
        return categories.count
    }
    
    func categoryName(forCellIdx idx: Int) -> String
    {
        return categories[idx].title
    }
    
    func description(forCellIdx idx: Int) -> String
    {
        return categories[idx].desc
    }
    
    func notificationIcon(forCellIdx idx: Int) -> UIImage
    {
        return UIImage(named: categories[idx].image)!
    }

    func complaintTapped()
    {
        if(!isComplaintsShowing)
        {
            categories.removeAll()
            getComplaintsCategories()
            self.del?.reloadTableData()
            self.del?.toggleTab(showSecondTab: isComplaintsShowing)
            isComplaintsShowing = !isComplaintsShowing
        }
    }
    
    func lostItemTapped()
    {
        if(isComplaintsShowing)
        {
            categories.removeAll()
            getLostAndFoundCategories()
            self.del?.reloadTableData()
            self.del?.toggleTab(showSecondTab: isComplaintsShowing)
            isComplaintsShowing = !isComplaintsShowing
        }
    }
    
    func fetchnComplaintsCategories()
    {
        getComplaintsCategories()
        self.del?.reloadTableData()
    }
    
    func getComplaintsCategories()
    {
        categories.append(ComplaintCategoryModel(12, "ico_vehicle", "VEHICLE ISSUES", "Cleanliness, A/C, Printer not working, etc"))
        categories.append(ComplaintCategoryModel(14, "ico_driver", "DRIVER ISSUES", "Mis-behaved, Speaking negatively, Smoking, etc"))
        categories.append(ComplaintCategoryModel(15, "ico_fare", "FARE ISSUES", "Tampering, Long route, Meter not working, etc"))
        categories.append(ComplaintCategoryModel(13, "ico_safety", "SAFETY ISSUES", "Lane discipline, Over speeding, Poor driving, etc"))
        categories.append(ComplaintCategoryModel(-1, "ico_other", "I HAVE DIFFERENT ISSUES", "Some feedback, quality improvements, etc"))
    }
    
    func getLostAndFoundCategories()
    {
        categories.append(ComplaintCategoryModel(1, "ico_personal_items", "PERSONAL ITEMS", "Handbag, Keys, Luggage, Clothes, etc"))
        categories.append(ComplaintCategoryModel(2, "ico_appliances", "APPLIANCES", "LED TV, Heater, Microwave, Speakers, etc"))
        categories.append(ComplaintCategoryModel(3, "ico_electronics", "ELECTRONICS", "Mobile, Camera, Tablet, Laptop, etc"))
        categories.append(ComplaintCategoryModel(4, "ico_documents", "DOCUMENTS", "ertificates, Books, Passport, etc"))
        categories.append(ComplaintCategoryModel(10, "ico_valuables", "VALUABLES", "Gold, Cash, Silver Jewelry, etc"))
        categories.append(ComplaintCategoryModel(18, "ico_cards", "CARDS", "QID, Driving license, ATM, Credit Card, etc"))
        categories.append(ComplaintCategoryModel(20, "ico_sports", "SPORTS ITEMS", "Football, Cricket, Tennis, Badminton, etc"))
        categories.append(ComplaintCategoryModel(-1, "ico_other", "OTHERS", "I have lost something else"))
    }

    func rowSelected(atIndex idx: Int)
    {
        selectedCategory = categories[idx]
        del?.showIssueSelectionScene()
    }
}
