//
//  KTScanAndPayViewModel.swift
//  KarwaRide
//
//  Created by Sam Ash on 10/29/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import Foundation

protocol KTPaymentViewModelDelegate : KTViewModelDelegate
{
    func reloadTableData()
}

class KTPaymentViewModel: KTBaseViewModel
{
    var del : KTPaymentViewModelDelegate?

    var paymentMethods : [KTPaymentMethod] = []
    var selectedPaymentMethod = KTPaymentMethod()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        del = self.delegate as? KTPaymentViewModelDelegate
        fetchnPaymentMethods()
    }
    
    func numberOfRows() -> Int
    {
        return paymentMethods.count
    }
    
    func paymentMethodName(forCellIdx idx: Int) -> String
    {
        return "**** **** **** " + paymentMethods[idx].last_four_digits!
    }
    
    func expiry(forCellIdx idx: Int) -> String
    {
        return "EXP. " + paymentMethods[idx].expiry_month! + "/" + paymentMethods[idx].expiry_year!
    }
    
    func cardIcon(forCellIdx idx: Int) -> UIImage
    {
        return UIImage(named: getImage(paymentMethods[idx].brand!))!
    }
    
    func paymentTapped()
    {
        self.del?.reloadTableData()
    }
    
    func fetchnPaymentMethods()
    {
        self.del?.reloadTableData()
    }
    
    func rowSelected(atIndex idx: Int)
    {
        selectedPaymentMethod = paymentMethods[idx]
//        del?.showIssueSelectionScene()
    }
    
    func getImage(_ brand: String) -> String
    {
        var brandImage = "ico_wallet"
        
        switch brand
        {
        case "MASTERCARD":
            brandImage = "ico_mc"
            break;
        case "MASTER":
            brandImage = "ico_mc"
            break;
        case "VISACARD":
            brandImage = "ico_visa"
            break;
        case "VISA":
            brandImage = "ico_visa"
            break;
        case "AMEXCARD":
            brandImage = "ico_amex"
            break;
        case "AMEX":
            brandImage = "ico_amex"
            break;
        case "DINERSCLUBCARD":
            brandImage = "ico_dinersclub"
            break;
        case "DINERS_CLUB":
            brandImage = "ico_dinersclub"
            break;
        case "DISCOVERCARD":
            brandImage = "ico_discover"
            break;
        case "DISCOVER":
            brandImage = "ico_discover"
            break;
        case "JCBCARD":
            brandImage = "ico_jcb"
            break;
        case "JCB":
            brandImage = "ico_jcb"
            break;
        case "MAESTROCARD":
            brandImage = "ico_maestro"
            break;
        case "MAESTRO":
            brandImage = "ico_maestro"
            break;
        default:
            brandImage = "ico_wallet"
            break;
        }
        return brandImage
    }
}

