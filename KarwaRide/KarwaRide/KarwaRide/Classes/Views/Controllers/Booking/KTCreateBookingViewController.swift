//
//  KTCreateBookingViewController.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 1/16/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

class KTCreateBookingViewController: KTBaseCreateBookingController, KTCreateBookingViewModelDelegate,KTFareViewDelegate {
    
    var vModel : KTCreateBookingViewModel?
    
    @IBOutlet weak var etaToCustomerLabel: UILabel!
    
    @IBOutlet weak var etaToCustomerContainer: UIImageView!
    
    var removeBookingOnReset : Bool = true
    
    //MARK:- View lifecycle
    override func viewDidLoad() {
        viewModel = KTCreateBookingViewModel(del:self)
        vModel = viewModel as? KTCreateBookingViewModel
        if booking != nil {
            vModel?.booking = booking!
            (viewModel as! KTCreateBookingViewModel).setRemoveBookingOnReset(removeBookingOnReset: removeBookingOnReset)
        }
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        addMap()
        
        self.navigationItem.hidesBackButton = true;
        self.btnRevealBtn.addTarget(self, action: #selector(SSASideMenu.presentLeftMenuViewController), for: .touchUpInside)
        
        hideFareBreakdown(animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    func showCoachmarkIfRequired()
    {
        let isCoachmarksShown = SharedPrefUtil.getSharePref(SharedPrefUtil.IS_COACHMARKS_SHOWN)
        
        if(isCoachmarksShown.isEmpty || isCoachmarksShown.count == 0)
        {
            if(vModel?.isCoachmarkOneShown)!
            {
                showCoachmarkTwo()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //TODO: If no pick uplocation
        if (viewModel as! KTCreateBookingViewModel).vehicleTypeShouldAnimate() {
            self.carousel!.scrollToItem(at: IndexPath(row: (viewModel as! KTCreateBookingViewModel).maxCarouselIdx(), section: 0), at: UICollectionViewScrollPosition.right, animated: false)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){
                self.carousel!.scrollToItem(at: IndexPath(row: (self.viewModel as! KTCreateBookingViewModel).idxToSelectVehicleType(), section: 0), at: UICollectionViewScrollPosition.right, animated: true)
            }
        }
    }
    
    func showCoachmarkOne()
    {
        self.performSegue(name: "SagueCoachmark1")
    }
    
    func showCoachmarkTwo()
    {
        self.performSegue(name: "SagueCoachmark2")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if timer != nil {
            timer.invalidate()
        }
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    //MARK:- User Actions
    @IBAction func btnPickupAddTapped(_ sender: Any) {
        
        (viewModel as! KTCreateBookingViewModel).btnPickupAddTapped()
    }
    @IBAction func btnDropAddTapped(_ sender: Any) {
        
        (viewModel as! KTCreateBookingViewModel).btnDropAddTapped()
    }
    
    @IBAction func btnRequestBooking(_ sender: Any) {
        
        (viewModel as! KTCreateBookingViewModel).btnRequestBookingTapped()
    }
    
    @IBAction func btnPickDateTapped(_ sender: Any) {
        
        let currentDate = Date()
        var dateComponents = DateComponents()
        dateComponents.month = 3
        let threeMonth = Calendar.current.date(byAdding: dateComponents, to: currentDate)
        
        let datePicker = DatePickerDialog(textColor: UIColor(hexString: "4A4A4A"),
                                          buttonColor: UIColor(hexString: "129793"),
                                          font: UIFont(name: "MuseoSans-500", size: 18.0)!,
                                          showCancelButton: true)
        datePicker.show("Set Pickup Time",
                        doneButtonTitle: "Done",
                        cancelButtonTitle: "Cancel", defaultDate: (viewModel as! KTCreateBookingViewModel).selectedPickupDateTime,
                        minimumDate: currentDate,
                        maximumDate: threeMonth,
                        datePickerMode: .dateAndTime) { (date) in
                            if let dt = date {
                                (self.viewModel as! KTCreateBookingViewModel).setPickupDateForAdvJob(date: dt)
                            }
        }
    }
    
    @IBAction func btnCancelBtnTapped(_ sender: Any)
    {
        (viewModel as! KTCreateBookingViewModel).resetInProgressBooking()
    }
    
    //MARK: - Book Ride
    func bookRide()  {
        (viewModel as! KTCreateBookingViewModel).bookRide()
    }
    
    func showBookingConfirmation() {
        
        let confirmationPopup = storyboard?.instantiateViewController(withIdentifier: "ConfermationPopupVC") as! BookingConfermationPopupVC
        confirmationPopup.previousView = self
        confirmationPopup.view.frame = self.view.bounds
        view.addSubview(confirmationPopup.view)
        addChildViewController(confirmationPopup)
    }
    
    func showCallerIdPopUp() {
        let callerIDPopup = storyboard?.instantiateViewController(withIdentifier: "callerIDPopupVC") as! KTCallerIDPopup
        callerIDPopup.previousView = self
        callerIDPopup.view.frame = self.view.bounds
        view.addSubview(callerIDPopup.view)
        addChildViewController(callerIDPopup)
    }
    
    // MARK : - UI Update
    func showCancelBookingBtn() {
        btnCancelBtn.isHidden = false
        btnRevealBtn.isHidden = true
    }
    
    func hideCancelBookingBtn()  {
        btnCancelBtn.isHidden = true
        btnRevealBtn.isHidden = false
    }
    
    func hideRequestBookingBtn() {
        
        constraintBtnRequestBookingHeight.constant = 0
        constraintBtnRequestBookingBottomSpace.constant = 0
        constraintBoxBtnRequestBookingSpace.constant = 0
        btnRequestBooking.isHidden = true
        
        //self.btnRequestBooking.setNeedsDisplay()
        self.view.layoutIfNeeded()
    }
    
    func showRequestBookingBtn()  {
        constraintBtnRequestBookingHeight.constant = 60
        constraintBtnRequestBookingBottomSpace.constant = 20
        constraintBoxBtnRequestBookingSpace.constant = 20
        btnRequestBooking.isHidden = false
        
        self.btnRequestBooking.setNeedsDisplay()
        self.view.layoutIfNeeded()
    }
    
    func setRemoveBookingOnReset(removeBookingOnReset : Bool)
    {
        self.removeBookingOnReset = removeBookingOnReset
    }
    
    func pickDropBoxStep3() {
        constraintBoxHeight.constant = 144
        constraintBoxBGImageHeight.constant = 144
        constraintBoxItemsTopSpace.constant = 24
        imgPickDestBoxBG.image = UIImage(named: "BookingPickDropTimeBox")
        btnCash.isHidden = false
        btnPickDate.isHidden = false
    }
    
    func pickDropBoxStep1() {
        constraintBoxHeight.constant = 130
        constraintBoxBGImageHeight.constant = 130
        constraintBoxItemsTopSpace.constant = 30
        imgPickDestBoxBG.image = UIImage(named: "BookingPickDropBox")
        btnCash.isHidden = true
        btnPickDate.isHidden = true
    }
    
    func setETAContainerBackground(background: String)
    {
        etaToCustomerContainer.image = UIImage(named: background)
    }

    func setETAString(etaString: String)
    {
        etaToCustomerLabel.text = etaString
    }
    
    //MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueBookingToAddresspickerForDropoff"  || segue.identifier == "segueBookingToAddresspickerForPickup"{
            
            let destination : KTAddressPickerViewController = segue.destination as! KTAddressPickerViewController
            (viewModel as! KTCreateBookingViewModel).prepareToMoveAddressPicker()
            
            destination.pickupAddress = (viewModel as! KTCreateBookingViewModel).pickUpAddress()
            destination.dropoffAddress = (viewModel as! KTCreateBookingViewModel).dropOffAddress()
            destination.previousView = (viewModel as! KTCreateBookingViewModel)
            
            if segue.identifier == "segueBookingToAddresspickerForDropoff" {
                
                destination.selectedTxtField = SelectedTextField.DropoffAddress
            }
            else {
                destination.selectedTxtField = SelectedTextField.PickupAddress
            }
        }
        else if segue.identifier == "segueBookingToBreakdown" {
            
            fareBreakdown = segue.destination as! KTFareViewController
        }
        else if segue.identifier == "segueBookToDetail" {
            let destination : KTBookingDetailsViewController = segue.destination as! KTBookingDetailsViewController
            destination.setBooking(booking: (viewModel as! KTCreateBookingViewModel).booking)
            
        }
        else if segue.identifier == "SagueCoachmark1"
        {
            //TODO: Make Delegate here
        }
        else if segue.identifier == "segueBookingListForDetails" {
            
            // Create a variable that you want to send
//            var newProgramVar = ""
            
            // Create a new variable to store the instance of PlayerTableViewController
            let destinationVC = segue.destination as! KTMyTripsViewController
            destinationVC.setBooking(booking: (viewModel as! KTCreateBookingViewModel).booking)
        }
    }
    func moveToDetailView() {
        
        self.performSegue(withIdentifier: "segueBookingListForDetails", sender: self)
    }
    
    //MARK:- Locations
    func showAlertForLocationServerOn() {
        
        let alertController = UIAlertController(title: NSLocalizedString("", comment: ""), message: NSLocalizedString("Location services are disabled. Please enable location services.", comment: ""), preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        let settingsAction = UIAlertAction(title: NSLocalizedString("Settings", comment: ""), style: .default) { (UIAlertAction) in
            
            UIApplication.shared.open(NSURL(string: UIApplicationOpenSettingsURLString)! as URL, options: [:], completionHandler: nil)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
/*func updateCurrentAddress(addressName: String) {
        
        btnPickupAddress.setTitle(addressName, for: UIControlState.normal)
    }*/
    
    // MARK: - View Model Delegate
    func hintForPickup() -> String {
        return pickupHint
    }
    
    func callerPhoneNumber() -> String? {
        return callerId
    }
    
    func setPickUp(pick: String?) {
        
        guard pick != nil else {
            return
        }
        self.btnPickupAddress.setTitle(pick, for: UIControlState.normal)
    }
    
    func setDropOff(drop: String?) {
        
        guard drop != nil else {
            return
        }
        
        self.btnDropoffAddress.setTitle(drop, for: UIControlState.normal)
        self.btnDropoffAddress.setTitleColor(UIColor(hexString:"#1799A6"), for: UIControlState.normal)
    }
    
    func setPickDate(date: String) {
        btnPickDate.setTitle(date, for: UIControlState.normal)
    }
    
    func hideFareBreakdown() {
        
        //        btnRevealBtn.constant = 0
        //        btnRevealBtn.constant = 0
        //        btnRevealBtn.constant = 0

        fareBreakdown.showHideBackFareDetailsBtn(hide: true)

        constraintFareToBox.constant = 0
        viewFareBreakdown.alpha = 0.0
        self.viewFareBreakdown.isHidden = true
        
        self.view.layoutIfNeeded()
    }
}
