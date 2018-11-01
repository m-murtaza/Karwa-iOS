//
//  KTScanAndPayViewController.swift
//  KarwaRide
//
//  Created by Sam Ash on 10/29/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
import BarcodeScanner
import Spring

class KTPaymentViewController: KTBaseDrawerRootViewController, KTPaymentViewModelDelegate, CardIOPaymentViewControllerDelegate, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var tableView: UITableView!

    public var vModel : KTPaymentViewModel?
    public var payTripBean : PayTripBeanForServer?
    
    public var isManageButtonPressed = false
    public var isCrossButtonPressed = false
    @IBOutlet weak var emptyView: UIImageView!
    
    @IBOutlet weak var bottomContainer: SpringImageView!
    @IBOutlet weak var labelTotalFare: SpringLabel!
    @IBOutlet weak var labelTripId: SpringLabel!
    @IBOutlet weak var labelPickupType: SpringLabel!
    @IBOutlet weak var btnPay: SpringButton!
    
    @IBOutlet weak var btnAdd: SpringButton!
    
    
    override func viewDidLoad()
    {
        self.viewModel = KTPaymentViewModel(del: self)
        vModel = viewModel as? KTPaymentViewModel
        
        self.tableView.dataSource = self
        self.tableView.delegate = self;

        super.viewDidLoad()
        
        self.tableView.rowHeight = 100
        self.tableView.tableFooterView = UIView()
        
        CardIOUtilities.preload()
        
        payTripBean = nil
        presentBarcodeScanner()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        if(payTripBean == nil)
        {
            hideBottomContainer()
        }
        btnAdd.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        if(isCrossButtonPressed)
        {
            sideMenuViewController?.contentViewController = self.storyboard?.instantiateViewController(withIdentifier: "BookingNavigationViewController")
            sideMenuViewController?.hideMenuViewController()
            isCrossButtonPressed = !isCrossButtonPressed
        }
        
        if(payTripBean != nil)
        {
            showBottomContainer()
            populatePayTripData()
            btnAdd.duration = 1
            btnAdd.delay = 1
        }
        else
        {
            btnAdd.duration = 1
            btnAdd.delay = 0.15
        }
        btnAdd.isHidden = false
        btnAdd.animation = "slideUp"
        btnAdd.animate()
    }

    func populatePayTripData()
    {
        showBottomContainer()
    }

    func showBottomContainer()
    {
        bottomContainer.isHidden = false
        labelTotalFare.isHidden = false
        labelTripId.isHidden = false
        labelPickupType.isHidden = false
        btnPay.isHidden = false
        
        bottomContainer.animation = "slideUp"
        labelTotalFare.animation = "slideUp"
        labelTripId.animation = "slideUp"
        labelPickupType.animation = "slideUp"
        btnPay.animation = "slideUp"
        
        bottomContainer.duration = 1
        labelTotalFare.duration = 1
        labelTripId.duration = 1
        labelPickupType.duration = 1
        btnPay.duration = 1
        
        bottomContainer.delay = 0.15
        labelTotalFare.delay = 0.25
        labelTripId.delay = 0.35
        labelPickupType.delay = 0.45
        btnPay.delay = 0.55

        
        
        bottomContainer.animate()
        labelTotalFare.animate()
        labelTripId.animate()
        labelPickupType.animate()
        btnPay.animate()
    }
    
    func hideBottomContainer()
    {
        bottomContainer.isHidden = true
        labelTotalFare.isHidden = true
        labelTripId.isHidden = true
        labelPickupType.isHidden = true
        btnPay.isHidden = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return (vModel?.numberOfRows())!
    }
    
    var animationDelay = 1.0
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell : KTPaymentViewCell = tableView.dequeueReusableCell(withIdentifier: "KTPaymentViewCellIdentifier") as! KTPaymentViewCell
        cell.cardNumber.text = vModel?.paymentMethodName(forCellIdx: indexPath.row)
        cell.cardExpiry.text = vModel?.expiry(forCellIdx: indexPath.row)
        cell.cardImage.image  = vModel?.cardIcon(forCellIdx: indexPath.row)
        cell.cellBackground?.image = vModel?.cardSelection(forCellIdx: indexPath.row)
        cell.selectionStyle = .none

        animateCell(cell, delay: animationDelay)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView(frame: CGRect(x: 0, y: 0, width: 10 , height: 20))
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        vModel?.rowSelected(atIndex: indexPath.row)
    }
    
    func showEmptyScreen()
    {
        emptyView.isHidden = false
        tableView.isHidden = true
    }

    func hideEmptyScreen()
    {
        emptyView.isHidden = true
        tableView.isHidden = false
    }
    
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
        if(isManageButtonPressed)
        {
            presentBarcodeScanner()
            isManageButtonPressed = !isManageButtonPressed
        }
        else
        {
            dismiss()
        }
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
    
    private func presentBarcodeScanner()
    {
        present(makeBarcodeScannerViewController(), animated: true, completion: nil)
    }
    
    private func makeBarcodeScannerViewController() -> BarcodeScannerViewController
    {
        let viewController = BarcodeScannerViewController()
        viewController.codeDelegate = self
        viewController.errorDelegate = self
        viewController.dismissalDelegate = self
        viewController.manageDelegate = self
        
        // Change focus view style
        viewController.cameraViewController.barCodeFocusViewType = .animated
        
        return viewController
    }
    
    private func isValidQRCode(_ code: String) -> Bool
    {
        //TODO: Validate QR Code Data
        return true
    }
}

// MARK: - BarcodeScannerCodeDelegate
extension KTPaymentViewController: BarcodeScannerCodeDelegate {
    func scanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String) {
        print("Barcode Data: \(code)")
        print("Symbology Type: \(type)")

        if(isValidQRCode(code))
        {
            payTripBean = PayTripBeanForServer("1001387", "", "10", "12", 1, "", "", "")
            self.isManageButtonPressed = true
            controller.dismiss(animated: false, completion: nil)
        }
        else
        {
            controller.resetWithError()
        }
    }
}

// MARK: - BarcodeScannerErrorDelegate
extension KTPaymentViewController: BarcodeScannerErrorDelegate {
    func scanner(_ controller: BarcodeScannerViewController, didReceiveError error: Error) {
        controller.resetWithError()
    }
}

// MARK: - BarcodeScannerDismissalDelegate
extension KTPaymentViewController: BarcodeScannerDismissalDelegate
{
    func scannerDidDismiss(_ controller: BarcodeScannerViewController)
    {
        self.isCrossButtonPressed = true
        controller.dismiss(animated: false, completion: nil)
    }
}

// MARK: - BarcodeScannerDismissalDelegate
extension KTPaymentViewController: BarcodeScannerManageDelegate
{
    func scannerDidManage(_ controller: BarcodeScannerViewController)
    {
        self.isManageButtonPressed = true
        payTripBean = nil
        controller.dismiss(animated: true, completion: nil)
    }
}
