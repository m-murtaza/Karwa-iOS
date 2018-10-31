//
//  KTScanAndPayViewController.swift
//  KarwaRide
//
//  Created by Sam Ash on 10/29/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
import BarcodeScanner

class KTPaymentViewController: KTBaseDrawerRootViewController, KTPaymentViewModelDelegate, CardIOPaymentViewControllerDelegate, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var tableView: UITableView!

    public var vModel : KTPaymentViewModel?
    
    override func viewDidLoad()
    {
        self.viewModel = KTPaymentViewModel(del: self)
        vModel = viewModel as? KTPaymentViewModel
        
        self.tableView.dataSource = self
        self.tableView.delegate = self;

        super.viewDidLoad()
        
        self.tableView.rowHeight = 80
        self.tableView.tableFooterView = UIView()
        
        CardIOUtilities.preload()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return (vModel?.numberOfRows())!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell : KTPaymentViewCell = tableView.dequeueReusableCell(withIdentifier: "KTPaymentViewCellIdentifier") as! KTPaymentViewCell
        cell.cardNumber.text = vModel?.paymentMethodName(forCellIdx: indexPath.row)
        cell.cardExpiry.text = vModel?.expiry(forCellIdx: indexPath.row)
        cell.cardImage.image  = vModel?.cardIcon(forCellIdx: indexPath.row)
        cell.selectionStyle = .none

//        animateCell(cell, delay: animationDelay)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return UIView(frame:
            CGRect(x: 0, y: 0, width: 10 , height: 30))
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        vModel?.rowSelected(atIndex: indexPath.row)
    }
    
//    func showEmptyScreen() {
//        imgEmpty.isHidden = false
//        tblView.isHidden = true
//    }
//
//    func hideEmptyScreen() {
//        imgEmpty.isHidden = true
//        tblView.isHidden = false
//    }
    
    func reloadTableData()
    {
        tableView.reloadData()
    }
    
    @IBAction func btnAddCardTapped(_ sender: Any)
    {
        presentAddCardViewController()
    }

    @IBAction func btnBackTapped(_ sender: Any)
    {
        dismiss()
    }

    func presentAddCardViewController()
    {
        let cardIOVC = CardIOPaymentViewController(paymentDelegate: self)
        cardIOVC?.modalPresentationStyle = .formSheet
        cardIOVC?.collectCardholderName = true
        cardIOVC?.collectCVV = true
        cardIOVC?.collectExpiry = true
        cardIOVC?.hideCardIOLogo = true
        cardIOVC?.keepStatusBarStyle = true
        cardIOVC?.scanExpiry = true
        present(cardIOVC!, animated: true, completion: nil)
    }
    
    func userDidCancel(_ paymentViewController: CardIOPaymentViewController!)
    {
        paymentViewController?.dismiss(animated: true, completion: nil)
    }
    
    func userDidProvide(_ cardInfo: CardIOCreditCardInfo!, in paymentViewController: CardIOPaymentViewController!)
    {
        if let info = cardInfo {
            let str = NSString(format: "Received card info.\n Number: %@\n expiry: %02lu/%lu\n cvv: %@.", info.redactedCardNumber, info.expiryMonth, info.expiryYear, info.cvv)
            print(str)
        }
        paymentViewController?.dismiss(animated: true, completion: nil)
    }
}
