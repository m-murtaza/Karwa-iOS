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
    
    @IBOutlet weak var eta: LocalisableButton!

    @IBOutlet weak var rideHeaderText: LocalisableSpringLabel!
    @IBOutlet weak var lblPickAddress: SpringLabel!
    @IBOutlet weak var lblDropoffAddress: SpringLabel!

    @IBOutlet weak var lblPickMessage: SpringLabel!
    @IBOutlet weak var bookingTime: UILabel!
    @IBOutlet weak var btnPhone: LocalisableButton!
    
    @IBOutlet weak var btnShare: LocalisableButton!
    @IBOutlet weak var lblVehicleNumber: UILabel!
    @IBOutlet weak var imgNumberPlate: UIImageView!
    
    @IBOutlet weak var lblDriverName: LocalisableSpringLabel!
    @IBOutlet weak var starView: SpringLabel!
    var sheetCoordinator: UBottomSheetCoordinator?

    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        sheetCoordinator?.startTracking(item: self)
        sheetCoordinator?.addDropShadowIfNotExist()
        (sheetCoordinator?.parent as! (KTBookingDetailsViewController)).setMapPadding()
    }

    @IBAction func cancelBtnTap(_ sender: Any) {
        self.vModel?.buttonTapped(withTag: BottomBarBtnTag.Cancel.rawValue)
    }
    
    @IBAction func shareBtnTap(_ sender: Any) {
        shareBtnTapped()
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
        
//        lblServiceType.text = vModel?.vehicleType()
        
//        if(vModel?.bookingStatii() == BookingStatus.COMPLETED.rawValue)
//        {
//            lblEstimatedFare.text = vModel?.totalFareOfTrip()
//            titleEstimatedFare.text = "Fare"
//        }
//        else
//        {
//            lblEstimatedFare.text = vModel?.estimatedFare()
//            titleEstimatedFare.text = "Est. Fare"
//        }
        
        updateBookingStatusOnCard(false)
        
//        lblPickTime.text = vModel?.pickupTime()
//        lblDropTime.text = vModel?.dropoffTime()
//
//        viewCard.backgroundColor = vModel?.cellBGColor()
//
//        viewCard.borderColor = vModel?.cellBorderColor()
//
//        lblPaymentMethod.text = vModel?.paymentMethod()
//        imgPaymentMethod.image = UIImage(named: ImageUtil.getSmallImage((vModel?.paymentMethodIcon())!))
    }

    func hidePhoneButton()
    {
        btnPhone.isHidden = true
    }

    func updateBookingCardForCompletedBooking()
    {
        eta.isHidden = true
        btnPhone.isHidden = true
    }
    func updateBookingCardForUnCompletedBooking()
    {
        bookingTime.isHidden = true
    }
    
    func updateAssignmentInfo()
    {
        lblDriverName.text = vModel?.driverName()
        lblVehicleNumber.text = vModel?.vehicleNumber()
        starView.text = (vModel?.driverRating())?.toString()
        imgNumberPlate.image = vModel?.imgForPlate()
    }
    func hideDriverInfoBox()
    {
        preRideDriver.isHidden = true
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
        eta.isHidden = true
    }
    func showEtaView()
    {
        eta.isHidden = false
    }
    
    func updateBookingStatusOnCard(_ withAnimation: Bool)
    {
        
    }
    func showHideShareButton(_ show : Bool)
    {
        btnShare.isHidden = !show
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
}
