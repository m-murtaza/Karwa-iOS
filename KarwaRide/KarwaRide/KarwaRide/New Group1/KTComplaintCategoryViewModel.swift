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
        categories.append(ComplaintCategoryModel(12, "ico_vehicle", "str_vehicle_issues".localized(), "vehicle_issues_details".localized()))
        categories.append(ComplaintCategoryModel(14, "ico_driver", "driver_issues".localized(), "driver_issues_details".localized()))
        categories.append(ComplaintCategoryModel(15, "ico_fare", "fare_issues".localized(), "fare_issues_details".localized()))
        categories.append(ComplaintCategoryModel(13, "ico_safety", "safety_issues".localized(), "safety_issues_details".localized()))
        categories.append(ComplaintCategoryModel(17, "ico_other_complaints", "other_issue".localized(), "other_issue_details".localized()))
    }
    
    func getLostAndFoundCategories()
    {
        categories.append(ComplaintCategoryModel(1, "ico_personal_items", "personal_items".localized(), "personal_items_details".localized()))
        categories.append(ComplaintCategoryModel(2, "ico_appliances", "appliances".localized(), "appliances_details".localized()))
        categories.append(ComplaintCategoryModel(3, "ico_electronics", "electronics".localized(), "electronics_details".localized()))
        categories.append(ComplaintCategoryModel(4, "ico_documents", "documents".localized(), "documents_details".localized()))
        categories.append(ComplaintCategoryModel(10, "ico_valuables", "valuables".localized(), "valuables_details".localized()))
        categories.append(ComplaintCategoryModel(18, "ico_cards", "cards".localized(), "cards_details".localized()))
        categories.append(ComplaintCategoryModel(20, "ico_sports", "sports_item".localized(), "sports_item_detail".localized()))
        categories.append(ComplaintCategoryModel(11, "ico_other", "others".localized(), "others_detail".localized()))
    }

    func rowSelected(atIndex idx: Int)
    {
        selectedCategory = categories[idx]
        del?.showIssueSelectionScene()
    }
}
