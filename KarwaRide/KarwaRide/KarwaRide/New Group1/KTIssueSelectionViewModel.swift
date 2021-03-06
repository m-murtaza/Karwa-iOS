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
    func showMessage(_ title: String, _ message: String)
    func setSubTitle(_ issueName: String)
}

class KTIssueSelectionViewModel: KTBaseViewModel
{
    var issues : [KTComplaint] = []
    var del : KTIssueSelectionViewModelDelegate?

    var bookingId = String()
    var categoryId = -1
    var issueId = -1
    var complaintType = 1

    var isComplaintsShowing = true
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        del = self.delegate as? KTIssueSelectionViewModelDelegate
        modifyUIIfRequired()
    }
    
    func modifyUIIfRequired()
    {
        if(categoryId == 17 || categoryId == 11)
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
        if((categoryId == 17 || categoryId == 11) && remarks.count == 0)
        {
            del?.showToast(message: "err_empty_complain_remarks".localized())
        }
        else
        {
            sendComplaintToServer(remarks)
        }
    }

    func fetchnComplaintsCategories()
    {
        issues = KTComplaintsManager().getAllComplaints(categoryId: categoryId)
        self.del?.reloadTableData()
    }
    
    func rowSelected(atIndex idx: Int)
    {
        print("issue ID: \(issueId) selected")
        issueId = Int(issues[idx].issueId)
        del?.setSubTitle((issues[idx].issue)!)
        issueTapped()
    }
    
    func sendComplaintToServer(_ remarks: String)
    {
        delegate?.showProgressHud(show: true)

        let booking = KTBookingManager().getBooking(bookingId: bookingId)

        let complaint = ComplaintBeanForServer(bookingId, complaintType, categoryId, issueId, remarks, booking.tripType)
        
        KTComplaintsManager().createComplaintAtServer(complaint: complaint) { (status, response) in
            self.delegate?.hideProgressHud()
            
            self.del?.showMessage("", "booking_rated".localized())
        }
    }
}
