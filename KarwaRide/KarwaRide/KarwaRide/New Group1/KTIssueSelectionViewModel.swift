//
//  KTIssueSelectionViewModel.swift
//  KarwaRide
//
//  Created by Sam Ash on 10/11/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

protocol KTIssueSelectionViewModelDelegate: KTViewModelDelegate
{
    func reloadTableData()
}

class KTIssueSelectionViewModel: KTBaseViewModel
{
    var issues : [KTComplaint] = []
    var del : KTIssueSelectionViewModelDelegate?

    var bookingId = String()
    var categoryId = -1

    var isComplaintsShowing = true
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        del = self.delegate as? KTIssueSelectionViewModelDelegate
        modifyUIIfRequired()
    }
    
    func modifyUIIfRequired()
    {
        if(categoryId == -1)
        {
            //TODO: show direct input for remarks
        }
        else
        {
            fetchnComplaintsCategories()
        }
    }
    
    func numberOfRows() -> Int
    {
        return issues.count
    }
    
    func categoryName(forCellIdx idx: Int) -> String
    {
        return issues[idx].issue!
    }
    
    func issueTapped()
    {
        
    }
    
    func fetchnComplaintsCategories()
    {
        issues = KTComplaintsManager().getAllComplaints(categoryId: categoryId)
        self.del?.reloadTableData()
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
