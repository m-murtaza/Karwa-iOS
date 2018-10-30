//
//  KTScanAndPayViewController.swift
//  KarwaRide
//
//  Created by Sam Ash on 10/29/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
import BarcodeScanner

class KTPaymentViewController: KTBaseDrawerRootViewController,KTPaymentViewModelDelegate
{
    public var vModel : KTPaymentViewModel?
    
    override func viewDidLoad()
    {
        self.viewModel = KTPaymentViewModel(del: self)
        vModel = viewModel as? KTPaymentViewModel
        
        super.viewDidLoad()
    }
    
    @IBAction func btnAddCardTapped(_ sender: Any)
    {
        //TODO: Add Card Screen
    }

    @IBAction func btnBackTapped(_ sender: Any)
    {
        dismiss()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
    }
    
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

