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
import CDAlertView
import AVFoundation
import AlertOnboarding

class KTPaymentViewController: KTBaseDrawerRootViewController, KTPaymentViewModelDelegate, UITableViewDelegate, UITableViewDataSource
{

    @IBOutlet weak var tableView: UITableView!

    public var vModel : KTPaymentViewModel?
    public var payTripBean : PayTripBeanForServer?
    
    public var isManageButtonPressed = false
    public var isCrossButtonPressed = false
    @IBOutlet weak var emptyView: SpringImageView!
    
    @IBOutlet weak var bottomContainer: SpringImageView!
    @IBOutlet weak var labelTotalFare: SpringLabel!
    @IBOutlet weak var labelTripId: SpringLabel!
    @IBOutlet weak var labelPickupType: SpringLabel!
    @IBOutlet weak var btnPay: SpringImageView!
    
    @IBOutlet weak var tripPaidSuccessImageView: SpringImageView!
    @IBOutlet weak var btnEdit: UIBarButtonItem!
    
    var isTriggeredFromUniversalLink = false
    var gotoDashboardRequired = false
    private var isPaidSuccessfullShowed = false

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

//        showbarcodeScanner(show: true)
        
        tripPaidSuccessImageView.isHidden = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(payBtnTapped(tapGestureRecognizer:)))
        btnPay.isUserInteractionEnabled = true
        btnPay.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func showCardOnboarding()
    {
        //First, declare datas
        let arrayOfImage = ["add_credit_card", "scan_qr_code", "pay_trip_fare"]
        let arrayOfTitle = ["Add Credit Card", "Scan QR Code", "Pay Trip Fare"]
        let arrayOfDescription = ["Getting started by adding a new credit card for scan n pay payment",
                                  "Scan QR code from the taxi meter after ending the trip",
                                  "Now, you can pay your trip by your credit card!"]
        
        //Simply call AlertOnboarding...
        let alertView = AlertOnboarding(arrayOfImage: arrayOfImage, arrayOfTitle: arrayOfTitle, arrayOfDescription: arrayOfDescription)
        
        //        //Modify background color of AlertOnboarding
        //        alertView.colorForAlertViewBackground = UIColor(red: 173/255, green: 206/255, blue: 183/255, alpha: 1.0)
        
        //Modify colors of AlertOnboarding's button
        alertView.colorButtonText = UIColor.init(hex: "129793")
        alertView.colorButtonBottomBackground = UIColor.white

        //Modify colors of labels
        alertView.colorTitleLabel = UIColor.black
        alertView.colorDescriptionLabel = UIColor.init(hex: "A9A9B0")

        //Modify colors of page indicator
//      alertView.colorPageIndicator = UIColor.whiteColor()
//      alertView.colorCurrentPageIndicator = UIColor(red: 65/255, green: 165/255, blue: 115/255, alpha: 1.0)
        
        //Modify size of alertview (Purcentage of screen height and width)
        alertView.percentageRatioWidth = 0.9
        alertView.percentageRatioHeight = 0.65
        
        alertView.show()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        if(isCrossButtonPressed)
        {
            sideMenuViewController?.contentViewController = self.storyboard?.instantiateViewController(withIdentifier: "BookingNavigationViewController")
            sideMenuViewController?.hideMenuViewController()
            isCrossButtonPressed = !isCrossButtonPressed
            
            return
        }
        
        if(payTripBean != nil)
        {
            fillPayTripData(payTripBean)
            vModel?.showingTripPayment()
            showBottomContainer()
            populatePayTripData()
        }
    }

    func showbarcodeScanner(show: Bool)
    {
        if(!isTriggeredFromUniversalLink)
        {
            if(show)
            {
                presentBarcodeScanner()
            }
            isTriggeredFromUniversalLink = !isTriggeredFromUniversalLink
        }
    }
    
    func showCameraPermissionError()
    {
        showWarningBanner("", "Tap on Settings to Enable Camera")
    }
    
    func fillPayTripData(_ payTripBean: PayTripBeanForServer?)
    {
        if(payTripBean != nil)
        {
            labelTotalFare.text = "TOTAL FARE - QR " + (payTripBean?.totalFare)!
            labelTripId.text = "TRIP ID: " + (payTripBean?.tripId)!
            labelPickupType.text = payTripBean?.tripType == 1 ? "Street Pickup - Karwa" : "Booking - Karwa"
        }
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
        labelTotalFare.animation = "zoomIn"
        labelTripId.animation = "zoomIn"
        labelPickupType.animation = "zoomIn"
        btnPay.animation = "fadeIn"
        
        bottomContainer.duration = 1
        labelTotalFare.duration = 1
        labelTripId.duration = 1
        labelPickupType.duration = 1
        btnPay.duration = 1
        
        bottomContainer.delay = 0.15
        labelTotalFare.delay = 1
        labelTripId.delay = 1.15
        labelPickupType.delay = 1.30
        btnPay.delay = 2

        
        
        bottomContainer.animate()
        labelTotalFare.animate()
        labelTripId.animate()
        labelPickupType.animate()
        btnPay.animate()
    }
    
    func showPayBtn()
    {
        btnPay.isUserInteractionEnabled = true
        btnPay.image = UIImage(named: "pay_button")
    }
    
    func showPayNonTappableBtn()
    {
        btnPay.isUserInteractionEnabled = false
        btnPay.image = UIImage(named: "pay_button_inactive")
    }
    
    func showPaidSuccessBtn()
    {
        btnPay.isUserInteractionEnabled = false
        btnPay.image = UIImage(named: "successfully_paid")
    }
    
    func showTripPaidScene()
    {
        showPaidSuccessBtn()
        tableView.isHidden = true

        tripPaidSuccessImageView.animation = "zoomIn"
        tripPaidSuccessImageView.curve = "easeIn"
        tripPaidSuccessImageView.duration = 1
        tripPaidSuccessImageView.delay = 0.3

        tripPaidSuccessImageView.isHidden = false
        tripPaidSuccessImageView.animate()
        
        btnEdit.title = ""
        isPaidSuccessfullShowed = true
    }
    
    @IBAction func editBtnTapped(_ sender: Any)
    {
        toggleEditButton()
    }
    
    func toggleEditButton()
    {
        if btnEdit.title! == "Edit"
        {
            self.tableView.setEditing(true, animated: true)
            btnEdit.title = "Done"
        }
        else
        {
            self.tableView.setEditing(false, animated: true)
            btnEdit.title = "Edit"
        }
    }
    
    func toggleDoneToEdit()
    {
        self.tableView.setEditing(false, animated: true)
        if btnEdit.title! == "Done"
        {
            btnEdit.title = "Edit"
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return (vModel?.numberOfRows())!
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle
    {
        if self.tableView.isEditing
        {
            return UITableViewCellEditingStyle.delete
        }
        else
        {
            return UITableViewCellEditingStyle.none
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
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
        btnEdit.title = ""

        emptyView.animation = "squeezeDown"
        emptyView.duration = 1
        emptyView.delay = 0.15
        
        emptyView.animate()
        
        if(!SharedPrefUtil.isScanNPayCoachmarkShownInDetails())
        {
            showCardOnboarding()
            SharedPrefUtil.setScanNPayCoachmarkShownInDetails()
        }
    }

    func hideEmptyScreen()
    {
        emptyView.isHidden = true
        tableView.isHidden = false
        btnEdit.title = "Edit"
    }
    
    func gotoDashboardRequired(required: Bool)
    {
        gotoDashboardRequired = required
    }

    func gotoManagePayments()
    {
        self.performSegue(name: "SagueToManagePayment")
    }
    
    func reloadTableData()
    {
        tableView.reloadData()
    }
    
    @objc func payBtnTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        springAnimateButtonTapIn(imageView: btnPay)
        springAnimateButtonTapOut(imageView: btnPay)
        vModel!.payTripButtonTapped(payTripBean: payTripBean!)
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

    @IBAction func btnBackTapped(_ sender: Any)
    {
        if(isPaidSuccessfullShowed || gotoDashboardRequired)
        {
            gotoDashboard()
        }
        else if(isManageButtonPressed || !gotoDashboardRequired)
        {
            presentBarcodeScanner()
            isManageButtonPressed = !isManageButtonPressed
        }
        else
        {
            dismiss()
        }
    }
    
    func gotoDashboard()
    {
        sideMenuViewController?.contentViewController = self.storyboard?.instantiateViewController(withIdentifier: "BookingNavigationViewController")
        sideMenuViewController?.hideMenuViewController()
    }
    
    private func presentBarcodeScanner()
    {
        present(makeBarcodeScannerViewController(), animated: true, completion: nil)
    }
    
    func isCameraPermissionGiven() -> Bool
    {
        var isPermissionGiven = false
        
        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized
        {
            isPermissionGiven = true
        } else
        {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                if granted
                {
                    isPermissionGiven = true
                }
            })
        }
        return isPermissionGiven
    }

    private func makeBarcodeScannerViewController() -> BarcodeScannerViewController
    {
        if(!isCameraPermissionGiven())
        {
            showCameraPermissionError()
        }

        let viewController = BarcodeScannerViewController()
        viewController.codeDelegate = self
        viewController.errorDelegate = self
        viewController.dismissalDelegate = self
        viewController.manageDelegate = self

        viewController.cameraViewController.barCodeFocusViewType = .animated

        return viewController
    }
}

// MARK: - BarcodeScannerCodeDelegate
extension KTPaymentViewController: BarcodeScannerCodeDelegate {
    func scanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String) {
//        print("Barcode Data: \(code)")
//        print("Symbology Type: \(type)")
        let tripServerBean = KTUtils.isValidQRCode(code)
        if(tripServerBean != nil)
        {
            payTripBean = tripServerBean
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
