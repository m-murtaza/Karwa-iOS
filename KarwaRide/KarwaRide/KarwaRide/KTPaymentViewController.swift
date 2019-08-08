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
import RKTagsView

protocol FinishProtocol
{
    func setFinishRequired(valueSent: Bool)
}

protocol BarcodeProtocol
{
    func setShowBarcodeRequired(valueSent: Bool)
}

class KTPaymentViewController: KTBaseDrawerRootViewController, KTPaymentViewModelDelegate, UITableViewDelegate, UITableViewDataSource, FinishProtocol, BarcodeProtocol, RKTagsViewDelegate
{
    @IBOutlet weak var tableView: UITableView!

    public var vModel : KTPaymentViewModel?
    public var payTripBean : PayTripBeanForServer?
    
    public var isManageButtonPressed = false
    public var isCrossButtonPressed = false
    public var isShowBarcodeRequired = false

    @IBOutlet weak var bottomContainer: SpringImageView!
    @IBOutlet weak var labelHTripFare: SpringLabel!
    @IBOutlet weak var labelTotalFare: SpringLabel!
    @IBOutlet weak var labelTripId: SpringLabel!
    @IBOutlet weak var labelHDriverTrip: SpringLabel!
    
    @IBOutlet weak var tagView: RKTagsView!
    
    
    @IBOutlet weak var btnPay: SpringButton!
    
    @IBOutlet weak var tripPaidSuccessImageView: SpringImageView!

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
//        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(payBtnTapped(tapGestureRecognizer:)))
        btnPay.isUserInteractionEnabled = true
//        btnPay.addGestureRecognizer(tapGestureRecognizer)

        tagView.textField.textAlignment = NSTextAlignment.center
        tagView.textFieldAlign = .center
        tagView.scrollsHorizontally = true

        tagView.allowsMultipleSelection = false
        tagView.isHidden = true
        tagView.editable = false
        tagView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        self.tableView.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
//        payTripBean = KTUtils.isValidQRCode("https://app.karwatechnologies.com/download/Z4G1+M6UuamSg7ESwUJIX+/dtiQsSsrIq/Vgq7q9P2c=,70,BTFN69I2I9,1")
//        self.isManageButtonPressed = true

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
        else
        {
            bottomContainer.isHidden = true
            labelTotalFare.isHidden = true
            labelTripId.isHidden = true
            btnPay.isHidden = true
            labelHTripFare.isHidden = true
            labelHDriverTrip.isHidden = true
        }
        
        if(payTripBean == nil && isManageButtonPressed)
        {
            isManageButtonPressed = !isManageButtonPressed
            gotoManagePayments()
        }
        
        if(isShowBarcodeRequired)
        {
            isShowBarcodeRequired = !isShowBarcodeRequired
            presentBarcodeScanner()
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
    
    func removeAllTags() {
        tagView.removeAllTags()
    }
    
    func addTag(tag: String) {
        tagView.addTag(tag)
    }

    func tagsView(_ tagsView: RKTagsView, buttonForTagAt index: Int) -> UIButton
    {
        tagView.scrollView.flashScrollIndicators()

        let btn: KTTripTagButton = KTTripTagButton(type:UIButtonType.custom)

        btn.setTitle(vModel?.tipOptions(atIndex: index), for: UIControlState.normal)

        btn.setTitleColor(UIColor(hexString:"#5B5A5A"), for: UIControlState.normal)
        
        btn.setTitleColor(UIColor.white, for: UIControlState.selected)
        
        btn.adjustsImageWhenHighlighted = false
        btn.addTarget(self, action: #selector(KTPaymentViewController.tagViewTapped), for: .touchUpInside)
        return btn
    }
    
    @objc func tagViewTapped() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2)
        {
            self.vModel?.tagViewTapped()
        }
    }
    
    func selectedTipIdx() ->[NSNumber] {
        return tagView.selectedTagIndexes
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
    
    func showCameraPermissionError()
    {
        showWarningBanner("", "Tap on Settings to Enable Camera")
    }
    
    func fillPayTripData(_ payTripBean: PayTripBeanForServer?)
    {
        if(payTripBean != nil)
        {
            labelTotalFare.text = "QR " + (payTripBean?.totalFare)!
            labelTripId.text = "TRIP ID: " + (payTripBean?.tripId)!
            updatePayButton(btnText: (payTripBean?.totalFare)!)
        }
    }
    
    func populatePayTripData()
    {
        tableView.isHidden = false
        showBottomContainer()
    }

    func getPayTripBean() -> PayTripBeanForServer
    {
        return payTripBean!
    }

    func updatePayButton(btnText value: String)
    {
        btnPay.setTitle("PAY (QR " + (value) + ")", for: .normal)
    }
    
    func showBottomContainer()
    {
        bottomContainer.isHidden = false
        labelHTripFare.isHidden = false
        labelTotalFare.isHidden = false
        labelTripId.isHidden = false
        labelHDriverTrip.isHidden = false
        btnPay.isHidden = false

        bottomContainer.animation = "slideUp"
        labelHTripFare.animation = "zoomIn"
        labelTotalFare.animation = "zoomIn"
        labelTripId.animation = "zoomIn"
        labelHDriverTrip.animation = "zoomIn"
        btnPay.animation = "slideUp"
        
        labelHTripFare.duration = 1
        bottomContainer.duration = 1
        labelTotalFare.duration = 1
        labelHDriverTrip.duration = 1
        labelTripId.duration = 1
        btnPay.duration = 1
        
        bottomContainer.delay = 0.15
        labelTripId.delay = 0.8
        labelHTripFare.delay = 0.9
        labelTotalFare.delay = 1.0
        labelHDriverTrip.delay = 1.1
        btnPay.delay = 1.7
        
        bottomContainer.animate()
        labelHTripFare.animate()
        labelTotalFare.animate()
        labelTripId.animate()
        labelHDriverTrip.animate()
        btnPay.animate()
        

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8)
        {
            UIView.animate(withDuration: 3.0, animations:
            {
                self.tagView.isHidden = false
            })
        }
    }
    
    func showPayBtn()
    {
        btnPay.isUserInteractionEnabled = true
//        btnPay.image = UIImage(named: "pay_button")
    }
    
    func showPayNonTappableBtn()
    {
        btnPay.isUserInteractionEnabled = false
//        btnPay.image = UIImage(named: "pay_button_inactive")
    }
    
    func showPaidSuccessBtn()
    {
        btnPay.isUserInteractionEnabled = false
//        btnPay.image = UIImage(named: "successfully_paid")
    }
    
    func hideBottomSheet()
    {
        btnPay.isEnabled = false

        bottomContainer.animation = "fadeOut"
        labelHTripFare.animation = "zoomOut"
        labelTotalFare.animation = "zoomOut"
        labelTripId.animation = "zoomOut"
        labelHDriverTrip.animation = "zoomOut"
        btnPay.animation = "zoomOut"
        
        labelHTripFare.duration = 1
        bottomContainer.duration = 1
        labelTotalFare.duration = 1
        labelHDriverTrip.duration = 1
        labelTripId.duration = 1
        btnPay.duration = 1
        
        bottomContainer.delay = 1.7
        labelTripId.delay = 1.1
        labelHTripFare.delay = 1.0
        labelTotalFare.delay = 0.9
        labelHDriverTrip.delay = 0.8
        btnPay.delay = 0.15
        
        bottomContainer.animate()
        labelHTripFare.animate()
        labelTotalFare.animate()
        labelTripId.animate()
        labelHDriverTrip.animate()
        btnPay.animate()
        
        UIView.animate(withDuration: 3.0, animations:
            {
                self.tagView.isHidden = true
        })
    }
    
    func showTripPaidScene()
    {
        hideBottomSheet()
        showPaidSuccessBtn()
        tableView.isHidden = true

        tripPaidSuccessImageView.animation = "zoomIn"
        tripPaidSuccessImageView.curve = "easeIn"
        tripPaidSuccessImageView.duration = 1
        tripPaidSuccessImageView.delay = 0.3

        tripPaidSuccessImageView.isHidden = false
        tripPaidSuccessImageView.animate()

        isPaidSuccessfullShowed = true
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
    
    func gotoDashboardRequired(required: Bool)
    {
        gotoDashboardRequired = required
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "segueToManagePayment"
        {
            let contentView : UINavigationController = segue.destination as! UINavigationController
            let destination : KTManagePaymentViewController = (contentView.viewControllers)[0] as! KTManagePaymentViewController
            destination.finishDelegate = self
            destination.barcodeDelegate = self
        }
    }
    
    func gotoManagePayments()
    {
        self.performSegue(withIdentifier: "segueToManagePayment", sender: self)
    }
    
    func reloadTableData()
    {
        tableView.reloadData()
    }
    
    
    @IBAction func payBtnTapped(_ sender: Any) {
        //        springAnimateButtonTapIn(imageView: btnPay)
        //        springAnimateButtonTapOut(imageView: btnPay)
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
    
    func setFinishRequired(valueSent: Bool) {
        isCrossButtonPressed = valueSent
    }
    
    func setShowBarcodeRequired(valueSent: Bool) {
        isShowBarcodeRequired = valueSent
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
