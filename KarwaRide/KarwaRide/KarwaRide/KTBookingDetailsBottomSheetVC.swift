//
//  KTBookingDetailsBottomSheetVC.swift
//  KarwaRide
//
//  Created by Sam Ash on 10/12/2020.
//  Copyright © 2020 Karwa. All rights reserved.
//

import Foundation
import UBottomSheet
import Spring

class KTBookingDetailsBottomSheetVC: UIViewController, Draggable
{
    var vModel : KTBookingDetailsViewModel?

    @IBOutlet weak var preRideDriver: UIView!
    @IBOutlet weak var viewTripInfo: UIView!
    @IBOutlet weak var viewRideInfo: UIView!

    @IBOutlet weak var viewRideActions: UIView!
    
    @IBOutlet weak var bottomSheetToolIcon: UIImageView!
    
    @IBOutlet weak var constraintPlateNo: NSLayoutConstraint!
    @IBOutlet weak var constraintHeaderWidth: NSLayoutConstraint!
    @IBOutlet weak var constraintReportIssueMarginTop: NSLayoutConstraint!
    @IBOutlet weak var constraintFareInfoMarginTop: LocalisableButton!
    
    
    
    @IBOutlet weak var eta: LocalisableButton!

    @IBOutlet weak var rideHeaderText: LocalisableSpringLabel!
    @IBOutlet weak var lblPickAddress: SpringLabel!
    @IBOutlet weak var lblDropoffAddress: SpringLabel!

    @IBOutlet weak var lblPickMessage: SpringLabel!
    @IBOutlet weak var bookingTime: UILabel!
    @IBOutlet weak var btnETA: LocalisableButton!
    
    @IBOutlet weak var btnShare: LocalisableButton!
    @IBOutlet weak var btnCancel: LocalisableButton!
    @IBOutlet weak var btnPhone: LocalisableSpringButton!
    @IBOutlet weak var btnReportIssue: LocalisableButton!
    @IBOutlet weak var btnRebook: LocalisableButton!
    @IBOutlet weak var btnFareInfo: LocalisableButton!
    
    
    
    @IBOutlet weak var iconVehicle: SpringImageView!
    @IBOutlet weak var lblVehicleType: LocalisableLabel!
    @IBOutlet weak var lblPassengerCount: LocalisableLabel!
    @IBOutlet weak var lblVehicleNumber: UILabel!
    @IBOutlet weak var imgNumberPlate: UIImageView!
    
    @IBOutlet weak var lblDriverName: LocalisableSpringLabel!
    @IBOutlet weak var starView: SpringLabel!
    var sheetCoordinator: UBottomSheetCoordinator?

    @IBOutlet weak var constraintTripInfoMarginTop: NSLayoutConstraint!

    lazy var fareBreakDownView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.distribution = .fillProportionally
        return view
    }()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        sheetCoordinator?.startTracking(item: self)
        sheetCoordinator?.addDropShadowIfNotExist()
        (sheetCoordinator?.parent as! (KTBookingDetailsViewController)).setMapPadding(height: 40)
        constraintPlateNo.constant = Device.language().contains("ar") ? 60 : 25
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
        lblPickAddress.text = vModel?.pickAddress()
        lblDropoffAddress.text = vModel?.dropAddress()
        let msg = vModel?.pickMessage()
        if (msg?.isEmpty)! {
            lblPickMessage.isHidden = true
        }
        else {
            lblPickMessage.text = vModel?.pickMessage()
        }
        
        bookingTime.text = (vModel?.pickupDayAndTime())! + (vModel?.pickupDateOfMonth())!  + (vModel?.pickupMonth())! + (vModel?.pickupYear())!

        updateVehicleDetails()
        
        updateBookingBottomSheet()

        updateBookingStatusOnCard(false)
    }

    func hideBtnComplain()
    {
        btnReportIssue.isHidden = true
    }
    
    func showBtnComplain()
    {
        btnReportIssue.isHidden = false
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
        btnFareInfo.isHidden = true
    }
    
    func showFareDetailBtn()
    {
        btnFareInfo.isHidden = false
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
        eta.isHidden = true
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
    
    
    @IBAction func btnRebookTap(_ sender: Any)
    {
        vModel?.buttonTapped(withTag: BottomBarBtnTag.Rebook.rawValue)
    }
    
    func updateAssignmentInfo()
    {
        lblDriverName.text = vModel?.driverName()
        lblVehicleNumber.text = vModel?.vehicleNumber()
        starView.text = String(format: "%.1f", vModel?.driverRating() as! CVarArg)
        imgNumberPlate.image = vModel?.imgForPlate()
    }
    func hideDriverInfoBox()
    {
        preRideDriver.isHidden = true
        //self.mapToPickupCardView_Bottom.priority = UILayoutPriority(rawValue: 1000)
        constraintTripInfoMarginTop.constant = 1
    }

    func showDriverInfoBox()
    {
        preRideDriver.isHidden = false
    }
    
    func updateEta(eta: String)
    {
        self.eta.setTitle(eta, for: .normal)
    }
    func hideEtaView()
    {
        btnETA.isHidden = true
        constraintHeaderWidth.constant = 420
    }
    func showEtaView()
    {
        btnETA.isHidden = false
        constraintHeaderWidth.constant = 250
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
    
    func updateBookingBottomSheet()
    {
        //MARK:- DISPATCHING
        if(vModel?.bookingStatii() == BookingStatus.DISPATCHING.rawValue)
        {
            hideEtaView()
            showCancelBtn()
            hideShareBtn()
            hidePhoneButton()
            hideRebookBtn()
            hideFareDetailBtn()
            hideBtnComplain()
        }
        
        //MARK:- ON CALL BOOKING
        if(vModel?.bookingStatii() == BookingStatus.CONFIRMED.rawValue)
        {
            showEtaView()
            showCancelBtn()
            showShareBtn()
            showPhoneButton()
            hideBtnComplain()
            hideRebookBtn()
            hideFareDetailBtn()
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
//            showFareDetailBtn()
            hideFareDetailBtn()
            constraintReportIssueMarginTop.constant = 250
            setUpfareBreakDownView()
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
        }

        //MARK:- CANCELLED BOOKING
        if(vModel?.bookingStatii() == BookingStatus.CANCELLED.rawValue)
        {
            hideEtaView()
            hideCancelBtn()
            hideShareBtn()
            hidePhoneButton()
            rideHeaderText.textColor = UIColor(hexString:"#E43825")
            showBtnComplain()
            showRebookBtn()
            hideFareDetailBtn()
            constraintReportIssueMarginTop.constant = 100
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
            constraintReportIssueMarginTop.constant = 100
        }
        
        updateAssignmentInfo()
    }
    
    func updateVehicleDetails()
    {
        iconVehicle.image = vModel?.imgForVehicle()
        lblVehicleType.text = vModel?.vehicleType()
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
    
    fileprivate func setUpfareBreakDownView() {
        setHeaderFooter("txt_fare_info_Upper_Case".localized(), value: "")
        
        for i in 0 ..< (vModel?.fareDetailsHeader()?.count ?? 0) {
            setFarDetails(fareDetail: vModel?.fareDetailsHeader()?[i] ?? KTKeyValue())
        }
        
        for i in 0 ..< (vModel?.fareDetailsBody()?.count ?? 0) {
            setFarDetails(fareDetail: vModel?.fareDetailsBody()?[i] ?? KTKeyValue())
        }
        
        let seperatorView = UIView()
        seperatorView.translatesAutoresizingMaskIntoConstraints = false
        seperatorView.heightAnchor.constraint(equalToConstant: 0.6).isActive = true
        seperatorView.backgroundColor = UIColor(hexString: "#89B4BC")
        
        fareBreakDownView.addArrangedSubview(seperatorView)
        
        setHeaderFooter("str_cash".localized(), value: vModel?.totalFareOfTrip() ?? "")
        
        self.view.addSubview(fareBreakDownView)
        
        [fareBreakDownView.topAnchor.constraint(equalTo: self.iconVehicle.bottomAnchor, constant: 35),
         fareBreakDownView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
         fareBreakDownView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
         fareBreakDownView.heightAnchor.constraint(equalToConstant: 150)].forEach{$0.isActive = true}
    }
    
    fileprivate func setFarDetails(fareDetail: KTKeyValue) {
        
        print("Device.language() -> ", Device.language())
        
        let keyLbl = UILabel()
        keyLbl.translatesAutoresizingMaskIntoConstraints = false
        keyLbl.heightAnchor.constraint(equalToConstant: 15).isActive = true
        keyLbl.text = fareDetail.key ?? ""
        keyLbl.textAlignment = .right
        keyLbl.textColor = UIColor(hexString: "#006170")
        keyLbl.font = UIFont(name: "MuseoSans-500", size: 11.0)!
        
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
        valueLbl.font = UIFont(name: "MuseoSans-500", size: 11.0)!

        let stackView = UIStackView(arrangedSubviews: [keyLbl, valueLbl])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        fareBreakDownView.addArrangedSubview(stackView)
    }
    
    fileprivate func setHeaderFooter(_ key: String, value: String) {
        let keyLbl = LocalisableLabel()
        keyLbl.translatesAutoresizingMaskIntoConstraints = false
        keyLbl.heightAnchor.constraint(equalToConstant: 15).isActive = true
        
        if value != "" {
            keyLbl.addLeading(image: UIImage(named: "icon-cash-new") ?? UIImage(), text: " \(key) ")
        }
        else {
            keyLbl.text = key
        }

        keyLbl.textColor = value == "" ? UIColor(hexString: "#89B4BC") : UIColor(hexString: "#095A86")
        keyLbl.font = UIFont(name: "MuseoSans-700", size: 12.0)!

        let valueLbl = LocalisableLabel()
        valueLbl.translatesAutoresizingMaskIntoConstraints = false
        valueLbl.heightAnchor.constraint(equalToConstant: 15).isActive = true
        valueLbl.text = value
        valueLbl.font = UIFont(name: "MuseoSans-700", size: 12.0)!
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

//icon-cash-new
