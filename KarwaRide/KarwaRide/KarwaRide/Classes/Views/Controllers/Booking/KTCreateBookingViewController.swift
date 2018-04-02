//
//  KTCreateBookingViewController.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 1/16/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

class KTCreateBookingViewController: KTBaseCreateBookingController, KTCreateBookingViewModelDelegate,KTFareViewDelegate {
    
    //MARK:- View lifecycle
    override func viewDidLoad() {
        viewModel = KTCreateBookingViewModel(del:self)
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addMap()
        
        self.navigationItem.hidesBackButton = true;
        
        self.btnRevealBtn.addTarget(self, action: #selector(SSASideMenu.presentLeftMenuViewController), for: .touchUpInside)
        
        hideFareBreakdown(animated: false)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
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
                                (self.viewModel as! KTCreateBookingViewModel).setPickupDate(date: dt)
                            }
        }
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
    
    
    
    // MARK : - UI Update
    func hideRequestBookingBtn() {
        
        constraintBtnRequestBookingHeight.constant = 0
        constraintBtnRequestBookingBottomSpace.constant = 0
        btnRequestBooking.isHidden = true
        
        self.btnRequestBooking.setNeedsDisplay()
        self.view.layoutIfNeeded()
    }
    
    func showRequestBookingBtn()  {
        constraintBtnRequestBookingHeight.constant = 60
        constraintBtnRequestBookingBottomSpace.constant = 20
        btnRequestBooking.isHidden = false
        
        self.btnRequestBooking.setNeedsDisplay()
        self.view.layoutIfNeeded()
    }
    
    func pickDropBoxStep2() {
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
    //MARK: - Detail
    
    //MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueBookingToAddresspickerForDropoff"  || segue.identifier == "segueBookingToAddresspickerForPickup"{
            
            let destination : KTAddressPickerViewController = segue.destination as! KTAddressPickerViewController
            (viewModel as! KTCreateBookingViewModel).prepareToMoveAddressPicker()
            
            if (viewModel as! KTCreateBookingViewModel).pickUpAddress != nil {
                
                destination.pickupAddress = (viewModel as! KTCreateBookingViewModel).pickUpAddress
            }
            if (viewModel as! KTCreateBookingViewModel).dropOffAddress != nil {
                
                destination.dropoffAddress = (viewModel as! KTCreateBookingViewModel).dropOffAddress
            }
        
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
    }
    func moveToDetailView() {
     
        self.performSegue(withIdentifier: "segueBookToDetail", sender: self)
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
    
    func updateCurrentAddress(addressName: String) {
        
        btnPickupAddress.setTitle(addressName, for: UIControlState.normal)
    }
    
    // MARK: - View Model Delegate
    func hintForPickup() -> String {
        return pickupHint
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
        self.btnDropoffAddress.setTitleColor(UIColor(hexString:"#006170"), for: UIControlState.normal)
    }
    
    func setPickDate(date: String) {
        btnPickDate.setTitle(date, for: UIControlState.normal)
    }
}
