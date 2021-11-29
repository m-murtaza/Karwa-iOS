//
//  KTCreateBookingViewController.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 1/16/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
import Spring
import Lottie
//import UBottomSheet
import FittedSheets

public class PreviousSelectedPayment: NSObject {
    static let shared = PreviousSelectedPayment()
    var selectedPaymentMethod: String?
    var rebook: Bool? = false
    public override init() {
        
    }
}

class RideServiceCell: UITableViewCell {
  @IBOutlet weak var serviceName: UILabel!
  @IBOutlet weak var capacity: UILabel!
  @IBOutlet weak var fare: UILabel!
  @IBOutlet weak var time: UILabel!
  @IBOutlet weak var icon: SpringImageView!
  @IBOutlet weak var promoBadge: UIImageView!
  @IBOutlet weak var fareInfo: UILabel!
  @IBOutlet weak var iconBackgroundAnim: AnimationView!
  @IBOutlet weak var icArrow: SpringImageView!
    
  override func setHighlighted(_ highlighted: Bool, animated: Bool) {
//    contentView.backgroundColor = highlighted ? .white : .clear
//    contentView.layer.borderColor = highlighted ? UIColor.primary.cgColor : UIColor.clear.cgColor
//    contentView.layer.borderWidth = highlighted ? 1 : 0
//    contentView.layer.cornerRadius = highlighted ? 8 : 0
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    contentView.backgroundColor = selected ? .white : .clear
    contentView.layer.borderColor = selected ? UIColor.primary.cgColor : UIColor.clear.cgColor
    contentView.layer.borderWidth = selected ? 2 : 0
    contentView.layer.cornerRadius = selected ? 8 : 0
    serviceName.font = UIFont(name:selected ? "MuseoSans-900" : "MuseoSans-700", size: 16.0)
    fare.font = UIFont(name:selected ? "MuseoSans-900" : "MuseoSans-700", size: 16.0)
    if(selected && !animated)
    {
        icon.animation = (Locale.current.languageCode?.contains("ar"))! ? "slideLeft" : "slideRight"
        icon.animate()
    }
  }

  func setFare(fare: String) {
    let parts = fare.split(separator: "(")
    if parts.count > 1, var last = parts.last {
      last.removeLast()
      self.fareInfo.text = "(\(String(last)))"
      self.fareInfo.isHidden = false
      let startingFare = String(parts.first ?? "")
      let trimmedString = startingFare.trimmingCharacters(in: .whitespacesAndNewlines)
      self.fare.text = trimmedString
    }
    else {
      self.fare.text = fare
      self.fareInfo.text = ""
        self.fareInfo.isHidden = true
        
    }
  }
  
  override class func awakeFromNib() {
    super.awakeFromNib()
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    self.promoBadge.isHidden = true
    self.icArrow.image = UIImage(named: "ic_right_arrow")?.imageFlippedForRightToLeftLayoutDirection()
  }
}

class DashboardAddressCell: UICollectionViewCell {
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var bottomCardContainer: UIView!
    
  var destination: KTGeoLocation? {
    didSet {
      if let destination = destination {
        switch destination.type {
        case geoLocationType.Home.rawValue:
            titleLabel.text = "strHome".localized()
          icon.image = UIImage(named: "home_db_ico")
        case geoLocationType.Work.rawValue:
            titleLabel.text = "strWork".localized()
          icon.image = UIImage(named: "icon_work")
        case geoLocationType.Recent.rawValue:
          titleLabel.text = destination.name
          icon.image = UIImage(named: "icon_recent_new")
        default:
          titleLabel.text = destination.name
          icon.image = UIImage(named: "bottom_card_landmark_icon")
        }
        addressLabel.text = destination.name
      }
        bottomCardContainer.layer.cornerRadius = 15
        bottomCardContainer.addShadowBottomXpress()
      self.layer.masksToBounds = false
    }
  }
  override class func awakeFromNib() {
    super.awakeFromNib()
  }
}

extension KTCreateBookingViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return (viewModel as! KTCreateBookingViewModel).numberOfVehicleCategories()
    }
    
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "serviceCell", for: indexPath) as! RideServiceCell
    let viewModel = self.viewModel as! KTCreateBookingViewModel
    cell.promoBadge.isHidden = true
    var item = viewModel.getVehicleByCategory(catName: VehicleCategories.FIRST.rawValue).first
    if indexPath.section == 0 {
        item = viewModel.getVehicleByCategory(catName: VehicleCategories.FIRST.rawValue).first
    }
    else if indexPath.section == 1 {
        item = viewModel.getVehicleByCategory(catName: VehicleCategories.SECOND.rawValue).first
    }
    else {
        item = viewModel.getVehicleByCategory(catName: VehicleCategories.THIRD.rawValue).first
    }

    cell.serviceName.text = viewModel.getVehicleTitle(vehicleType: item!.typeId)
    let fare = viewModel.getTypeBaseFareOrEstimate(typeId: item!.typeId)
    cell.setFare(fare: fare)
    cell.capacity.text = viewModel.getTypeCapacity(typeId: item!.typeId)
    cell.time.text = viewModel.getTypeEta(typeId: item!.typeId)
    cell.icon.image = viewModel.getTypeVehicleImage(typeId: item!.typeId)
    let shouldHidePromoFare = !(viewModel.isPromoFare(typeId: item!.typeId))
    cell.promoBadge.isHidden = shouldHidePromoFare
    if(viewModel.isPremiumRide(typeId: item!.typeId)){
        cell.iconBackgroundAnim.isHidden = false
        cell.iconBackgroundAnim.backgroundColor = .clear
        cell.iconBackgroundAnim.loopMode = .loop
        cell.iconBackgroundAnim.play()
    }
    else
    {
        cell.iconBackgroundAnim.isHidden = true
    }
    
    cell.selectionStyle = .none
    return cell
  }
    
    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//    selectedIndex = indexPath.row
//    (viewModel as! KTCreateBookingViewModel).vehicleTypeTapped(idx: selectedIndex)
    selectedSection = indexPath.section
    self.setupVehicleDetailBottomSheet()
  }
  
//  func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
//      return true
//  }
  
  func restoreCustomerServiceSelection() {
    restoreCustomerServiceSelection(animateView: true)
  }
    
    func reloadRidesList()
    {
        tableView.reloadData()
    }

    func focusIndex(selectingRow: Int, animateView: Bool)
    {
        DispatchQueue.main.async {
          self.tableView.selectRow(at: IndexPath(row: selectingRow, section: 0),
                                   animated: !animateView,
                                   scrollPosition: .none)
        }
    }

    func restoreCustomerServiceSelection(animateView: Bool)
    {
        
//            guard selectedIndex < (viewModel as! KTCreateBookingViewModel).numberOfRowsVType() else {
//                return
//            }
//
//            print("Restoring index: \(selectedIndex)")
//
//            let indexPath = IndexPath(row: 0, section: 0)
//            DispatchQueue.main.async {
//                self.tableView.selectRow(at: indexPath,
//                                         animated: !animateView,
//                                         scrollPosition: .none)
//            }
                    
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
    (viewModel as! KTCreateBookingViewModel).destinationSelectedFromHomeScreen(location: destination)
  }
  
  func reloadDestinations() {
    DispatchQueue.main.async {
//      self.collectionView.reloadData()
        self.collectionView.performBatchUpdates({
                            let indexSet = IndexSet(integersIn: 0...0)
                            self.collectionView.reloadSections(indexSet)
                        }, completion: nil)
    }
  }
  
}
class KTCreateBookingViewController:
    KTBaseCreateBookingController, KTCreateBookingViewModelDelegate,KTFareViewDelegate {
    
    func reloadSelection() {
        self.tableView.reloadData()
    }
    

    func showScanPayCoachmark()
    {
        
    }

  func showCurrentLocationButton() {
    DispatchQueue.main.async {
      self.currentLocationButton.isHidden = false
    }
  }
  
  func moveRow(from: IndexPath, to: IndexPath) {
    self.tableView.moveRow(at: from, to: to)
  }
    
    func moveRowToFirst(fromIndex from: Int) {
        self.tableView.moveRow(at: IndexPath(row: from, section: 0), to: IndexPath(row: 0, section: 0))
        selectedIndex = 0
    }
  
  func allowScrollVTypeCard(allow: Bool) {
    
  }
  
  var vModel : KTCreateBookingViewModel?
  
  @IBOutlet weak var pickupPin: KTAddressPin!
  @IBOutlet weak var pickupCardView: UIView!
  @IBOutlet weak var destinationView: UIView!
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var pickupDropoffParentContainer: UIView!
  @IBOutlet weak var pickupDropoffContainer: UIView!
  @IBOutlet weak var promoAppliedContainer: UIView!
  @IBOutlet weak var pickupLabel: UILabel!
  @IBOutlet weak var ivPickup: UIImageView!
  @IBOutlet weak var ivDropoff: UIImageView!
  @IBOutlet weak var dropoffLabel: UILabel!
  @IBOutlet weak var promoAppliedKeyLabel: UILabel!
  @IBOutlet weak var promoAppliedValueLabel: UILabel!
  @IBOutlet weak var promoKeyLabel: UILabel!
  @IBOutlet weak var cashKeyLabel: UILabel!
  @IBOutlet weak var scheduleKeyLabel: UILabel!
  @IBOutlet weak var rideServicesContainer: UIView!
  @IBOutlet weak var mapInstructionsContainer: UIView!
  @IBOutlet weak var currentLocationButton: UIButton!
  @IBOutlet weak var showMoreRideOptions: UIButton!
  @IBOutlet weak var pickupAddressLabel: UILabel!
    @IBOutlet weak var btnRecenterLocationConstraint: NSLayoutConstraint!
  @IBOutlet weak var mapViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bottomConstraintCardView: NSLayoutConstraint!
    @IBOutlet weak var pickUpClikcBtn: UIButton!
    @IBOutlet weak var dropClikcBtn: UIButton!

    
  var tableViewMinimumHeight: CGFloat = 220
  var tableViewMaximumHeight: CGFloat = 220
  var selectedIndex = 0
  var selectedSection = 0
  
  @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
  @IBOutlet weak var mapToPickupCardView_Bottom: NSLayoutConstraint!
  @IBOutlet weak var mapToRideServicesView_Bottom: NSLayoutConstraint!
  var removeBookingOnReset : Bool = true
  
    var selectedPaymentMethod = "Cash"
    @IBOutlet weak var paymentTypeIcon: UIImageView!
    @IBOutlet weak var paymentTypeLabel: UILabel!
    
    var titleForRequestOrScheduleKarwa: String?

  //MARK:- View lifecycle
    fileprivate func setUpPreviousPaymentMethod() {
        if let selectedPM = PreviousSelectedPayment.shared.selectedPaymentMethod {
            if let paym = KTPaymentManager().getAllPayments().filter({$0.source! == selectedPM}).first {
                
                let paymentId = AESEncryption().encrypt(paym.source!)
                (viewModel as! KTCreateBookingViewModel).selectedPaymentMethodId = paymentId
                
                if paym.payment_type == "WALLET" {
                    self.paymentTypeLabel.text = "str_wallet".localized()
                    self.paymentTypeIcon.image = UIImage(named:"ico_wallet_new")
                } else {
                    self.paymentTypeLabel.text = "str_card".localized()
                    self.paymentTypeIcon.image = (paym.brand ?? "") == "MASTERCARD" ? UIImage(named: ImageUtil.getSmallImage(paym.brand ?? ""))! : UIImage(named: ImageUtil.getImage(paym.brand ?? ""))!
                }
                
            } else {
                (viewModel as! KTCreateBookingViewModel).selectedPaymentMethodId = ""
                self.paymentTypeLabel.text = "str_cash".localized()
                self.paymentTypeIcon.image = UIImage(named: ImageUtil.getImage("Cash"))
            }
        } else {
            (viewModel as! KTCreateBookingViewModel).selectedPaymentMethodId = ""
            self.paymentTypeLabel.text = "str_cash".localized()
            self.paymentTypeIcon.image = UIImage(named: ImageUtil.getImage("Cash"))
        }
    }
    
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
    self.btnRevealBtn.addTarget(self, action: #selector(showMenu), for: .touchUpInside)
    
    hideFareBreakdown(animated: false)
    pickupCardView.topTwoRoundedCorners()
    pickupCardView.applyShadow()
    destinationView.layer.cornerRadius = 30.0
    destinationView.applyShadow()
    collectionView.dataSource = self
    collectionView.delegate = self
    tableView.delegate = self
    tableView.dataSource = self
    tableView.backgroundColor = .clear
    tableView.isScrollEnabled = false
//    let gesture = UIPanGestureRecognizer(target: self, action: #selector(self.pan(_:)))
    
//    rideServicesContainer.addGestureRecognizer(gesture)
    tableViewHeight.constant = tableViewMaximumHeight
        if #available(iOS 15.0, *) {
            self.tableView.sectionHeaderTopPadding = 0.0
        } else {
            // Fallback on earlier versions
        }
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    self.showMoreRideOptions.isHidden = true

    //    hideCurrentLocationButton()
    
    //TODO: This needs to be converted on Location Call Back
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1)
    {
        self.vModel?.setupCurrentLocaiton()
    }
    
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 4)
    {
        self.vModel?.setupCurrentLocaiton()
    }

    if(Device.getLanguage().contains("AR"))
    {
        btnRecenterLocationConstraint.constant = 15
    }
    
    if vModel?.rebook == false {
        setUpPreviousPaymentMethod()
    } else {
        (viewModel as! KTCreateBookingViewModel).selectedPaymentMethodId = ""
        self.paymentTypeLabel.text = "str_cash".localized()
        self.paymentTypeIcon.image = UIImage(named: ImageUtil.getImage("Cash"))
    }
    
        if UIDevice().userInterfaceIdiom == .phone {
                switch UIScreen.main.nativeBounds.height {
                case 1136:
                    print("iPhone 5 or 5S or 5C")
                    bottomConstraintCardView.constant = 38
                case 1334:
                    print("iPhone 6/6S/7/8")
                    bottomConstraintCardView.constant = 38
                case 1920, 2208:
                    print("iPhone 6+/6S+/7+/8+")
                    bottomConstraintCardView.constant = 38
                case 2436:
                    print("iPhone X")
                    bottomConstraintCardView.constant = 68
                default:
                    print("unknown")
                    bottomConstraintCardView.constant = 68
                }
            }
        
        if !KTConfiguration.sharedInstance.checkRSEnabled() {
            bottomConstraintCardView.constant = 0
        }
        
        self.title = "str_book_karwa".localized()
        self.mapView.settings.rotateGestures = false
        self.mapView.settings.tiltGestures = false
        
        self.ivPickup.image = UIImage(named: "arrow_right copy_2")?.imageFlippedForRightToLeftLayoutDirection()
        self.ivDropoff.image = UIImage(named: "arrow_right copy_2")?.imageFlippedForRightToLeftLayoutDirection()
  }
    
    private func setupVehicleDetailBottomSheet() {
        if let viewModel = self.viewModel as? KTCreateBookingViewModel {
            var vehicles = viewModel.getVehicleByCategory(catName: VehicleCategories.FIRST.rawValue)
            if self.selectedSection == 0 {
                vehicles = viewModel.getVehicleByCategory(catName: VehicleCategories.FIRST.rawValue)
            }
            else if self.selectedSection == 1 {
                vehicles = viewModel.getVehicleByCategory(catName: VehicleCategories.SECOND.rawValue)
            }
            else {
                vehicles = viewModel.getVehicleByCategory(catName: VehicleCategories.THIRD.rawValue)
            }
            
            let bottomSheetVC = VehicleDetailBottomSheetVC()
            let bottomSheet = SheetViewController(
                controller: bottomSheetVC,
                sizes: [.fixed(530)],
                options: SheetOptions(useInlineMode: true))
            bottomSheetVC.sheet = bottomSheet
            bottomSheetVC.vehicles = vehicles
            bottomSheetVC.vModel = viewModel
            bottomSheet.allowPullingPastMaxHeight = false
            bottomSheet.allowPullingPastMinHeight = true
            
            bottomSheet.dismissOnPull = true
            bottomSheet.dismissOnOverlayTap = true
            bottomSheet.overlayColor = UIColor.black.withAlphaComponent(0.1)
            bottomSheet.contentViewController.view.layer.shadowColor = UIColor.black.cgColor
            bottomSheet.contentViewController.view.layer.shadowOpacity = 0.1
            bottomSheet.contentViewController.view.layer.shadowRadius = 10
            bottomSheet.cornerRadius = 30.0
            bottomSheet.allowGestureThroughOverlay = false
            bottomSheet.animateIn(to: view, in: self)
            
            bottomSheet.didDismiss = { [weak self] _ in
                guard let `self` = self else {return}
                (self.viewModel as! KTCreateBookingViewModel).resetVehicleTypes()
                self.updateVehicleTypeList()
            }
            
            if let title = self.titleForRequestOrScheduleKarwa {
                bottomSheetVC.setRequestButtonTitle(title: title)
            }
            bottomSheetVC.updateDetailBottomSheet()
        }
    }
  
  @objc private func showMenu() {
    sideMenuController?.revealMenu()
  }
  
  private var heightBegan: CGFloat = 0.0

  @objc func pan(_ pan: UIPanGestureRecognizer) {
    let translation = pan.translation(in: view)
    switch pan.state {
    case .began:
      heightBegan = tableViewHeight.constant
    case .changed:
      let fractionCompleted = abs(translation.y) / view.bounds.height
      if translation.y < 0 { // going up
        let value = tableViewMaximumHeight * fractionCompleted
        var result = heightBegan + value
        if result > tableViewMaximumHeight {
          result = tableViewMaximumHeight
        }
        tableViewHeight.constant = result
      }
      if translation.y > 0 { // going down
        let value = tableViewMaximumHeight * fractionCompleted
        var result = heightBegan - value
        if result < tableViewMinimumHeight {
          result = tableViewMinimumHeight
        }
        tableViewHeight.constant = result
      }
    case .ended:
        tableViewHeight.constant = translation.y < 0 ? tableViewMaximumHeight : tableViewMinimumHeight
        UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseInOut, animations: {
          self.view.layoutIfNeeded()
        }, completion: nil)

        let isClosed = (self.tableViewHeight.constant == self.tableViewMaximumHeight)
        DispatchQueue.main.async
        {
            self.showMoreRideOptions.isHidden = isClosed
            
            (self.viewModel as! KTCreateBookingViewModel).vehicleTypes = (self.viewModel as! KTCreateBookingViewModel).modifiedVehicleTypes
            
            if(self.selectedIndex != 0 && !isClosed)
            {
                UIView.transition(with: self.tableView,
                                  duration: 0.2,
                                  options: .transitionFlipFromTop,
                                  animations: {self.tableView.reloadData()},
                                  completion:
                                    {
                                        success in
                                        self.selectedIndex = 0
                                        self.focusIndex(selectingRow: 0, animateView: false)
                                    })
            }
        }
        default:
          ()
    }
  }
  
    func collapseRideList()
    {
        tableViewHeight.constant = tableViewMinimumHeight
        UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseInOut, animations: {
            self.showMoreRideOptions.isHidden = false
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
  override func viewWillAppear(_ animated: Bool)
  {
    super.viewWillAppear(false)
    navigationController?.isNavigationBarHidden = true
    navigationController?.isNavigationBarHidden = true
    self.tabBarController?.tabBar.alpha = 1
    self.mapViewBottomConstraint.constant = 280
  }
      
  @IBAction func scanPayBannerCrossTapped(_ sender: Any) {
    SharedPrefUtil.setScanNPayCoachmarkShown()
  }
  
  @IBAction func scanPayBannerTapped(_ sender: Any) {
    SharedPrefUtil.setScanNPayCoachmarkShown()
  }
  
  @IBAction func currentLocationButtonAction(_ sender: Any) {
    (viewModel as! KTCreateBookingViewModel).setupCurrentLocaiton()
//    hideCurrentLocationButton()
  }
  
  func hideCurrentLocationButton() {
    DispatchQueue.main.async {
     self.currentLocationButton.isHidden = true
    }
  }

  @IBAction func showMoreRideOptions(_ sender: Any) {
    tableViewHeight.constant =  tableViewMaximumHeight
    UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {
      self.view.layoutIfNeeded()
    }, completion: { animated in
      self.showMoreRideOptions.isHidden = true
    })
  }
  
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(false)
    
    (viewModel as! KTCreateBookingViewModel).fetchDestinations()
    
    //TODO: If no pick uplocation
    if (viewModel as! KTCreateBookingViewModel).vehicleTypeShouldAnimate() {
        if(self.carousel != nil)
        {
            self.carousel!.scrollToItem(at: IndexPath(row: (viewModel as! KTCreateBookingViewModel).maxCarouselIdx(), section: 0), at: UICollectionViewScrollPosition.right, animated: false)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3)
            {
              self.carousel!.scrollToItem(at: IndexPath(row: (self.viewModel as! KTCreateBookingViewModel).idxToSelectVehicleType(), section: 0), at: UICollectionViewScrollPosition.right, animated: true)
            }
        }
    }
    print(vModel?.booking.vehicleType)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    if timer != nil {
      timer.invalidate()
    }
//    tableViewHeight.constant =  tableViewMinimumHeight
//    UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {
//      self.view.layoutIfNeeded()
//    }, completion: { animated in
//      self.showMoreRideOptions.isHidden = false
//    })
    super.viewWillDisappear(animated)
    navigationController?.isNavigationBarHidden = true
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
    datePicker.show("",
                    doneButtonTitle: "txt_done".localized(),
                    cancelButtonTitle: "cancel".localized(), defaultDate: (viewModel as! KTCreateBookingViewModel).selectedPickupDateTime,
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
  
  @IBAction func btnCashTapped(_ sender: Any) {
    paymentSelectionVC.delegate = self
    sheet.allowPullingPastMaxHeight = true
    sheet.allowPullingPastMinHeight = true
    sheet.setSizes([.fixed(CGFloat(KTPaymentManager().getAllPayments().count * 90) + 270),.intrinsic], animated: true)
    sheet.dismissOnPull = true
    sheet.dismissOnOverlayTap = true
    sheet.overlayColor = UIColor.black.withAlphaComponent(0.6)
    sheet.contentViewController.view.layer.shadowColor = UIColor.black.cgColor
    sheet.contentViewController.view.layer.shadowOpacity = 0.1
    sheet.contentViewController.view.layer.shadowRadius = 10
    sheet.allowGestureThroughOverlay = false
    sheet.animateIn(to: view, in: self)
  }
    
    @objc func dismissSelectionMethod() {
        sheet.attemptDismiss(animated: true)
    }
  
  @IBAction func btnCancelBtnTapped(_ sender: Any) {
    removeBookingOnReset = true
    (viewModel as! KTCreateBookingViewModel).resetInProgressBooking()
    (viewModel as! KTCreateBookingViewModel).resetVehicleTypes()
//    collapseRideList()
    updateVehicleTypeList()
    if sheetPresented == true {
        self.dismissSelectionMethod()
    }
      self.viewWillAppear(true)
    self.tabBarController?.tabBar.isHidden = false
    self.edgesForExtendedLayout = UIRectEdge.all
    self.view.layoutIfNeeded()
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
  
  func setPromoButtonLabel(validPromo promo : String) {
    DispatchQueue.main.async {
      if promo.length > 0 {
        self.promoKeyLabel.text = promo
        self.promoKeyLabel.font = UIFont(name: "MuseoSans-900", size: 15.0)!
        self.promoAppliedKeyLabel.text = "txt_promo_applied".localized()
        self.promoAppliedValueLabel.text = ""
        self.promoAppliedContainer.isHidden = false
      }
      else {
        self.promoKeyLabel.text = "str_promo_str".localized()
        self.promoKeyLabel.font = UIFont(name: "MuseoSans-500", size: 15.0)!
        self.promoAppliedKeyLabel.text = ""
        self.promoAppliedValueLabel.text = ""
        self.promoAppliedContainer.isHidden = true
      }
    }
    //btnPromo.setTitle(promo.length > 0 ? promo : "+ Promo", for: .normal)
  }
  
  func setPromotionCode(promo promoEntered: String)
  {
    promoCode = promoEntered
  }
    
    func showPromotionAppliedToast(show: Bool) {
        self.showToast(message: "txt_promo_applied".localized())
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
    selectedIndex = 0
    restoreCustomerServiceSelection()
    self.tabBarController?.tabBar.isHidden = true
  }
  
  func hideCancelBookingBtn()  {
    self.tableView.isUserInteractionEnabled = true
    self.mapView.isUserInteractionEnabled = true
    btnCancelBtn.isHidden = true
    btnRevealBtn.isHidden = false
    setUpPreviousPaymentMethod()

  }
  
  func hideRequestBookingBtn() {
    UIView.animate(withDuration: 0.5, animations: {
      self.btnRequestBooking.isHidden = true
      self.view.layoutIfNeeded()
    })
  }
    
    func hidePickDropoffParentContainer()
    {
        UIView.animate(withDuration: 0.5, animations: {
          self.pickupDropoffParentContainer.isHidden = true
//            self.mapViewBottomConstraint.constant = 304
            
          self.view.layoutIfNeeded()
        })
    }
    
    func hideRideServicesContainer()
    {
        UIView.animate(withDuration: 0.5, animations: {
          self.rideServicesContainer.isHidden = true
          self.view.layoutIfNeeded()
        })
    }
  
  func showRequestBookingBtn()  {
    
    self.btnRequestBooking.animation = "slideUp"
    
        UIView.animate(withDuration: 0.5, animations: {
          self.btnRequestBooking.setNeedsDisplay()
          self.view.layoutIfNeeded()
        })
    
        self.btnRequestBooking.isHidden = false
        self.btnRequestBooking.animate()
  }
  
  func setRemoveBookingOnReset(removeBookingOnReset : Bool)
  {
    self.removeBookingOnReset = removeBookingOnReset
  }

    func pickDropBoxStep3() {
        
        let corouselSelected = (viewModel as? KTCreateBookingViewModel)?.carouselSelected
        
        self.rideServicesContainer.frame.origin.y += corouselSelected! ? 50 : 150
        self.pickupDropoffParentContainer.frame.origin.y += corouselSelected! ? 40 : 150
        self.pickupDropoffParentContainer.isHidden = false
        
        
        if self.promoCode == ""{
            self.promoAppliedContainer.isHidden = true
            //            self.mapViewBottomConstraint.constant = 304
        } else {
            //            self.mapViewBottomConstraint.constant = 375
        }
        
        //        self.view.layoutIfNeeded()
        
        self.rideServicesContainer.isHidden = false
        
        if !KTConfiguration.sharedInstance.checkRSEnabled() {
            self.mapViewBottomConstraint.constant = 280
        }
        
        if corouselSelected == false {
            UIView.animate(
                withDuration: 0.4,
                delay: 0.0,
                usingSpringWithDamping: 0.5,
                initialSpringVelocity: 2,
                options: .curveEaseInOut,
                animations:
                    {
                        self.rideServicesContainer.frame.origin.y -= 150
                        self.pickupDropoffParentContainer.frame.origin.y -= 150
                    },completion: nil)
            
        }
        
        
        self.pickupCardView.isHidden = true
        self.pickupPin.isHidden = true
        self.mapInstructionsContainer.isHidden = true
        self.currentLocationButton.isHidden = true
        (viewModel as? KTCreateBookingViewModel)?.carouselSelected = false

        //}
    }
  
  func pickDropBoxStep1() {
    DispatchQueue.main.async {
        self.pickupCardView.isHidden = false
        self.pickupPin.isHidden = false
        self.mapInstructionsContainer.isHidden = false
        self.currentLocationButton.isHidden = false
        
        if (self.promoKeyLabel.text?.count ?? 0) > 0 && self.promoKeyLabel.text! != "str_promo_str".localized() {
            self.promoAppliedContainer.isHidden = false
//            self.mapViewBottomConstraint.constant = 375
        } else {
            self.promoAppliedContainer.isHidden = true
//            self.mapViewBottomConstraint.constant = 304
        }

        
        if self.removeBookingOnReset == false {
            self.rideServicesContainer.isHidden = false
            self.pickupDropoffParentContainer.isHidden = false
            self.mapInstructionsContainer.isHidden = true
            self.pickupPin.isHidden = true
            self.pickupCardView.isHidden = true
        } else {
            self.rideServicesContainer.isHidden = true
            self.pickupDropoffParentContainer.isHidden = true
        }
        
        if !KTConfiguration.sharedInstance.checkRSEnabled() {
            if UIDevice().userInterfaceIdiom == .phone {
                switch UIScreen.main.nativeBounds.height {
                case 1136:
                    print("iPhone 5 or 5S or 5C")
                    self.mapViewBottomConstraint.constant = self.mapViewBottomConstraint.constant - 38
                case 1334:
                    print("iPhone 6/6S/7/8")
                    self.mapViewBottomConstraint.constant = self.mapViewBottomConstraint.constant - 38
                case 1920, 2208:
                    print("iPhone 6+/6S+/7+/8+")
                    self.mapViewBottomConstraint.constant = self.mapViewBottomConstraint.constant - 38
                case 2436:
                    print("iPhone X")
                    self.mapViewBottomConstraint.constant = self.mapViewBottomConstraint.constant - 68
                default:
                    print("unknown")
                    self.mapViewBottomConstraint.constant = self.mapViewBottomConstraint.constant - 68
                }
            }
            else {
                self.mapViewBottomConstraint.constant = self.mapViewBottomConstraint.constant - 50
            }
        }
    }
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
    let alertController = UIAlertController(title: "",
                                            message: "str_enable_location_services".localized(),
                                            preferredStyle: .alert)
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
    self.pickupAddressLabel.text = pick
    self.pickupLabel.text = pick
    self.pickupLabel.font = UIFont(name: "MuseoSans-700", size: 13.0)!
  }
  
  func setDropOff(drop: String?) {
    
    guard drop! != "txt_set_destination".localized() else {
        self.dropoffLabel.text = drop!
        self.dropoffLabel.font = UIFont(name: "MuseoSans-500Italic", size: 13.0)!
        self.tableView.reloadData()
        return
    }
    
    //self.btnDropoffAddress.setTitle(drop, for: UIControlState.normal)
    //self.btnDropoffAddress.setTitleColor(UIColor(hexString:"#1799A6"), for: UIControlState.normal)
    self.dropoffLabel.text = drop
    self.dropoffLabel.font = UIFont(name: "MuseoSans-700", size: 13.0)!

  }
  
  func setPickDate(date: String) {
    scheduleKeyLabel.text = date
    //btnPickDate.setTitle(date, for: UIControlState.normal)
  }
    
    func setRequestButtonTitle(title: String) {
        self.titleForRequestOrScheduleKarwa = title
    }
      
  
  func hideFareBreakdown() {
    
    //        btnRevealBtn.constant = 0
    //        btnRevealBtn.constant = 0
    //        btnRevealBtn.constant = 0
    
    //fareBreakdown.showHideBackFareDetailsBtn(hide: true)
    
    //viewFareBreakdown.alpha = 0.0
    //self.viewFareBreakdown.isHidden = true
    
    //self.view.layoutIfNeeded()
  }
  
}

extension KTCreateBookingViewController: PaymethodSelectionDelegate {
    func setSelectedPaymentType(type: String, paymentMethod: KTPaymentMethod?) {
        if type == "Wallet" {
            let paymentId = AESEncryption().encrypt(paymentMethod?.source ?? "")
            (viewModel as! KTCreateBookingViewModel).selectedPaymentMethodId = paymentId
            self.paymentTypeLabel.text = "str_wallet".localized()
            self.paymentTypeIcon.image = UIImage(named:"ico_wallet_new")
            PreviousSelectedPayment.shared.selectedPaymentMethod = paymentMethod?.source!
        } else if type == "Card" {
            let paymentId = AESEncryption().encrypt(paymentMethod?.source ?? "")
            (viewModel as! KTCreateBookingViewModel).selectedPaymentMethodId = paymentId
            self.paymentTypeLabel.text =  "str_card".localized()
            self.paymentTypeIcon.image = (paymentMethod?.brand ?? "") == "MASTERCARD" ? UIImage(named: ImageUtil.getSmallImage(paymentMethod?.brand ?? ""))! : UIImage(named: ImageUtil.getImage(paymentMethod?.brand ?? ""))!
            PreviousSelectedPayment.shared.selectedPaymentMethod = paymentMethod?.source!
        }
        else {
            (viewModel as! KTCreateBookingViewModel).selectedPaymentMethodId = ""
            self.paymentTypeLabel.text = "str_cash".localized()
            self.paymentTypeIcon.image = UIImage(named: ImageUtil.getImage("Cash"))
            PreviousSelectedPayment.shared.selectedPaymentMethod = nil

        }
        self.dismissSelectionMethod()
        self.paymentTypeIcon.contentMode = .center
        
              
    }
    
    func closeSheet() {
        
    }
    
}

extension UICollectionViewFlowLayout {

    open override var flipsHorizontallyInOppositeLayoutDirection: Bool {
        return true
    }

}
