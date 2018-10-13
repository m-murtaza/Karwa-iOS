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
    func showInputRemarksLayout()
}

class KTIssueSelectionViewModel: KTBaseViewModel
{
    var issues : [KTComplaint] = []
    var del : KTIssueSelectionViewModelDelegate?

    var bookingId = String()
    var categoryId = -1
    var issueId : Int32 = -1

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
            showRemarksLayout()
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
        showRemarksLayout()
    }
    
    func showRemarksLayout()
    {
        del?.showInputRemarksLayout()
    }
    
    func submitBtnTapped(remarksString remarks : String)
    {
        if(categoryId == -1 && remarks.count == 0)
        {
            del?.showToast(message: "Please Enter Remarks")
        }
        else
        {
            sendComplaintToServer(remarks)
        }
    }

    func sendComplaintToServer(_ remarks: String)
    {
        print("Remarks are: " + remarks)
    }
    
    func fetchnComplaintsCategories()
    {
        issues = KTComplaintsManager().getAllComplaints(categoryId: categoryId)
        self.del?.reloadTableData()
    }
    
    func rowSelected(atIndex idx: Int)
    {
        print("issue ID: \(issueId) selected")
        issueId = issues[idx].issueId
        issueTapped()
    }
}
