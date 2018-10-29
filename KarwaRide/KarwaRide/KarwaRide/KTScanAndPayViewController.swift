//
//  KTScanAndPayViewController.swift
//  KarwaRide
//
//  Created by Sam Ash on 10/29/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

class KTScanAndPayViewController: KTBaseDrawerRootViewController,KTScanAndPayViewModelDelegate
{
    public var vModel : KTScanAndPayViewModel?
    
    override func viewDidLoad()
    {
        self.viewModel = KTScanAndPayViewModel(del: self)
        vModel = viewModel as? KTScanAndPayViewModel
        
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
//        if(segue.identifier == "segueCategoryToIssueSelection")
//        {
//            let navVC = segue.destination as? UINavigationController
//            let destination = navVC?.viewControllers.first as! KTIssueSelectionViewController
//            destination.previousControllerLifeCycle = self
//            destination.bookingId = (vModel?.bookingId)!
//            destination.categoryId = (vModel?.selectedCategory.id)!
//            destination.complaintType = (vModel?.isComplaintsShowing)! ? 1 : 2
//            destination.name = (vModel?.selectedCategory.title)!
//        }
    }
    
//    func showIssueSelectionScene()
//    {
//        self.performSegue(name: "segueCategoryToIssueSelection")
//    }
    
    func reloadTableData()
    {
    }
    
    func showIssueSelectionScene()
    {
    }
    
    func toggleTab(showSecondTab isComplaintsVisible: Bool)
    {
    }
}

