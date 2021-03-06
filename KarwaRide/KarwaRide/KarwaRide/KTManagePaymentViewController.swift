//
//  KTManagePaymentViewController.swift
//  KarwaRide
//
//  Created by Sam Ash on 7/28/19.
//  Copyright © 2019 Karwa. All rights reserved.
//

import Foundation

import UIKit
import BarcodeScanner
import Spring
import CDAlertView
import AVFoundation
import AlertOnboarding

class KTManagePaymentViewController: KTBaseDrawerRootViewController, KTManagePaymentViewModelDelegate, CardIOPaymentViewControllerDelegate, UITableViewDelegate, UITableViewDataSource
{
     @IBOutlet weak var tableView: UITableView!

    public var vModel : KTManagePaymentViewModel?
    
    public var isManageButtonPressed = false
    public var isCrossButtonPressed = false
    @IBOutlet weak var emptyView: SpringImageView!
    
    @IBOutlet weak var btnAdd: LocalisableSpringButton!
    @IBOutlet weak var btnEdit: UIBarButtonItem!
    
    var isTriggeredFromUniversalLink = false
    
    var finishDelegate:FinishProtocol?
    var barcodeDelegate:BarcodeProtocol?

    override func viewDidLoad()
    {
        self.viewModel = KTManagePaymentViewModel(del: self)
        vModel = viewModel as? KTManagePaymentViewModel
        
        self.tableView.dataSource = self
        self.tableView.delegate = self;
        
        super.viewDidLoad()
        
        self.tableView.rowHeight = 100
        self.tableView.tableFooterView = UIView()
        
        CardIOUtilities.preload()
    }
    
    func showCardOnboarding()
    {
        //First, declare datas
        let arrayOfImage = ["add_credit_card", "scan_qr_code", "pay_trip_fare"]
        let arrayOfTitle = ["payment_help_title_one".localized(), "str_scan_qr_code".localized(), "payment_help_title_three".localized()]
        let arrayOfDescription = ["payment_help_desc_one".localized(),
                                  "payment_help_desc_two".localized(),
                                  "payment_help_desc_three".localized()]
        
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
        btnAdd.isHidden = true

        if (viewModel as! KTManagePaymentViewModel).paymentMethods.count == 0 {
            btnEdit.title = ""
        } else {
            btnEdit.title = "txt_edit".localized()
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        if(isCrossButtonPressed)
        {
            sideMenuController?.contentViewController = self.storyboard?.instantiateViewController(withIdentifier: "BookingNavigationViewController")
            sideMenuController?.hideMenu()
            isCrossButtonPressed = !isCrossButtonPressed
            
            return
        }
        
        
        btnAdd.duration = 1
        btnAdd.delay = 0.15

        btnAdd.isHidden = false
        btnAdd.animation = "slideUp"
        btnAdd.animate()
    }
    
    func showCameraPermissionError()
    {
        showWarningBanner("", "camera_text".localized())
    }

    @IBAction func btnEditTapped(_ sender: Any) {
        
        if (viewModel as! KTManagePaymentViewModel).paymentMethods.count != 0 {
            toggleEditButton()
        }
    }
    
    
    func toggleEditButton()
    {
        if btnEdit.title! == "txt_edit".localized()
        {
            self.tableView.setEditing(true, animated: true)
            btnEdit.title = "txt_done".localized()
        }
        else
        {
            self.tableView.setEditing(false, animated: true)
            btnEdit.title = "txt_edit".localized()
        }
    }
    
    func toggleDoneToEdit()
    {
        self.tableView.setEditing(false, animated: true)
        if btnEdit.title! == "txt_done".localized()
        {
            btnEdit.title = "txt_edit".localized()
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
        if(editingStyle == .delete)
        {
            self.showPopupDeleteConfirmation(indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?{
        
        let deleteAction = UITableViewRowAction(style: .normal, title: "remove".localized()){ (rowAction, indexPath) in
            //            self.showPopupDeleteConfirmation(indexPath)
        }
        
        deleteAction.backgroundColor = .red
        
        self.showPopupDeleteConfirmation(indexPath)
        
        return [deleteAction]
        
    }
    
    func showPopupDeleteConfirmation(_ indexPath: IndexPath)
    {
        let alert = CDAlertView(title: "str_confirmation".localized(), message: "txt_remove_payment_method_confirmation".localized(), type: .warning)
        
        let removeAction = CDAlertViewAction(title: "remove".localized(), textColor: .red,
                                             handler:{(alert: CDAlertViewAction) -> Bool in
                                                self.vModel?.deletePaymentMethod(indexPath)
                                                self.toggleDoneToEdit()
                                                return true})
        
        alert.add(action: removeAction)
        
        let keepAction = CDAlertViewAction(title: "keep_payment".localized(), handler:{(alert: CDAlertViewAction) -> Bool in
            self.toggleDoneToEdit()
            return true})
        alert.add(action: keepAction)
        alert.show()
    }
    
    func deleteRowWithAnimation(_ indexPath: IndexPath)
    {
        self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
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
        tableView.isHidden = true
        btnEdit.title = ""
        
        showNoCardsBackground()
        
        if(!SharedPrefUtil.isScanNPayCoachmarkShownInDetails())
        {
            showCardOnboarding()
            SharedPrefUtil.setScanNPayCoachmarkShownInDetails()
        }
    }
    
    func showNoCardsBackground()
    {
        emptyView.isHidden = false
        emptyView.animation = "squeezeDown"
        emptyView.duration = 1
        emptyView.delay = 0.15
        emptyView.animate()
    }
    
    func hideEmptyScreen()
    {
        emptyView.isHidden = true
        tableView.isHidden = false
        btnEdit.title = "txt_edit".localized()
    }
    
    func reloadTableData()
    {
        if (viewModel as! KTManagePaymentViewModel).paymentMethods.count == 0 {
            btnEdit.title = ""
        } else {
            btnEdit.title = "txt_edit".localized()
        }
        tableView.reloadData()
    }
    
    @IBAction func addCardTapped(_ sender: Any) {
        vModel?.addCardButtonTapped()
    }

    func showAddCardVC()
    {
        presentAddCardViewController()
    }
    
    func showVerifyEmailPopup(email: String)
    {
        showPopupMessage("", "please_verify_email_str".localized() + email)
    }
    
    func showEnterEmailPopup()
    {
        showEnterEmailPopup(header: "txt_confirm_email".localized(), subHeader: "str_verify_email".localized(), currentText: "", inputType: "email")
    }
    
    func showEnterEmailPopup(header: String, subHeader: String, currentText : String, inputType: String)
    {
        let inputPopup = storyboard?.instantiateViewController(withIdentifier: "GenericInputVC") as! GenericInputVC
//        inputPopup.paymentVC = self
        view.addSubview(inputPopup.view)
        addChildViewController(inputPopup)
        
        inputPopup.inputType = inputType
        inputPopup.header.text = header
        inputPopup.txtPickupHint.text = currentText
        inputPopup.lblSubHeader.text = subHeader
    }
    
    func saveEmail(inputText: String)
    {
        vModel?.updateEmail(email: inputText)
    }
    
    @IBAction func btnBackTapped(_ sender: Any)
    {
        if(vModel?.paymentMethods.count == 0)
        {
            finishDelegate?.setFinishRequired(valueSent: true)
        }
        else
        {
            barcodeDelegate?.setShowBarcodeRequired(valueSent: true)
        }

        dismiss()
    }
    
    func gotoDashboard()
    {
        sideMenuController?.contentViewController = self.storyboard?.instantiateViewController(withIdentifier: "BookingNavigationViewController")
        sideMenuController?.hideMenu()
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
        cardIOVC?.modalPresentationStyle = .fullScreen
        present(cardIOVC!, animated: true, completion: nil)
    }
    
    var cardIOPaymentController = CardIOPaymentViewController()
    
    func userDidCancel(_ paymentViewController: CardIOPaymentViewController!)
    {
        paymentViewController?.dismiss(animated: true, completion: nil)
    }
    
    func userDidProvide(_ cardInfo: CardIOCreditCardInfo!, in paymentViewController: CardIOPaymentViewController!)
    {
        if let info = cardInfo
        {
            cardIOPaymentController = paymentViewController
            
            //            let str = NSString(format: "Received card info.\n Number: %@\n expiry: %02lu/%lu\n cvv: %@.", info.redactedCardNumber, info.expiryMonth, info.expiryYear, info.cvv)
            //            print(str)
            
            vModel?.updateSession(info.cardholderName, info.cardNumber, cardInfo.cvv, info.expiryMonth, info.expiryYear)
        }
    }
    
    func hideCardIOPaymentController()
    {
        DispatchQueue.main.async {
            self.cardIOPaymentController.dismiss(animated: true, completion: nil)
        }
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

    var completion: ((Transaction) -> Void)?
    var cancelled: (() -> Void)?

    internal func show3dSecureController(_ html:String)
    {
        // create the Gateway3DSecureViewController
        let threeDSecureView = Gateway3DSecureViewController(nibName: nil, bundle: nil)
        
        // Optionally, customize the presentation
        threeDSecureView.title = "3-D Secure"
        threeDSecureView.navBar.tintColor = UIColor(red: 1, green: 0.357, blue: 0.365, alpha: 1)
        // present the 3DSecureViewController
        present(threeDSecureView, animated: true)
        
        // provide the html content and a handler
        threeDSecureView.authenticatePayer(htmlBodyContent: html) { (threeDSView, result) in
            // dismiss the 3-D Secure view controller
            threeDSView.dismiss(animated: true)
            
            // handle the result case
            switch result
            {
            case .completed(summaryStatus: "<FAILED STATUS>", threeDSecureId: _):
                // failed authentication
                self.vModel!.kmpgs3dSecureFailure("3D Secure Failed")
                break;
            case .completed(summaryStatus: _, threeDSecureId: let _):
                // continue with the payment for all other statuses
                self.vModel!.updatePaymentMethod()
                break;
            default:
                // authentication was cancelled
                self.vModel!.kmpgs3dSecureFailure("3D Secure Failed")
                break;
                
            }
        }
    }
    
}
