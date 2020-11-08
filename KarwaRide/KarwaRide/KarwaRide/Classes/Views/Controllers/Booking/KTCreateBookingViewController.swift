//
//  KTCreateBookingViewController.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 1/16/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
import Spring
import Crashlytics

class DashboardAddressCell: UICollectionViewCell {
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var icon: UIImageView!
  
  var destination: KTGeoLocation? {
    didSet {
      if let destination = destination {
        switch destination.type {
        case geoLocationType.Home.rawValue:
          titleLabel.text = "Home"
          icon.image = UIImage(named: "ic_home_pickup")
        case geoLocationType.Work.rawValue:
          titleLabel.text = "Work"
          icon.image = UIImage(named: "icon_work")
        case geoLocationType.Recent.rawValue:
          titleLabel.text = destination.name
          icon.image = UIImage(named: "icon_recent_new")
        default:
          titleLabel.text = destination.name
          icon.image = UIImage(named: "ic_home_pickup")
        }
        addressLabel.text = destination.name
      }
    }
  }
  override class func awakeFromNib() {
    super.awakeFromNib()
  }
}

extension KTCreateBookingViewController: UICollectionViewDataSource, UICollectionViewDelegate {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return (viewModel as! KTCreateBookingViewModel).destinations.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "homeAddressCell", for: indexPath) as! DashboardAddressCell
    cell.destination = (viewModel as! KTCreateBookingViewModel).destinations[indexPath.item]
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let destination = (viewModel as! KTCreateBookingViewModel).destinations[indexPath.item]
    (viewModel as! KTCreateBookingViewModel).setDropAddress(dAddress: destination)
  }
  
  func reloadDestinations() {
    DispatchQueue.main.async {
      self.collectionView.reloadData()
    }
  }
  
}
class KTCreateBookingViewController:
KTBaseCreateBookingController, KTCreateBookingViewModelDelegate,KTFareViewDelegate {
  func allowScrollVTypeCard(allow: Bool) {
    
  }
  
  
  var vModel : KTCreateBookingViewModel?
  
  @IBOutlet weak var pickupPin: KTAddressPin!
  @IBOutlet weak var pickupCardView: UIView!
  @IBOutlet weak var destinationView: UIView!
  @IBOutlet weak var collectionView: UICollectionView!
  
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
    pickupCardView.topTwoRoundedCorners()
    pickupCardView.applyShadow()
    destinationView.layer.cornerRadius = 30.0
    destinationView.applyShadow()
    btnPickupAddress.titleLabel?.lineBreakMode = .byWordWrapping
    btnPickupAddress.titleLabel?.numberOfLines = 2
    collectionView.dataSource = self
    collectionView.delegate = self
    (viewModel as! KTCreateBookingViewModel).fetchDestinations()
  }
  func showScanPayCoachmark() {
    
  }
  
  override func viewWillAppear(_ animated: Bool)
  {
    super.viewWillAppear(animated)
    navigationController?.isNavigationBarHidden = true
  }
  
  func showCoachmarkIfRequired()
  {
    if(SharedPrefUtil.isBookingCoachmarkOneShown())
    {
      if(vModel?.isCoachmarkOneShown)!
      {
        showCoachmarkTwo()
      }
    }
  }
  
  @IBAction func scanPayBannerCrossTapped(_ sender: Any) {
    SharedPrefUtil.setScanNPayCoachmarkShown()
  }
  
  @IBAction func scanPayBannerTapped(_ sender: Any) {
    SharedPrefUtil.setScanNPayCoachmarkShown()
  }
  
  @IBAction func currentLocationButtonAction(_ sender: Any) {
    (viewModel as! KTCreateBookingViewModel).setupCurrentLocaiton()
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
//    btnDropoffAddress.animation = "pop"
//    btnDropoffAddress.duration = 1.5
//    btnDropoffAddress.animate()
  }
  @IBAction func btnDropAddTapped(_ sender: Any) {
    
    (viewModel as! KTCreateBookingViewModel).btnDropAddTapped()
  }
  
  
  @IBAction func btnRequestBookingTouchDown(_ sender: SpringButton)
  {
    springAnimateButtonTapIn(button: btnRequestBooking)
  }
  
  @IBAction func btnRequestBookingTouchUpOutside(_ sender: SpringButton)
  {
    springAnimateButtonTapOut(button: btnRequestBooking)
  }
  
  
  @IBAction func btnRequestBooking(_ sender: Any)
  {
    springAnimateButtonTapOut(button: btnRequestBooking)
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
  
  @IBAction func btnPromoTapped(_ sender: Any)
  {
    (viewModel as! KTCreateBookingViewModel).btnPromoTapped()
  }
  
  @IBAction func btnCashTapped(_ sender: Any)
  {
    showError(title: "Payment Methods", message: "More payment options will be available soon")
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
  
  // TODO: Promo Impl
  // ----------------------------------------------------
  func showPromoInputDialog(currentPromo : String)
  {
    let promoPopup = storyboard?.instantiateViewController(withIdentifier: "PromoCodePopupVC") as! PromoCodePopupVC
    promoPopup.previousView = self
    promoPopup.previousPromo = currentPromo
    promoPopup.view.frame = self.view.bounds
    view.addSubview(promoPopup.view)
    addChildViewController(promoPopup)
  }
  
  func applyPromoTapped(_ enteredPromo: String)
  {
    (viewModel as! KTCreateBookingViewModel).applyPromoTapped(enteredPromo)
  }
  
  func removePromoTapped()
  {
    if(promoCode.length > 0)
    {
      promoCode = ""
      setPromoButtonLabel(validPromo: promoCode)
      (viewModel as! KTCreateBookingViewModel).removePromoTapped()
    }
  }
  
  func setPromoButtonLabel(validPromo promo : String)
  {
    //btnPromo.setTitle(promo.length > 0 ? promo : "+ Promo", for: .normal)
  }
  
  func setPromotionCode(promo promoEntered: String)
  {
    promoCode = promoEntered
  }
  // ----------------------------------------------------
  
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
    //self.btnRequestBooking.setNeedsDisplay()
    
    //        self.btnRequestBooking.animation = "slideDown"
    //        self.btnRequestBooking.curve = "easeOut"
    //        self.btnRequestBooking.duration = 1
    //        self.btnRequestBooking.animate()
    
    UIView.animate(withDuration: 0.5, animations: {
      
      self.btnRequestBooking.isHidden = true
      self.view.layoutIfNeeded()
    })
  }
  
  func showRequestBookingBtn()  {
    
    self.btnRequestBooking.animation = "slideUp"
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 1)
    {
      UIView.animate(withDuration: 0.5, animations: {
        
        self.btnRequestBooking.setNeedsDisplay()
        self.view.layoutIfNeeded()
      })
    }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 1)
    {
      self.btnRequestBooking.isHidden = false
      self.btnRequestBooking.animate()
    }
  }
  
  func setRemoveBookingOnReset(removeBookingOnReset : Bool)
  {
    self.removeBookingOnReset = removeBookingOnReset
  }
  
  func pickDropBoxStep3() {
    
  }
  
  func pickDropBoxStep1() {
    
  }
  
  func setETAContainerBackground(background: String)
  {
  }
  
  func setETAString(etaString: String)
  {
    pickupPin.eta = etaString
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
      
      fareBreakdown = segue.destination as? KTFareViewController
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
    //btnPickDate.setTitle(date, for: UIControlState.normal)
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
