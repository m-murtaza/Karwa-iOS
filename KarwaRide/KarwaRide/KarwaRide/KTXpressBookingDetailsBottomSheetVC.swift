//
//  KTXpressBookingDetailsBottomSheetVC.swift
//  KarwaRide
//
//  Created by Satheesh on 8/8/2021.
//  Copyright © 2021 Karwa. All rights reserved.
//

import Foundation
import UBottomSheet
import Spring
import ABLoaderView
import FittedSheets

class KTXpressBookingDetailsBottomSheetVC: UIViewController, Draggable
{
    var vModel : KTXpresssBookingDetailsViewModel?
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var rideHeaderText: LocalisableSpringLabel!
    @IBOutlet weak var lblPickAddress: LocalisableButton!
    @IBOutlet weak var lblDropoffAddress: LocalisableButton!

//    @IBOutlet weak var lblPickMessage: SpringLabel!
//    @IBOutlet weak var bookingTime: UILabel!
//    @IBOutlet weak var btnETA: LocalisableButton!
    
    @IBOutlet weak var btnShare: LocalisableButton!
    @IBOutlet weak var btnCancel: LocalisableButton!
    @IBOutlet weak var btnPhone: LocalisableSpringButton!
    @IBOutlet weak var btnRebook: SpringButton!
        
//    @IBOutlet weak var iconVehicle: SpringImageView!
//    @IBOutlet weak var lblVehicleType: LocalisableLabel!
    @IBOutlet weak var lblPassengerCount: LocalisableLabel!
    @IBOutlet weak var lblVehicleNumber: UILabel!
    @IBOutlet weak var imgNumberPlate: UIImageView!
    
    @IBOutlet weak var fareInfoView: UIView!
    @IBOutlet weak var lblDriverName: LocalisableSpringLabel!
    @IBOutlet weak var starView: SpringLabel!
    var sheetCoordinator: UBottomSheetCoordinator?
    var sheet: SheetViewController?

//    @IBOutlet weak var constraintTripInfoMarginTop: NSLayoutConstraint!
//    @IBOutlet weak var constraintDriverInfoMarginTop: NSLayoutConstraint!
//    @IBOutlet weak var constraintVehicleInfoMarginTop: NSLayoutConstraint!
//    @IBOutlet weak var constraintViewRideActionsTop: NSLayoutConstraint!
//    @IBOutlet weak var constraintRebookMarginTop: NSLayoutConstraint!
    @IBOutlet weak var heightOFScrollViewContent: NSLayoutConstraint!

//    @IBOutlet weak var seperatorBeforeReportAnIssue: UIView!
    @IBOutlet weak var bottomStartRatingLabel: LocalisableLabel!
    
    var oneTimeSetSizeForBottomSheet = false

    @IBOutlet weak var fareBreakDownView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sheet?.handleScrollView(self.scrollView)
        self.lblPickAddress.titleLabel?.numberOfLines = 2
        self.lblDropoffAddress.titleLabel?.numberOfLines = 2
        self.sheet?.view.backgroundColor = .clear
        btnRebook.isUserInteractionEnabled = true
        
    }
    
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
//        sheetCoordinator?.startTracking(item: self)
//        sheetCoordinator?.addDropShadowIfNotExist()
//        (sheetCoordinator?.parent as! (KTBookingDetailsViewController)).setMapPadding(height: 40)
//        constraintPlateNo.constant = Device.language().contains("ar") ? 60 : 25
    }
    
    func draggableView() -> UIScrollView? {
        return scrollView
    }

    @IBAction func cancelBtnTap(_ sender: Any) {
        self.vModel?.buttonTapped(withTag: BottomBarBtnTag.Cancel.rawValue)
    }
    
    @IBAction func shareBtnTap(_ sender: Any) {
        shareBtnTapped()
    }

    @IBAction func phoneBtnTap(_ sender: Any) {
        vModel?.callDriver()
    }

    @IBAction func btnFareInfoTap(_ sender: Any)
    {
        vModel?.buttonTapped(withTag: BottomBarBtnTag.FareBreakdown.rawValue)
    }

    func updateBookingCard()
    {
        lblPickAddress.setTitle(vModel?.pickAddress(), for: .normal)
        lblDropoffAddress.setTitle( vModel?.dropAddress(), for: .normal)

//        if let msg = vModel?.pickMessage() {
//            lblPickMessage.text = msg
//        } else {
//            lblPickMessage.isHidden = true
//        }
        
//        bookingTime.text = (vModel?.pickupDayAndTime())! + (vModel?.pickupDateOfMonth())!  + (vModel?.pickupMonth())! + (vModel?.pickupYear())!

        updateVehicleDetails()
        
        updateBookingBottomSheet()

        updateBookingStatusOnCard(false)
    }

    func hideBtnComplain()
    {
//        btnReportIssue.isHidden = true
    }
    
    func showBtnComplain()
    {
//        if Device.getLanguage().contains("AR") {
//            btnReportIssue.contentHorizontalAlignment = .right
//        } else {
//            btnReportIssue.contentHorizontalAlignment = .left
//        }
//        btnReportIssue.isHidden = false
    }
    
    func hideRebookBtn()
    {
        btnRebook.isHidden = true
    }
    
    func showRebookBtn()
    {
        btnRebook.isHidden = false
    }
    
    func hideFareDetailBtn()
    {
        fareInfoView.isHidden = true
//        btnFareInfo.isHidden = true
    }

    func showFareDetailBtn()
    {
        fareInfoView.isHidden = false
//        btnFareInfo.isHidden = false
    }
    
    func hidePhoneButton()
    {
        btnPhone.isHidden = true
    }
    
    func showPhoneButton()
    {
        btnPhone.isHidden = false
    }

    func updateBookingCardForCompletedBooking()
    {
//        eta.isHidden = true
        btnPhone.isHidden = true
    }

    func updateBookingCardForUnCompletedBooking()
    {
        updateBookingBottomSheet()
    }

    @IBAction func btnComplainTap(_ sender: Any)
    {
        performSegue(withIdentifier: "segueComplaintCategorySelection", sender: self)
    }
    
    
    @IBAction func btnRebookTap(_ sender: UIButton)
    {
        vModel?.buttonTapped(withTag: BottomBarBtnTag.Rebook.rawValue)
    }
    
    @IBAction func btnRebookTapTouchIn(_ sender: UIButton)
    {
        sender.setBackgroundColor(color: .clear, forState: .highlighted)

        sender.layer.cornerRadius = 5
        sender.clipsToBounds = true

        sender.imageView?.layer.cornerRadius = 5
        sender.imageView?.clipsToBounds = true
        
        sender.setBackgroundColor(color: UIColor(hexString: "#126363"), forState: .highlighted)

        sender.setTitleColor(.white, for: .highlighted)
        sender.tintColor = UIColor(hexString: "#126363")
                
    }
    
    @IBAction func btnShareTapTouchIn(_ sender: UIButton)
    {
        
        sender.setBackgroundColor(color: .clear, forState: .highlighted)

        sender.layer.cornerRadius = 18
        sender.clipsToBounds = true

        sender.imageView?.layer.cornerRadius = 16
        sender.imageView?.clipsToBounds = true

        sender.setBackgroundColor(color: UIColor(hexString: "#0C81C0"), forState: .highlighted)

        sender.setTitleColor(.white, for: .highlighted)
        sender.tintColor = UIColor(hexString: "#0C81C0")
                
    }
    
    @IBAction func btnCancelTapTouchIn(_ sender: UIButton)
    {
        
        sender.setBackgroundColor(color: .clear, forState: .highlighted)

        sender.layer.cornerRadius = 5
        sender.clipsToBounds = true

        sender.imageView?.layer.cornerRadius = 5
        sender.imageView?.clipsToBounds = true

        sender.setBackgroundColor(color: UIColor(cgColor: sender.layer.borderColor!) , forState: .highlighted)

        sender.setTitleColor(.white, for: .highlighted)
        sender.tintColor = UIColor(cgColor: sender.layer.borderColor!)
                
    }
    
    func updateAssignmentInfo()
    {
        lblDriverName.text = vModel?.driverName()
        
        if vModel?.vehicleNumber() == "" || vModel?.bookingStatii() == BookingStatus.CANCELLED.rawValue {
            lblVehicleNumber.text = "----"
        } else {
            lblVehicleNumber.text = vModel?.vehicleNumber()
        }
        
        starView.addLeading(image: #imageLiteral(resourceName: "star_ico"), text: String(format: "%.1f", vModel?.driverRating() as! CVarArg), imageOffsetY: 0)
        starView.textAlignment = Device.getLanguage().contains("AR") ? .left : .right
        bottomStartRatingLabel.addLeading(image: #imageLiteral(resourceName: "star_ico"), text: String(format: "%.1f", vModel?.driverRating() as! CVarArg), imageOffsetY: 0)
        bottomStartRatingLabel.textAlignment = .natural
        imgNumberPlate.image = vModel?.imgForPlate()
    }
    func hideDriverInfoBox()
    {
//        preRideDriver.isHidden = true
        //self.mapToPickupCardView_Bottom.priority = UILayoutPriority(rawValue: 1000)
//        constraintTripInfoMarginTop.constant = 10
    }

    func showDriverInfoBox()
    {
//        preRideDriver.isHidden = false
    }
    
    func updateEta(eta: String)
    {
//        self.eta.setTitle(eta, for: .normal)
    }
    func hideEtaView()
    {
//        btnETA.isHidden = true
//        constraintHeaderWidth.constant = UIScreen.main.bounds.width - 40
    }
    func showEtaView()
    {
//        btnETA.isHidden = false
//        constraintHeaderWidth.constant = 250
    }
    
    func updateBookingStatusOnCard(_ withAnimation: Bool)
    {
        
    }
    
    func showShareBtn()
    {
        btnShare.isHidden = false
    }
    
    func showCancelBtn()
    {
        btnCancel.isHidden = false
    }
    
    func hideCancelBtn()
    {
        btnCancel.isHidden = true
    }

    func hideShareBtn()
    {
        btnShare.isHidden = true
    }
    
    func updateHeaderMsg(_ msg : String)
    {
        rideHeaderText.text = msg
    }
    
    func showOTP() -> Bool{
//        if (vModel?.getBookingOtp() != nil && ((vModel?.getBookingOtp()?.count ?? 0) > 0)) {
//            self.otpLabel.text = vModel?.getBookingOtp() ?? ""
//            self.otpView.isHidden = false
//            return true
//        } else {
//            self.otpView.isHidden = true
//            return false
//        }
        
        return false
    }
    
    fileprivate func hideSeperatorBeforeReportAnIssue() {
//        seperatorBeforeReportAnIssue.isHidden = true
    }
    
    
    
    func updateBookingBottomSheet()
    {
        self.sheet?.handleScrollView(self.scrollView)
//        self.scrollView.isScrollEnabled = false
        KTPaymentManager().fetchPaymentsFromServer{(status, response) in}

        
        //MARK:- ON CALL BOOKING
        if(vModel?.bookingStatii() == BookingStatus.CONFIRMED.rawValue)
        {
            self.view.backgroundColor = UIColor.clear
            showEtaView()
            showCancelBtn()
            hideShareBtn()
            showPhoneButton()
            hideBtnComplain()
            hideRebookBtn()
            hideFareDetailBtn()
            starView.isHidden = true
            bottomStartRatingLabel.isHidden = false
//            bookingTime.isHidden = false
            hideSeperatorBeforeReportAnIssue()
            
            showDriverInfoBox()
//            self.shimmerView.isHidden = true
//            self.lblDriverName.stopShimmeringAnimation()
//            self.bottomStartRatingLabel.stopShimmeringAnimation()
            
           
//                constraintRebookMarginTop.constant = 375
            hideBtnComplain()
                        
            self.view.customCornerRadius = 20.0
            
            DispatchQueue.main.async {
                self.heightOFScrollViewContent.constant = 500
                self.sheet?.setSizes([.percent(0.45),.intrinsic], animated: true)
            }
            
        }

        //MARK:- PICKUP BOOKING (Customer on-board)
        if(vModel?.bookingStatii() == BookingStatus.PICKUP.rawValue)
        {
            hideEtaView()
            hideCancelBtn()
            showShareBtn()
            showPhoneButton()
            hideBtnComplain()
            hideRebookBtn()
            hideFareDetailBtn()
            starView.isHidden = true
            bottomStartRatingLabel.isHidden = false
            hideSeperatorBeforeReportAnIssue()
            
            self.view.customCornerRadius = 20.0
                       
            if oneTimeSetSizeForBottomSheet == false {
                DispatchQueue.main.async {
//                    if self.vModel?.getBookingOtp() != nil {
//                        self.constraintViewRideActionsTop.constant = 328
//                    } else {
//                        self.constraintViewRideActionsTop.constant = 323
//                    }
                    self.heightOFScrollViewContent.constant = 600
                    
                    if UIScreen.main.bounds.height < 800 {
                        self.sheet?.setSizes([.percent(0.45),.marginFromTop(150)], animated: true)
                    } else {
                        self.sheet?.setSizes([.percent(0.45),.intrinsic], animated: true)
                    }
                    
                    self.oneTimeSetSizeForBottomSheet = true
                }
            }
                        
        }
        
        //MARK:- COMPLETED BOOKING
        if(vModel?.bookingStatii() == BookingStatus.COMPLETED.rawValue)
        {
            hideEtaView()
            hideCancelBtn()
            hideShareBtn()
            hidePhoneButton()
            showBtnComplain()
            showRebookBtn()
            showFareDetailBtn()
            setUpfareBreakDownView()

            let totalDetailsCount = (vModel?.fareDetailsHeader()?.count ?? 0) + (vModel?.fareDetailsBody()?.count ?? 0) + 3

            starView.isHidden = false
            bottomStartRatingLabel.isHidden = true
            
            self.view.customCornerRadius = 0
            
            DispatchQueue.main.async {
                self.heightOFScrollViewContent.constant = 575
                self.sheet?.setSizes([.percent(0.45),.marginFromTop(200)], animated: true)
            }
            
        }
        
        //MARK:- SHECULED BOOKING
        if(vModel?.bookingStatii() == BookingStatus.PENDING.rawValue)
        {
            hideEtaView()
            showCancelBtn()
            hideShareBtn()
            hidePhoneButton()
            hideBtnComplain()
            hideRebookBtn()
            hideFareDetailBtn()
//            constraintVehicleInfoMarginTop.constant = 140
            hideSeperatorBeforeReportAnIssue()
//            self.otpView.isHidden = true
            DispatchQueue.main.async {
//                self.constraintViewRideActionsTop.constant = 220
                self.heightOFScrollViewContent.constant = 500
                self.sheet?.setSizes([.percent(0.45),.intrinsic], animated: true)
            }
            
        }

        //MARK:- CANCELLED BOOKING
        if(vModel?.bookingStatii() == BookingStatus.CANCELLED.rawValue)
        {
            hideEtaView()
            hideCancelBtn()
            hideShareBtn()
            hidePhoneButton()
            rideHeaderText.textColor = UIColor(hexString:"#E43825")
            showRebookBtn()
            hideFareDetailBtn()
            hideSeperatorBeforeReportAnIssue()
            starView.isHidden = false
            bottomStartRatingLabel.isHidden = true
            DispatchQueue.main.async {
                    self.heightOFScrollViewContent.constant = 500
//                    self.sheet?.setSizes([.percent(0.45),.intrinsic], animated: true)
                self.sheet?.setSizes([.percent(0.45), .intrinsic], animated: true)
                }
                hideBtnComplain()
            
            self.view.customCornerRadius = 0
                        
        }
        
        //MARK:- NO RIDE FOUND BOOKING
        if(vModel?.bookingStatii() == BookingStatus.TAXI_NOT_FOUND.rawValue || vModel?.bookingStatii() == BookingStatus.NO_TAXI_ACCEPTED.rawValue)
        {
            hideEtaView()
            hideCancelBtn()
            hideShareBtn()
            hidePhoneButton()
            rideHeaderText.textColor = UIColor(hexString:"#E43825")
            hideBtnComplain()
            showRebookBtn()
            hideFareDetailBtn()
            DispatchQueue.main.async {
                self.heightOFScrollViewContent.constant = 500
                self.sheet?.setSizes([.percent(0.45),.intrinsic], animated: true)
            }
            hideSeperatorBeforeReportAnIssue()
            self.view.customCornerRadius = 0

        }
        
        //MARK:- ARRIVED BOOKING
        if(vModel?.bookingStatii() == BookingStatus.ARRIVED.rawValue) {
            starView.isHidden = true
            
            bottomStartRatingLabel.isHidden = false
            hideSeperatorBeforeReportAnIssue()
            
            DispatchQueue.main.async {
                self.heightOFScrollViewContent.constant = 650
                self.sheet?.setSizes([.percent(0.45),.intrinsic], animated: true)
            }
            
            hideFareDetailBtn()
            hideBtnComplain()
            hideRebookBtn()
            self.view.customCornerRadius = 20.0
            showDriverInfoBox()
            self.lblDriverName.stopShimmeringAnimation()
            self.bottomStartRatingLabel.stopShimmeringAnimation()

        }

        updateAssignmentInfo()
    }
    
    func updateVehicleDetails()
    {
//        iconVehicle.image = vModel?.imgForVehicle()
//        lblVehicleType.text = vModel?.vehicleType()
        lblPassengerCount.text = vModel?.getPassengerCountr()
    }

    func shareBtnTapped()
    {
        let URLstring =  String(format: Constants.ShareTripUrl + (vModel?.booking?.trackId ?? "unknown"))
        let urlToShare = URL(string:URLstring)
        let title = "Follow the link to track my ride: \n"
        let activityViewController = UIActivityViewController(activityItems: [title,urlToShare!], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        present(activityViewController,animated: true,completion: nil)
    }
    
            //MARK:- FARE DETAILS BREAKDOWN VIEW
    fileprivate func setUpfareBreakDownView() {
        setHeaderFooter("txt_fare_info_Upper_Case".localized(), value: "")
        
        for i in 0 ..< (vModel?.fareDetailsHeader()?.count ?? 0) {
            setFarDetails(fareDetail: vModel?.fareDetailsHeader()?[i] ?? KTKeyValue())
        }
        
        for i in 0 ..< (vModel?.fareDetailsBody()?.count ?? 0) {
            setFarDetails(fareDetail: vModel?.fareDetailsBody()?[i] ?? KTKeyValue())
        }
        
//        let seperatorView = UIView()
//        seperatorView.translatesAutoresizingMaskIntoConstraints = false
//        seperatorView.heightAnchor.constraint(equalToConstant: 0.6).isActive = true
//        seperatorView.backgroundColor = UIColor(hexString: "#89B4BC")
//
//        fareBreakDownView.addArrangedSubview(seperatorView)
        
        setHeaderFooter("str_cash".localized(), value: vModel?.totalFareOfTrip() ?? "")
        
//        self.view.addSubview(fareBreakDownView)
        fareBreakDownView.backgroundColor = UIColor.clear
                
        let totalDetailsCount = (vModel?.fareDetailsHeader()?.count ?? 0) + (vModel?.fareDetailsBody()?.count ?? 0) + 2
        
//        [fareBreakDownView.topAnchor.constraint(equalTo: self.lblPassengerCount.bottomAnchor, constant: 35),
//         fareBreakDownView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
//         fareBreakDownView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
//         fareBreakDownView.heightAnchor.constraint(equalToConstant: CGFloat(Double(totalDetailsCount) * 25.5))].forEach{$0.isActive = true}
    }
    
    fileprivate func setFarDetails(fareDetail: KTKeyValue) {
        
        print("Device.language() -> ", Device.language())
        
        let keyLbl = UILabel()
        keyLbl.translatesAutoresizingMaskIntoConstraints = false
        keyLbl.heightAnchor.constraint(equalToConstant: 15).isActive = true
        keyLbl.text = fareDetail.key ?? ""
        keyLbl.textAlignment = .right
        keyLbl.textColor = UIColor(hexString: "#006170")
        keyLbl.font = UIFont(name: "MuseoSans-500", size: 14.0)!
        
        let valueLbl = UILabel()
        valueLbl.translatesAutoresizingMaskIntoConstraints = false
        valueLbl.heightAnchor.constraint(equalToConstant: 15).isActive = true
        valueLbl.text = fareDetail.value ?? ""
        
        if Device.language().contains("ar") {
            valueLbl.textAlignment = .left
            keyLbl.textAlignment = .right
        } else {
            keyLbl.textAlignment = .left
            valueLbl.textAlignment = .right
        }
        
        valueLbl.textColor = UIColor(hexString: "#006170")
        valueLbl.font = UIFont(name: "MuseoSans-500", size: 14.0)!

        let stackView = UIStackView(arrangedSubviews: [keyLbl, valueLbl])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        fareBreakDownView.addArrangedSubview(stackView)
    }
    
    fileprivate func setHeaderFooter(_ key: String, value: String) {
        let keyLbl = LocalisableLabel()
        keyLbl.translatesAutoresizingMaskIntoConstraints = false
        keyLbl.heightAnchor.constraint(equalToConstant: 15).isActive = true
        
        let valueLbl = LocalisableLabel()

        if value != "" {
            var iconImage = UIImage()
            iconImage = UIImage(named: ImageUtil.getSmallImage(vModel?.paymentMethodIcon() ?? "")) ?? UIImage()
            keyLbl.addLeading(image: iconImage, text: "  \(String(describing: vModel?.paymentMethod() ?? "")) ", imageOffsetY: -4)
            keyLbl.font = UIFont(name: "MuseoSans-900", size: 14.0)!
        }
        else {
            keyLbl.font = UIFont(name: "MuseoSans-700", size: 14.0)!
            keyLbl.text = key
        }
        
        keyLbl.textColor = value == "" ? UIColor(hexString: "#89B4BC") : UIColor(hexString: "#095A86")
        
        valueLbl.translatesAutoresizingMaskIntoConstraints = false
        valueLbl.heightAnchor.constraint(equalToConstant: 15).isActive = true
        valueLbl.text = value
        valueLbl.font = UIFont(name: "MuseoSans-900", size: 14.0)!
        valueLbl.textColor = value == "" ? UIColor(hexString: "#89B4BC") : UIColor(hexString: "#095A86")
        
        if Device.language().contains("ar") {
            valueLbl.textAlignment = .left
            keyLbl.textAlignment = .right
        } else {
            keyLbl.textAlignment = .left
            valueLbl.textAlignment = .right
        }
        
        let stackView = UIStackView(arrangedSubviews: [keyLbl, valueLbl])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        
        fareBreakDownView.addArrangedSubview(stackView)
        
    }
    
}



