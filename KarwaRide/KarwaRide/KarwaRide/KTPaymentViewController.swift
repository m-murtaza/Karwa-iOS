//
//  KTScanAndPayViewController.swift
//  KarwaRide
//
//  Created by Sam Ash on 10/29/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
import BarcodeScanner

class KTPaymentViewController: KTBaseDrawerRootViewController, KTPaymentViewModelDelegate, CardIOPaymentViewControllerDelegate
{
    public var vModel : KTPaymentViewModel?
    
    override func viewDidLoad()
    {
        self.viewModel = KTPaymentViewModel(del: self)
        vModel = viewModel as? KTPaymentViewModel
        
        super.viewDidLoad()
        
        CardIOUtilities.preload()

    }
    
    @IBAction func btnAddCardTapped(_ sender: Any)
    {
        let cardIOVC = CardIOPaymentViewController(paymentDelegate: self)
        cardIOVC?.modalPresentationStyle = .formSheet
        cardIOVC?.collectCardholderName = true

        present(cardIOVC!, animated: true, completion: nil)
    }

    @IBAction func btnBackTapped(_ sender: Any)
    {
        dismiss()
    }

    func userDidCancel(_ paymentViewController: CardIOPaymentViewController!) {
        paymentViewController?.dismiss(animated: true, completion: nil)
    }
    
    func userDidProvide(_ cardInfo: CardIOCreditCardInfo!, in paymentViewController: CardIOPaymentViewController!) {
        if let info = cardInfo {
            let str = NSString(format: "Received card info.\n Number: %@\n expiry: %02lu/%lu\n cvv: %@.", info.redactedCardNumber, info.expiryMonth, info.expiryYear, info.cvv)
            print(str)
        }
        paymentViewController?.dismiss(animated: true, completion: nil)
    }
}
