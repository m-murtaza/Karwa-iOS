//
//  KTAddressPickerViewController.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 1/23/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation

enum SelectedTextField: Int {
  case PickupAddress = 1
  case DropoffAddress = 2
}

enum SelectedInputMechanism : Int {
  case ListView = 1
  case MapView = 2
}

enum Tab {
  case address
  case favorite
}

let MIN_ALLOWED_TEXT_COUNT_SEARCH  = 2
let SEC_WAIT_START_SEARCH = 1.0
let SELECTED_TEXT_FIELD_COLOR : UIColor = UIColor(hexString: "#F5F5F5")

class KTAddressPickerViewController: KTBaseViewController,
KTAddressPickerViewModelDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, GMSMapViewDelegate, AddressPickerCellDelegate, KTXpressFavoriteDelegate {
  
  @IBOutlet weak var tblView: UITableView!
  @IBOutlet weak var txtPickAddress: UITextField!
  @IBOutlet weak var txtDropAddress: UITextField!
  @IBOutlet weak var imgListSelected : UIImageView!
  @IBOutlet weak var imgMapSelected : UIImageView!
  @IBOutlet weak var mapView : GMSMapView!
  @IBOutlet weak var mapSuperView : UIView!
  @IBOutlet weak var imgMapMarker : UIImageView!
  
  @IBOutlet weak var skipButton: UIButton!
  @IBOutlet weak var addressesListButton: UIButton!
  @IBOutlet weak var favouritesListButton: UIButton!
    @IBOutlet weak var setOnMapLabel: UILabel!
  @IBOutlet weak var mapOptionsContainer: UIView!
  
  @IBOutlet weak var btnHome : UIButton!
  @IBOutlet weak var btnWork : UIButton!
  @IBOutlet weak var btnConfirm : UIButton!
  @IBOutlet weak var titleLabel: UILabel!
  
  @IBOutlet weak var clearButtonPickup: UIButton!
  @IBOutlet weak var clearButtonDestination: UIButton!
  
  @IBOutlet weak var constraintTableViewBottom : NSLayoutConstraint!
  
  public var pickupAddress : KTGeoLocation?
  public var dropoffAddress : KTGeoLocation?
  var delegateAddress: KTXpressAddressDelegate?
  var metroStations = [Area]()
    var keyboardShowing = false
  var destinationForPickUp = [Area]()
    var fromDropOff = true
    var pickUpAddressName = ""
    var valueChanged = false

  public weak var previousView : KTCreateBookingViewModel?
  
  private var tab: Tab = .address {
    didSet {
      switch tab {
      case .address:
        imgListSelected.isHidden = false
        imgMapSelected.isHidden = true
        addressesListButton.setTitleColor(UIColor.primary, for: .normal)
        favouritesListButton.setTitleColor(UIColor.primary.withAlphaComponent(0.5), for: .normal)
      case .favorite:
        imgListSelected.isHidden = true
        imgMapSelected.isHidden = false
        addressesListButton.setTitleColor(UIColor.primary.withAlphaComponent(0.5), for: .normal)
        favouritesListButton.setTitleColor(UIColor.primary, for: .normal)
      }
    }
  }
  
  private var searchTimer: Timer = Timer()
  private var searchText : String = ""
  
  public var selectedTxtField : SelectedTextField = SelectedTextField.DropoffAddress
  private var selectedInputMechanism : SelectedInputMechanism = SelectedInputMechanism.ListView
  
  public var isConfirmPickupFlowDone : Bool = false
  
  
  private var zoomForPickupRequired : Bool = false
  
  ///This bool will be use to check if selected text box should be clear when user type a charecter.
  ///http://redmine.karwatechnologies.com/issues/2430 Point D.
  ///D)Tap and type in the Set current/destination address should clear the current/destination address
  private var removeTxtFromTextBox : Bool = true
  
  override func viewDidLoad() {
      
      self.tblView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 200, right: 0)
      
    self.setOnMapLabel.text = "txt_set_on_maps".localized()

    viewModel = KTAddressPickerViewModel(del:self)
    
    (viewModel as! KTAddressPickerViewModel).pickUpAddress = pickupAddress
    
    if dropoffAddress != nil {
      (viewModel as! KTAddressPickerViewModel).dropOffAddress = dropoffAddress
    }
      
      (viewModel as! KTAddressPickerViewModel).metroStations = self.metroStations
      
      getFavouriteMetroStations()

      tblView.tableFooterView = UIView(frame: .zero)
      tblView.delegate = self
      tblView.dataSource = self
      
      txtPickAddress.attributedPlaceholder = NSAttributedString(
        string: "str_setpick_loc".localized(),
          attributes: [NSAttributedStringKey.foregroundColor: UIColor.placeholder]
      )
      
      txtDropAddress.attributedPlaceholder = NSAttributedString(
        string: "hint_set_destination".localized(),
        attributes: [NSAttributedStringKey.foregroundColor: UIColor.placeholder]
      )
    
//      txtDropAddress.isUserInteractionEnabled = false
//    //Do not move these line after super.viewDidLoad
//
//      if fromDropOff == false {
//          self.txtPickAddress.text = pickUpAddressName
//          self.txtPickAddress.isUserInteractionEnabled = false
//          txtDropAddress.isUserInteractionEnabled = true
//          self.txtDropAddress.becomeFirstResponder()
//          self.selectedTxtField = SelectedTextField.DropoffAddress
//      }

    super.viewDidLoad()
    setupUI()
  }
    
    override func viewDidLayoutSubviews() {
          super.viewDidLayoutSubviews()
        
        if #available(iOS 15.0, *) {
            self.tblView.sectionHeaderTopPadding = 0.0
        } else {
            // Fallback on earlier versions
        }
//        self.tblView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

    }
  
  private func setupUI() {
    setupTableView()
    toggleSkipButton()
    skipButton.setTitle("signin_prompt_skip".localized(), for: .normal)
    addressesListButton.setTitle("btn_addresses_title".localized().uppercased(), for: .normal)
    favouritesListButton.setTitle("btn_favorites_title".localized().uppercased(), for: .normal)
  }
  
  private func setupTableView() {
    tblView.estimatedRowHeight = 80
    tblView.rowHeight = UITableViewAutomaticDimension
  }
  
  private func toggleSkipButton() {
    if metroStations.count == 0{
        switch selectedTxtField {
        case .PickupAddress:
          skipButton.isHidden = true
        case .DropoffAddress:
          skipButton.isHidden = false
        }
    }   else {
        skipButton.isHidden = true
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    NotificationCenter.default.addObserver(self, selector: #selector(KTAddressPickerViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(KTAddressPickerViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
  }
  
  @IBAction func clearActionPickup(_ sender: Any) {
    (viewModel as! KTAddressPickerViewModel).pickupAddressClearedAction()
    txtPickAddress.text = ""
    (viewModel as! KTAddressPickerViewModel).fetchLocations()
      clearButtonPickup.isHidden = true
  }
  
  @IBAction func clearActionDropoff(_ sender: Any) {
    (viewModel as! KTAddressPickerViewModel).dropoffAddressClearedAction()
    txtDropAddress.text = ""
      (viewModel as! KTAddressPickerViewModel).fetchLocations()
      clearButtonDestination.isHidden = true
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    //        print("Table view scroll detected at offset: %f", scrollView.contentOffset.y)
    //        txtPickAddress.resignFirstResponder()
    //        txtDropAddress.resignFirstResponder()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    NotificationCenter.default.removeObserver(self)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    if selectedTxtField == SelectedTextField.DropoffAddress {
      self.txtDropAddress.becomeFirstResponder()
    }
    else {
      self.txtPickAddress.becomeFirstResponder()
    }
    
    
      if metroStations.count == 0 {

          initializeMap()

          if (self.txtPickAddress.text?.count ?? 0) > 0 && (self.txtDropAddress.text?.count ?? 0) > 0{
              
              if selectedTxtField == SelectedTextField.DropoffAddress {
                  toggleToMapView(forPickup: false)
              }
              else {
                  toggleToMapView(forPickup: true)
              }
              
          }
      }
      
    
  }
  
  //MARK: - Notification
    @objc func keyboardWillShow(notification: NSNotification) {
        // read the CGRect from the notification (if any)
        if let newFrame = (notification.userInfo?[ UIKeyboardFrameEndUserInfoKey ] as? NSValue)?.cgRectValue {
            let insets = UIEdgeInsetsMake( 0, 0, 325, 0 )
            tblView.contentInset = insets
            tblView.scrollIndicatorInsets = insets
            
            print(newFrame.height)
            
            if UIDevice().userInterfaceIdiom == .phone {
                    switch UIScreen.main.nativeBounds.height {
                    case 1136:
                        print("iPhone 5 or 5S or 5C")
                        constraintTableViewBottom.constant = newFrame.height
                    case 1334:
                        print("iPhone 6/6S/7/8")
                        constraintTableViewBottom.constant = newFrame.height
                    case 1920, 2208:
                        print("iPhone 6+/6S+/7+/8+")
                        constraintTableViewBottom.constant = newFrame.height
                    default:
                        print("unknown")
                        constraintTableViewBottom.constant = newFrame.height-35
                    }
                }
            self.view.layoutIfNeeded()
        }
    }
  
  @objc func keyboardWillHide(notification: NSNotification) {
      if UIDevice().userInterfaceIdiom == .phone {
              switch UIScreen.main.nativeBounds.height {
              case 1136:
                  print("iPhone 5 or 5S or 5C")
                  constraintTableViewBottom.constant = 0
              case 1334:
                  print("iPhone 6/6S/7/8")
                  constraintTableViewBottom.constant = 0
              case 1920, 2208:
                  print("iPhone 6+/6S+/7+/8+")
                  constraintTableViewBottom.constant = 0
              default:
                  print("unknown")
                  constraintTableViewBottom.constant = -20
              }
          }
//      tblView.contentInset = .zero
  }
  
  
  //MARK: - Map related functions.
  private func initializeMap () {
    
    self.mapView.isMyLocationEnabled = true
    
    var focusLocation : CLLocationCoordinate2D  = (viewModel as! KTAddressPickerViewModel).currentLocation()
    
    if selectedTxtField == SelectedTextField.PickupAddress {
      if (viewModel as! KTAddressPickerViewModel).pickUpAddress != nil {
          focusLocation = getCoordinates(location: (viewModel as! KTAddressPickerViewModel).pickUpAddress)
      }
    }
    else {
      if (viewModel as! KTAddressPickerViewModel).dropOffAddress != nil {
          focusLocation = getCoordinates(location: (viewModel as! KTAddressPickerViewModel).dropOffAddress)
      }
    }
    
    let camera = GMSCameraPosition.camera(withLatitude: focusLocation.latitude, longitude: focusLocation.longitude, zoom: 14.0)
    
    self.mapView.camera = camera;
    self.mapView.delegate = self
    do {
      // Set the map style by passing the URL of the local file.
      if let styleURL = Bundle.main.url(forResource: "map_style_karwa", withExtension: "json") {
        mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
      } else {
        NSLog("Unable to find style.json")
      }
    } catch {
      NSLog("One or more of the map styles failed to load. \(error)")
    }
    
    //        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
    self.mapView.settings.myLocationButton = true
    self.mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: 85, right: 0)
    
    self.imgMapMarker.frame = CGRect(x: self.imgMapMarker.frame.origin.x, y: self.mapView.frame.height/2 - 85, width: self.imgMapMarker.frame.size.width, height: self.imgMapMarker.frame.size.height)
    //            self.imgMapMarker.frame = CGRect(x: 0, y: 75, width: self.imgMapMarker.frame.height, height: self.imgMapMarker.frame.width)
    //        }
  }
  
  private func updateMap()
  {
    updateMap(zoomLevel : KTCreateBookingConstants.DEFAULT_MAP_ZOOM)
  }
  
  private func updateMap(zoomLevel : Float)
  {
    var focusLocation : CLLocationCoordinate2D  = (viewModel as! KTAddressPickerViewModel).currentLocation()
    
    if selectedTxtField == SelectedTextField.PickupAddress {
      
      if (viewModel as! KTAddressPickerViewModel).pickUpAddress != nil
      {
        focusLocation = getCoordinates(location: (viewModel as! KTAddressPickerViewModel).pickUpAddress)//CLLocationCoordinate2D(latitude: ((viewModel as! KTAddressPickerViewModel).pickUpAddress?.latitude)!, longitude: ((viewModel as! KTAddressPickerViewModel).pickUpAddress?.longitude)!)
      }
    }
    else {
      if (viewModel as! KTAddressPickerViewModel).dropOffAddress != nil
      {
          focusLocation = getCoordinates(location: (viewModel as! KTAddressPickerViewModel).dropOffAddress)
      }
    }
    
    let update :GMSCameraUpdate = GMSCameraUpdate.setTarget(focusLocation, zoom: zoomLevel)
    CATransaction.begin()
    CATransaction.setValue(0.75, forKey: kCATransactionAnimationDuration)
    mapView.animate(with: update)
    CATransaction.commit()
    
  }
  
  func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
    enableButtons()
    
    if selectedInputMechanism == SelectedInputMechanism.MapView
    {
      (viewModel as! KTAddressPickerViewModel).MapStopMoving(location: mapView.camera.target)
    }
  }
  
  func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
    if (gesture){
      //print("dragged")
      disableButtons()
    }
  }
  
  //MARK:- Buttons and UserIntractions
  func disableButtons() {
    updateButtonsUserIntraction(enable: false)
  }
  
  func enableButtons() {
    updateButtonsUserIntraction(enable: true)
  }
  
  func updateButtonsUserIntraction(enable : Bool) {
    btnHome.isUserInteractionEnabled = enable
    btnWork.isUserInteractionEnabled = enable
    btnConfirm.isUserInteractionEnabled = enable
  }
  //MARK: - User Actions
  
  @IBAction func swapPickupAndDestination(_ sender: Any) {
    if txtPickAddress.text!.isEmpty && txtDropAddress.text!.isEmpty {
     return
    }
    let result = (viewModel as! KTAddressPickerViewModel).swapPickupAndDestination()
    if result {
      let temporary = txtPickAddress.text!
      txtPickAddress.text = txtDropAddress.text!
      txtDropAddress.text = temporary
    }
  }
  
  @IBAction func btnConfirmTapped(_ sender: Any) {
    
    (viewModel as! KTAddressPickerViewModel).confimMapSelection()
  }
  
  @IBAction func btnSkipTapped(_ sender: Any) {
    (viewModel as! KTAddressPickerViewModel).skipDestination()
  }
  
  @IBAction func btnSetWorkTapped(_ sender: Any) {
    btnToggleMapOptions(self)
    (viewModel as! KTAddressPickerViewModel).btnSetWorkTapped()
  }
  
  @IBAction func btnSetFavoriteTapped(_ sender: Any) {
    btnToggleMapOptions(self)
    (viewModel as! KTAddressPickerViewModel).btnFavoriteTapped()
  }
  
  @IBAction func btnSetHomeTapped(_ sender: Any) {
    btnToggleMapOptions(self)
    (viewModel as! KTAddressPickerViewModel).btnSetHomeTapped()
  }
  
  @IBAction func btnToggleMapOptions(_ sender: Any) {
    self.mapOptionsContainer.isHidden.toggle()
  }
  
  //MARK: - MAP/ LIST Selected
  
  @IBAction func btnListViewTapped(_ sender: Any) {
    tab = .address
    self.tblView.isHidden = false
    self.mapSuperView.isHidden = true
    
    txtDropAddress.inputView = nil
    txtPickAddress.inputView = nil
    
    selectedInputMechanism = SelectedInputMechanism.ListView
    
//    txtPickAddress.tintColor = UIColor(hexString:"#006170")
//    txtPickAddress.backgroundColor = UIColor.white
//    txtDropAddress.tintColor = UIColor(hexString:"#006170")
//    txtDropAddress.backgroundColor = UIColor.white
    
    if selectedTxtField == SelectedTextField.PickupAddress
    {
        print(self.pickUpTxt())
        self.txtPickAddress.becomeFirstResponder()
    }
    else
    {
        self.txtDropAddress.becomeFirstResponder()
    }
  }
  
  func toggleConfirmBtn(enableBtn enable : Bool)
  {
    btnConfirm.isEnabled = enable
  }
  
  @IBAction func btnMapViewTapped(_ sender: Any)
  {
      if metroStations.count == 0 {
          if mapSuperView.isHidden == false {
              self.tblView.isHidden = false
              self.mapSuperView.isHidden = true
              
              txtDropAddress.inputView = nil
              txtPickAddress.inputView = nil
              
              txtDropAddress.reloadInputViews()
              txtPickAddress.reloadInputViews()

              selectedInputMechanism = SelectedInputMechanism.ListView
              
              if selectedTxtField == SelectedTextField.DropoffAddress {
                  if dropoffAddress != nil {
                      clearButtonDestination.isHidden = false
                  }
              }
              
              if selectedTxtField == SelectedTextField.PickupAddress {
                  if pickupAddress != nil {
                      clearButtonPickup.isHidden = false
                  }
              }
              
          //    txtPickAddress.tintColor = UIColor(hexString:"#006170")
          //    txtPickAddress.backgroundColor = UIColor.white
          //    txtDropAddress.tintColor = UIColor(hexString:"#006170")
          //    txtDropAddress.backgroundColor = UIColor.white
             
              self.txtPickAddress.tintColor = UIColor.primary
              self.txtDropAddress.tintColor = UIColor.primary

              self.setOnMapLabel.text = "txt_set_on_maps".localized()
          } else {
              toggleToMapView()
              
              self.clearButtonPickup.isHidden = true
              self.clearButtonDestination.isHidden = true
              self.setOnMapLabel.text = "str_show_list".localized()
          }
      } else {
          if valueChanged == false {
              self.dismiss(animated: true, completion: nil)
          } else {
              self.delegateAddress?.setLocation(picklocation: pickupAddress, dropLocation: dropoffAddress, destinationForPickUp: destinationForPickUp)
              self.dismiss(animated: true, completion: nil)
          }
      }
      
      
      
  }
  
  @IBAction func btnFavoritesViewTapped(_ sender: Any) {
    tab = .favorite
    addressesListButton.setTitleColor(UIColor.primary.withAlphaComponent(0.5), for: .normal)
    favouritesListButton.setTitleColor(UIColor.primary, for: .normal)
    
    imgListSelected.isHidden = true
    imgMapSelected.isHidden = false
    
    (viewModel as! KTAddressPickerViewModel).loadFavoritesDataInView()
  }
  
  func toggleToMapView()
  {
    toggleToMapView(forPickup : false)
  }
  
  func toggleToMapView(forPickup : Bool)
  {
    selectedInputMechanism = SelectedInputMechanism.MapView
    
    self.zoomForPickupRequired = forPickup
    
//    imgListSelected.isHidden = true
//    imgMapSelected.isHidden = false
    
    
    self.tblView.isHidden = true
    self.mapSuperView.isHidden = false
    
    //UIView* dummyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    //myTextField.inputView = dummyView; // Hide keyboard, but show blinking cursor
    
    //let dummyView : UIView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0))
    txtDropAddress.inputView = UIView()
    txtPickAddress.inputView = UIView()
    
    if selectedTxtField == SelectedTextField.DropoffAddress {

      self.txtDropAddress.resignFirstResponder()
      txtDropAddress.becomeFirstResponder()
    }
    else {

      self.txtPickAddress.resignFirstResponder()
      txtPickAddress.becomeFirstResponder()
    }
    
//    txtPickAddress.tintColor = SELECTED_TEXT_FIELD_COLOR
//    txtDropAddress.tintColor = SELECTED_TEXT_FIELD_COLOR
    
//    if selectedTxtField == SelectedTextField.PickupAddress {
//
//      txtPickAddress.backgroundColor = SELECTED_TEXT_FIELD_COLOR
//    }
//    else {
//
//      txtDropAddress.backgroundColor = SELECTED_TEXT_FIELD_COLOR
//    }
  }
  
  @IBAction func dismissAction(_ sender: UIButton) {
    self.dismiss(animated: true, completion: nil)
  }
  
  // MARK: - View Model Delegate
  func moveFocusToDestination() {
    txtDropAddress.becomeFirstResponder()
  }
  
    func moveFocusToPickUp() {
      txtPickAddress.becomeFirstResponder()
    }
    
  func inFocusTextField() -> SelectedTextField {
    
    return selectedTxtField
  }
  
  func loadData() {
    tblView.reloadData()
  }
  
    fileprivate func checkDropOff(_ pickup: Any?) {
        if let dropOff = (viewModel as! KTAddressPickerViewModel).dropOffAddress as? Area {
            let metroAreaCoordinate = getCenterPointOfPolygon(bounds: dropOff.bound!)
            selectedRSDropOffCoordinate = CLLocationCoordinate2D(latitude: metroAreaCoordinate.latitude, longitude: metroAreaCoordinate.longitude)
            if dropOff.type! == "Zone" {
                selectedRSDropZone = dropOff
            } else {
                selectedRSDropStation = dropOff
                let stopOfStations = areas.filter{$0.parent == selectedRSDropStation?.code}
                selectedRSDropStop = stopOfStations.first!
                selectedRSDropZone = areas.filter{$0.code == selectedRSDropStation?.parent}.first!
            }
        } else {
            
            if let dropOff = (viewModel as! KTAddressPickerViewModel).dropOffAddress as? KTGeoLocation {
                if checkLatLonInside(location: CLLocation(latitude: dropOff.latitude, longitude: dropOff.longitude)) {
                    selectedRSDropOffCoordinate = CLLocationCoordinate2D(latitude: dropOff.latitude, longitude: dropOff.longitude)
                    self.setDropLocations()
                    self.delegateAddress?.setLocation(picklocation: pickup, dropLocation: dropOff, destinationForPickUp: self.destinationForPickUp)
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.showToast(message: "Please select proper dropoff location")
                }
                
            } else if let dropOff = (viewModel as! KTAddressPickerViewModel).dropOffAddress as? Area {
                let metrocoordinate = getCenterPointOfPolygon(bounds: dropOff.bound ?? "")
                if checkLatLonInside(location: CLLocation(latitude: metrocoordinate.latitude, longitude: metrocoordinate.longitude)) {
                    selectedRSDropOffCoordinate = metrocoordinate
                    self.setDropLocations()
                    self.delegateAddress?.setLocation(picklocation: pickup, dropLocation: dropOff, destinationForPickUp: self.destinationForPickUp)
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.showToast(message: "Please select proper dropoff location")
                }
            }
            
        }
    }
    
    func navigateToPreviousView(pickup: Any?, dropOff: Any?) {
      
      if metroStations.count == 0 {
          if pickup != nil {
            previousView?.setPickAddress(pAddress: pickup as! KTGeoLocation)
          }
          if dropOff != nil {
            previousView?.setDropAddress(dAddress: dropOff as! KTGeoLocation)
          }
          else {
            previousView?.setSkipDropOff()
          }
          previousView?.dismiss()
      } else {
          
          self.checkPermittedDropOff(dropOff: dropOff, pickup: pickup)
                              
      }
    
  }
    
    func checkPermittedDropOff(dropOff: Any?, pickup: Any?) {
        
        for item in destinationForPickUp {
            
            var location = CLLocation()
            
            if let drop = (viewModel as! KTAddressPickerViewModel).dropOffAddress as? Area {
                location = CLLocation(latitude:  getCenterPointOfPolygon(bounds: drop.bound ?? "").latitude, longitude:  getCenterPointOfPolygon(bounds: drop.bound ?? "").longitude)
            }
            
            if let drop1 = (viewModel as! KTAddressPickerViewModel).dropOffAddress as? KTGeoLocation {
                location = CLLocation(latitude:  drop1.latitude, longitude:  drop1.longitude)
            }
            
            let coordinates = item.bound!.components(separatedBy: ";").map{$0.components(separatedBy: ",")}.map{$0.map({Double($0)!})}.map { (value) -> CLLocationCoordinate2D in
                return CLLocationCoordinate2D(latitude: value[0], longitude: value[1])
            }
            
            if CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude).contained(by: coordinates) {
                
                if selectedRSPickStation != nil {
                    
                    let pickupCoordinates = selectedRSPickStation!.bound!.components(separatedBy: ";").map{$0.components(separatedBy: ",")}.map{$0.map({Double($0)!})}.map { (value) -> CLLocationCoordinate2D in
                        return CLLocationCoordinate2D(latitude: value[0], longitude: value[1])
                    }
                    
                    if CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude).contained(by: pickupCoordinates) {
                        print("not permitted")
//                        self.showToast(message: "Please select proper dropoff location")
//                        self.showErrorBanner("", "str_outzone".localized())
                        self.view.endEditing(true)
                        self.showToast(message: "str_outzone".localized())
                    }
                    else {
                        print("Permitted")
                        selectedRSDropOffCoordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                        self.setDropLocations()
                        self.delegateAddress?.setLocation(picklocation: pickup, dropLocation: dropOff, destinationForPickUp: self.destinationForPickUp)
                        self.dismiss(animated: true, completion: nil)
                        break
                    }
                } else {
                    print("Permitted")
                    selectedRSDropOffCoordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                    self.setDropLocations()
                    self.delegateAddress?.setLocation(picklocation: pickup, dropLocation: dropOff, destinationForPickUp: self.destinationForPickUp)
                    self.dismiss(animated: true, completion: nil)
                    break
                }
                
            } else {
                
                if selectedRSPickZone != nil {
                    
                    let pickupCoordinates = selectedRSPickZone!.bound!.components(separatedBy: ";").map{$0.components(separatedBy: ",")}.map{$0.map({Double($0)!})}.map { (value) -> CLLocationCoordinate2D in
                        return CLLocationCoordinate2D(latitude: value[0], longitude: value[1])
                    }
                    
                    if CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude).contained(by: pickupCoordinates) {
                        print("not permitted")
                        self.view.endEditing(true)
                        self.showToast(message: "SETTODROPZONE".localized())
//                        self.showToast(message: "Please select proper dropoff location")
//                        self.showErrorBanner("", "SETTODROPZONE".localized())

//                        self.setLocationButton.setTitle("SETTODROPZONE".localized(), for: .normal)
                    } else {
                        print("it wont contains")
                        self.view.endEditing(true)
                        self.showToast(message: "str_outzone".localized())
//                        self.showToast(message: "Please select proper dropoff location")
//                        self.showErrorBanner("", "str_outzone".localized())

//                        self.setLocationButton.setTitle("str_outzone".localized(), for: .normal)
                    }
                    
                } else {
                    
                    print("it wont contains")
                    self.view.endEditing(true)
                    self.showToast(message: "str_outzone".localized())
//                    self.showToast(message: "Please select proper dropoff location")
//                    self.showErrorBanner("", "str_outzone".localized())
//                    self.setDropOffButton.layer.shadowColor = UIColor.clear.cgColor
                    
                }
                
                
            }
            
        }
    }
  
  func startConfirmPickupFlow()
  {
    //        btnConfirm.setTitle("CONFIRM PICKUP",for: .normal)
    
    btnConfirm.setTitle("txt_confirm_pickup".localized(), for: .normal)
    
    selectedTxtField = SelectedTextField.PickupAddress
    toggleToMapView(forPickup: true)
    refineDropOff()
    
    /*
     TODO:
     - Change name of set destination to set pickup
     - Change List to Map
     - Focus on Pickup field
     */
  }
    
//    func navigateToFavoriteScreen(location: KTGeoLocation?) {
//        let vc = KTXpressFavoriteAddressViewController()
//        vc.favoritelocation = location
//        vc.xpressFavoriteDelegate = self
//        vc.modalPresentationStyle = .fullScreen
//        self.present(vc, animated: true, completion: nil)
//    }
    
    func savedFavorite() {
        (viewModel as! KTAddressPickerViewModel).fetchLocations(forSearch: searchText)
    }
  
    func navigateToFavoriteScreen(location: KTGeoLocation?) {
        let vc = KTFavoriteAddressViewController()
        vc.favoritelocation = location
        vc.xpressFavoriteDelegate = self
        vc.modalPresentationStyle = .fullScreen
        //    if #available(iOS 13.0, *)
        //    {
        //        vc.modalPresentationStyle = .automatic
        //    } else
        //    {
        //        vc.modalPresentationStyle = .fullScreen
        //    }
        self.present(vc, animated: true, completion: nil)
    }
  
  func refineDropOff()
  {
    // refine the drop-off which is disturbed.
    
    if (viewModel as! KTAddressPickerViewModel).dropOffAddress != nil
    {
      setDropOff(drop: getAddressName(location: (viewModel as! KTAddressPickerViewModel).dropOffAddress))
    }
    else
    {
      setDropOff(drop: "")
    }
  }
  
  func getConfirmPickupFlowDone() -> Bool
  {
    return self.isConfirmPickupFlowDone
  }
  
  func setConfirmPickupFlowDone(isConfirmPickupFlowDone : Bool)
  {
    self.isConfirmPickupFlowDone = isConfirmPickupFlowDone
  }
  
  func pickUpTxt() -> String {
    return self.txtPickAddress.text!
  }
  
  func dropOffTxt() -> String {
    return self.txtDropAddress.text!
  }
  func setPickUp(pick: String) {
    if(selectedInputMechanism == SelectedInputMechanism.MapView)
    {
      setConfirmPickupFlowDone(isConfirmPickupFlowDone: true)
    }
      
      print("***************** pickup text ********************", pick)
      
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
          self.txtPickAddress.text = pick
      }
      
  }
  
  func setDropOff(drop: String) {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
          self.txtDropAddress.text = drop
      }
  }
  
  // MARK: - TableView Delegates
  
//  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//    return (viewModel as! KTAddressPickerViewModel).numberOfRow(section: section)
//  }
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 3
//    }
//
//  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//    let cell : AddressPickCell = tableView.dequeueReusableCell(withIdentifier: "AddPickCellIdentifier", for: indexPath) as! AddressPickCell
//    /*AddressPickCell(style: UITableViewCellStyle.default, reuseIdentifier: "AddPickCellIdentifier")*/
//
//    cell.addressTitle.text = (viewModel as! KTAddressPickerViewModel).addressTitle(forIndex: indexPath)
//    cell.addressArea.text = (viewModel as! KTAddressPickerViewModel).addressArea(forIndex: indexPath)
//
//    cell.ImgTypeIcon.image = (viewModel as! KTAddressPickerViewModel).addressTypeIcon(forIndex: indexPath)
//
//    cell.btnMore.tag = indexPath.row
//
//    cell.delegate = self
//
////    animateCell(cell)
//
//    return cell
//  }
//
//  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//    (viewModel as! KTAddressPickerViewModel).didSelectRow(at:indexPath.row, type:selectedTxtField)
//  }
  
  // MARK: - UItextField Delegates
  
  func textFieldDidBeginEditing(_ textField: UITextField){
    if selectedInputMechanism == SelectedInputMechanism.MapView {
      
      updateSelectedField(txt:textField)
      
    }
    
    if textField.isEqual(txtDropAddress) {
      selectedTxtField = SelectedTextField.DropoffAddress
      titleLabel.text = "txt_set_drop_off".localized()
      clearButtonPickup.isHidden = true
        if textField.text?.count ?? 0 != 0 {
            clearButtonDestination.isHidden = false
        }
        if self.metroStations.count != 0 {
            self.getDestinationForPickUp()
        }
    }
    else {
      selectedTxtField = SelectedTextField.PickupAddress
      titleLabel.text = "txt_pick_up".localized()
        if textField.text?.count ?? 0 != 0 {
            clearButtonPickup.isHidden = false
        }
      clearButtonDestination.isHidden = true
      (viewModel as! KTAddressPickerViewModel).metroStations = self.metroStations
        
        if metroStations.count != 0 {
            if dropoffAddress == nil {
                txtDropAddress.isUserInteractionEnabled = false
            } else {
                txtDropAddress.isUserInteractionEnabled = true
            }
        }
        
    }
    
    (viewModel as! KTAddressPickerViewModel).txtFieldSelectionChanged()
    
    
//    removeTxtFromTextBox = true
    if selectedInputMechanism == SelectedInputMechanism.MapView {
      
      self.setOnMapLabel.text = "str_show_list".localized()
        
        self.clearButtonPickup.isHidden = true
        self.clearButtonDestination.isHidden = true

        if selectedTxtField == SelectedTextField.PickupAddress
        {
            print(self.pickUpTxt())
            self.txtPickAddress.tintColor = UIColor.white
            self.txtPickAddress.superview?.addExternalBorder(borderWidth: 2.0,
                                                   borderColor: UIColor.primary,
                                                   cornerRadius: 8.0)
            self.txtPickAddress.superview?.backgroundColor = UIColor.white
            self.txtDropAddress.superview?.removeExternalBorders()
            self.txtDropAddress.superview?.backgroundColor = UIColor.clear
            self.txtDropAddress.tintColor = UIColor.primary

        }
        else
        {
            self.txtDropAddress.superview?.addExternalBorder(borderWidth: 2.0,
                                                   borderColor: UIColor.primary,
                                                   cornerRadius: 8.0)
            self.txtDropAddress.superview?.backgroundColor = UIColor.white
            self.txtPickAddress.superview?.removeExternalBorders()
            self.txtPickAddress.superview?.backgroundColor = UIColor.clear
            self.txtDropAddress.tintColor = UIColor.white
            self.txtPickAddress.tintColor = UIColor.primary


        }
      if(zoomForPickupRequired)
      {
        zoomForPickupRequired = false
        updateMap(zoomLevel: KTCreateBookingConstants.PICKUP_MAP_ZOOM)
      }
      else
      {
        updateMap()
      }
    }
    
    toggleSkipButton()
    tab = .address
  }
  
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    textField.superview?.addExternalBorder(borderWidth: 2.0,
                                           borderColor: UIColor.primary,
                                           cornerRadius: 8.0)
    textField.superview?.backgroundColor = UIColor.white
    return true
  }
  
  func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
    if selectedTxtField == SelectedTextField.PickupAddress && (viewModel as! KTAddressPickerViewModel).pickUpAddress != nil {
        textField.text = getAddressName(location: (viewModel as! KTAddressPickerViewModel).pickUpAddress)
    }
    else if selectedTxtField == SelectedTextField.DropoffAddress && (viewModel as! KTAddressPickerViewModel).dropOffAddress != nil {
        textField.text = getAddressName(location: (viewModel as! KTAddressPickerViewModel).dropOffAddress)
    }
    
    textField.superview?.removeExternalBorders()
    textField.superview?.backgroundColor = UIColor.clear
    return true
  }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
  func textFieldDidEndEditing(_ textField: UITextField) {
    //print("---textFieldDidEndEditing---")
    clearButtonPickup.isHidden = true
    clearButtonDestination.isHidden = true
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    
//    if removeTxtFromTextBox == true {
//      removeTxtFromTextBox = false
//      textField.text = ""
//    }
      
    searchText = textField.text!;
      
      if textField.isEqual(txtDropAddress) {
          if searchText.count == 1 && string == ""{
              clearButtonPickup.isHidden = true
              clearButtonDestination.isHidden = true
          } else if searchText.count == 0 && string.count != 0 {
              clearButtonPickup.isHidden = true
              clearButtonDestination.isHidden = false
          } else if searchText.count > 0 {
              clearButtonPickup.isHidden = true
              clearButtonDestination.isHidden = false
          }else {
              clearButtonPickup.isHidden = true
              clearButtonDestination.isHidden = true
          }
      }
      
      if textField.isEqual(txtPickAddress) {
          if searchText.count == 1 && string == ""{
              clearButtonPickup.isHidden = true
              clearButtonDestination.isHidden = true
          } else if searchText.count == 0 && string.count != 0 {
              clearButtonPickup.isHidden = false
              clearButtonDestination.isHidden = true
          } else if searchText.count > 0 {
              clearButtonPickup.isHidden = false
              clearButtonDestination.isHidden = true
          } else {
              clearButtonPickup.isHidden = true
              clearButtonDestination.isHidden = true
          }
      }
      
    if searchTimer.isValid {
      
      searchTimer.invalidate()
    }
    if let txt = textField.text, txt.count >= MIN_ALLOWED_TEXT_COUNT_SEARCH {
      searchTimer = Timer.scheduledTimer(timeInterval: SEC_WAIT_START_SEARCH, target: self,   selector: (#selector(self.updateTimer)), userInfo: nil, repeats: false)
    }
    
    return true;
  }
  
  
  @objc func updateTimer() {
    print("OK Start searching now")
    
    if tab == .favorite {

    } else {
        (viewModel as! KTAddressPickerViewModel).fetchLocations(forSearch: searchText)
    }
    
  }
  func updateSelectedField(txt: UITextField) {
    
    if txt.isEqual(txtDropAddress) {
      searchText = txtDropAddress.text!
//      txtDropAddress.backgroundColor = SELECTED_TEXT_FIELD_COLOR
//      txtPickAddress.backgroundColor = UIColor.white
      imgMapMarker.image = UIImage(named: "APDropOffMarker")
      
      btnConfirm.setTitle("txt_confirm_dropoff".localized(), for: .normal)
    }
    else {
      searchText = txtPickAddress.text!
//      txtDropAddress.backgroundColor = UIColor.white
//      txtPickAddress.backgroundColor = SELECTED_TEXT_FIELD_COLOR
      imgMapMarker.image = UIImage(named: "APPickUpMarker")
      
      btnConfirm.setTitle("txt_confirm_pickup".localized(), for: .normal)
    }
  }
  
  //MARK: - Address Picker cell delegate
  func btnMoreTapped(withTag idx: Int) {
//
//    if tab == .favorite {
//
//      let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//      let cancelAction = UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil)
//        let editAction = UIAlertAction(title: "txt_edit".localized(), style: .default) { (UIAlertAction) in
//        (self.viewModel as! KTAddressPickerViewModel).editFavorite(forIndex: idx)
//      }
//        let removeAction = UIAlertAction(title: "str_remove".localized(), style: .default) { (UIAlertAction) in
//        (self.viewModel as! KTAddressPickerViewModel).removeFavorite(forIndex: idx)
//      }
//      alertController.addAction(cancelAction)
//      alertController.addAction(editAction)
//      alertController.addAction(removeAction)
//      self.present(alertController, animated: true, completion: nil)
//    }
//    else {
//      let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//      let cancelAction = UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil)
//      let homeAction = UIAlertAction(title: "set_as_home_address".localized(), style: .default) { (UIAlertAction) in
//        (self.viewModel as! KTAddressPickerViewModel).setHome(forIndex: idx)
//      }
//      let workAction = UIAlertAction(title: "set_as_work_address".localized(), style: .default) { (UIAlertAction) in
//        (self.viewModel as! KTAddressPickerViewModel).setWork(forIndex: idx)
//      }
//      let favoriteAction = UIAlertAction(title: "set_as_favorite".localized(), style: .default) { (UIAlertAction) in
//        (self.viewModel as! KTAddressPickerViewModel).setFavorite(forIndex: idx)
//      }
//
//      alertController.addAction(cancelAction)
//      let location = (self.viewModel as! KTAddressPickerViewModel).locationAtIndex(idx: idx)
//      if location.type == geoLocationType.Home.rawValue {
//        alertController.addAction(workAction)
//        alertController.addAction(favoriteAction)
//      }
//      else if location.type == geoLocationType.Work.rawValue {
//        alertController.addAction(homeAction)
//        alertController.addAction(favoriteAction)
//      }
//      else {
//        alertController.addAction(homeAction)
//        alertController.addAction(workAction)
//        alertController.addAction(favoriteAction)
//      }
//
//        alertController.modalTransitionStyle = .crossDissolve
//
//      self.present(alertController, animated: true, completion: nil)
//    }
//
  }

}


extension KTAddressPickerViewController {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 1
        }
        if (viewModel as! KTAddressPickerViewModel).numberOfRow(section: section) == 0 {
            return 1
        }
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let sectionHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.tblView.frame.width, height: 50))
        sectionHeaderView.backgroundColor = UIColor.white//(hexString: "#F9F9F9")
        let headerLabel = UILabel(frame: CGRect(x: 20, y: 20, width: self.tblView.frame.width-40, height: 30))
        if section == 0 {
            return nil
        } else if section == 1 {
            headerLabel.text = "\("favorites_title".localized())".uppercased()
        } else {
            headerLabel.text = "\("str_metro_title".localized())".uppercased()
        }
        
        if Device.getLanguage().contains("AR"){
            headerLabel.textAlignment = .right
        } else {
            headerLabel.textAlignment = .left
        }
        
        if (viewModel as! KTAddressPickerViewModel).numberOfRow(section: section) == 0 {
            return nil
        }
      
        headerLabel.textColor = UIColor(hexString: "#8EA8A7")
        headerLabel.font = UIFont(name: "MuseoSans-500", size: 10.0)!
        sectionHeaderView.addSubview(headerLabel)
        
        return sectionHeaderView
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if fromDropOff {
//            switch section {
//            case 0:
//                return 0
//            case 1:
//                return 0
//            case 2:
//                return (viewModel as! KTXpressAddressPickerViewModel).numberOfRow(section: section)
//            default:
//                return 0
//            }
//        }
        return (viewModel as! KTAddressPickerViewModel).numberOfRow(section: section)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
            
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : KTXpressAddressTableViewCell = tableView.dequeueReusableCell(withIdentifier: "KTXpressAddressTableViewCell") as! KTXpressAddressTableViewCell

        cell.titleLabel.text = (viewModel as! KTAddressPickerViewModel).addressTitle(forIndex: indexPath)
        
        cell.icon.image = (viewModel as! KTAddressPickerViewModel).addressTypeIcon(forIndex: indexPath)
        
        cell.moreButton.setImage((viewModel as! KTAddressPickerViewModel).moreButtonIcon(forIndex: indexPath), for: .normal)

        if indexPath.section == 1 {
            if let bookmarks = (viewModel as? KTAddressPickerViewModel)?.bookmarks {
                if indexPath.row < bookmarks.count  {
                    cell.moreButton.isHidden = false
                } else {
                    cell.moreButton.isHidden = true
                }
            }
        } else {
            cell.moreButton.isHidden = false
        }
            
        if indexPath.section != 2 {
            if (viewModel as! KTAddressPickerViewModel).addressArea(forIndex: indexPath).count > 0 {
                cell.addressLabel.isHidden = false
                cell.addressLabel.text = (viewModel as! KTAddressPickerViewModel).addressArea(forIndex: indexPath)
            } else {
                cell.addressLabel.isHidden = true
            }
            cell.icon.customCornerRadius = cell.icon.frame.width/2
        } else {
            cell.icon.customCornerRadius = 0
            cell.addressLabel.isHidden = true
        }
        
        cell.moreButton.addTarget(self, action: #selector(showActionSheet(sender:)), for: .touchUpInside)
        cell.moreButton.contentMode = .center
        
        cell.moreButton.tag = indexPath.row
        cell.delegate = self
        
        return cell
        
    }
    
    @objc func showActionSheet(sender: UIButton) {
        guard let cell = sender.superview?.superview as? KTXpressAddressTableViewCell else {
            return // or fatalError() or whatever
        }
        
        let indexPath = tblView.indexPath(for: cell)
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil)
        let homeAction = UIAlertAction(title: "set_as_home_address".localized(), style: .default) { (UIAlertAction) in
            (self.viewModel as! KTAddressPickerViewModel).setHome(forIndex: indexPath!)
        }
        let workAction = UIAlertAction(title: "set_as_work_address".localized(), style: .default) { (UIAlertAction) in
            (self.viewModel as! KTAddressPickerViewModel).setWork(forIndex: indexPath!)
        }
        let favoriteAction = UIAlertAction(title: "set_as_favorite".localized(), style: .default) { (UIAlertAction) in
            (self.viewModel as! KTAddressPickerViewModel).setFavorite(forIndex: indexPath!)
        }
        
        alertController.addAction(cancelAction)
        
        if let location = (self.viewModel as! KTAddressPickerViewModel).locationAtIndexPath(indexPath: indexPath!, type: selectedTxtField, fromActionSheet: true) as? KTGeoLocation {
            if location.type == geoLocationType.Home.rawValue {
                alertController.addAction(workAction)
                alertController.addAction(favoriteAction)
            }
            else if location.type == geoLocationType.Work.rawValue {
                alertController.addAction(homeAction)
                alertController.addAction(favoriteAction)
            }else if location.type == geoLocationType.favorite.rawValue {
                
                if indexPath?.section ?? 0 == 1 {
                      let editAction = UIAlertAction(title: "txt_edit".localized(), style: .default) { (UIAlertAction) in
                          (self.viewModel as! KTAddressPickerViewModel).editFavorite(forIndex: indexPath?.row ?? 0)
                    }
                      let removeAction = UIAlertAction(title: "str_remove".localized(), style: .default) { (UIAlertAction) in
                          (self.viewModel as! KTAddressPickerViewModel).removeFavorite(forIndex: indexPath?.row ?? 0)
                    }
                    alertController.addAction(editAction)
                    alertController.addAction(removeAction)
                }
                
                
                alertController.addAction(homeAction)
                alertController.addAction(workAction)
            }
            else {
                alertController.addAction(homeAction)
                alertController.addAction(workAction)
                alertController.addAction(favoriteAction)
            }
            alertController.modalTransitionStyle = .crossDissolve
            self.present(alertController, animated: true, completion: nil)
        } else {
            (viewModel as! KTAddressPickerViewModel).saveFavoriteMetroStations(metro: metroStations[indexPath!.row])
            self.getFavouriteMetroStations()
            self.tblView.reloadData()
        }
        
        
    }
    
    fileprivate func getFavouriteMetroStations() {
        (viewModel as! KTAddressPickerViewModel).favoriteMetroStation.removeAll()
        for itm in metroStations {
            if KTBookmarkManager().getXpressFavorite(code: itm.code ?? 0) == true {
                if (viewModel as! KTAddressPickerViewModel).favoriteMetroStation.contains(itm) == false {
                    (viewModel as! KTAddressPickerViewModel).favoriteMetroStation.append(itm)
                }
            }
        }
    }
    
    func toGeolocation(area: Area) -> KTGeoLocation {
        let location = KTGeoLocation(context: NSManagedObjectContext.mr_default())
        location.area = metroStations.first?.name
        
        let coordinates = (area.bound?.components(separatedBy: ";").map{$0.components(separatedBy: ",")}.map{$0.map({Double($0)!})}.map { (value) -> CLLocationCoordinate2D in
            return CLLocationCoordinate2D(latitude: value[0], longitude: value[1])
        })!
        location.latitude = coordinates.first!.latitude
        location.longitude = coordinates.first!.longitude
        location.name = area.name
        location.locationId = Int32((area.code)!)
        location.type = 0
        location.favoriteName = area.name ?? ""
        return location
    }
  
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)
        
        if self.metroStations.count == 0 {
            (viewModel as! KTAddressPickerViewModel).didSelectRow(at:indexPath, type: selectedTxtField)
        } else {
            let type = selectedTxtField
            valueChanged = true
            if selectedTxtField == .PickupAddress {
                selectedRSPickStop = nil
                selectedRSPickZone = nil
                selectedRSPickStation = nil
            } else {
                selectedRSDropStop = nil
                selectedRSDropZone = nil
                selectedRSDropStation = nil
            }
            
            self.setLocation(location: (self.viewModel as! KTAddressPickerViewModel).locationAtIndexPath(indexPath: indexPath, type: selectedTxtField, fromActionSheet: false), type: type)
        }
    }
    
    func setLocation(location: Any, type: SelectedTextField) {
        if let loc = location as? KTGeoLocation {
            print(location)
            let actualLocation = CLLocation(latitude: loc.latitude, longitude: loc.longitude)
            if checkLatLonInside(location: actualLocation) {
                KTLocationManager.sharedInstance.setCurrentLocation(location: actualLocation)
                switch type {
                case .PickupAddress:
                    selectedRSPickUpCoordinate = CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude)
                    self.getDestinationForPickUp()
                    txtDropAddress.isUserInteractionEnabled = true
                    txtDropAddress.becomeFirstResponder()
                    selectedRSDropStop = nil
                    selectedRSDropZone = nil
                    selectedRSDropStation = nil
                    selectedRSDropOffCoordinate = nil
                case .DropoffAddress:
                    selectedRSDropOffCoordinate = CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude)
                    self.setDropLocations()
                    txtPickAddress.isUserInteractionEnabled = true
                }
            } else {
                switch type {
                case .PickupAddress:
                    txtPickAddress.becomeFirstResponder()
                    txtDropAddress.isUserInteractionEnabled = false
                case .DropoffAddress:
                    txtDropAddress.becomeFirstResponder()
                }
                
//                self.showErrorBanner("", "str_outzone".localized())

                self.view.endEditing(true)
                self.showToast(message: "str_outzone".localized())
            }

        } else {
            if let loc = location as? Area {
                print(location)
                let metroAreaCoordinate = getCenterPointOfPolygon(bounds: loc.bound!)
                if type == .PickupAddress {
                    selectedRSPickUpCoordinate = CLLocationCoordinate2D(latitude: metroAreaCoordinate.latitude, longitude: metroAreaCoordinate.longitude)
                    if loc.type! == "Zone" {
                        selectedRSPickZone = loc
                    } else {
                        selectedRSPickStation = loc
                        let stopOfStations = areas.filter{$0.parent == selectedRSPickStation?.code}
                        selectedRSPickStop = stopOfStations.first!
                        selectedRSPickZone = areas.filter{$0.code == selectedRSPickStation?.parent}.first!
                    }
                    txtDropAddress.isUserInteractionEnabled = true
                    txtDropAddress.becomeFirstResponder()
                    self.getDestinationForPickUp()
                    self.tblView.reloadData()
                }
                
//                switch type {
//                case .PickupAddress:
//
//                case .DropoffAddress:
////                    selectedRSDropOffCoordinate = CLLocationCoordinate2D(latitude: metroAreaCoordinate.latitude, longitude: metroAreaCoordinate.longitude)
////                    if loc.type! == "Zone" {
////                        selectedRSDropZone = loc
////                    } else {
////                        selectedRSDropStation = loc
////                        let stopOfStations = areas.filter{$0.parent == selectedRSDropStation?.code}
////                        selectedRSDropStop = stopOfStations.first!
////                        selectedRSDropZone = areas.filter{$0.code == selectedRSDropStation?.parent}.first!
////                    }
////                    txtDropAddress.isUserInteractionEnabled = true
////                    self.setDropLocations()
//                    break
//                }
                
    
            }
        }
    }
    
    fileprivate func setPickUpLocations() {
        if selectedRSPickZone == nil {
            for item in zones {
                let coordinates = (item.bound?.components(separatedBy: ";").map{$0.components(separatedBy: ",")}.map{$0.map({Double($0)!})}.map { (value) -> CLLocationCoordinate2D in
                    return CLLocationCoordinate2D(latitude: value[0], longitude: value[1])
                })!
                if  CLLocationCoordinate2D(latitude: selectedRSPickUpCoordinate?.latitude ?? 0.0, longitude: selectedRSPickUpCoordinate?.longitude ?? 0.0).contained(by: coordinates) {
                    selectedRSPickZone = item
                    break
                }
                
            }
        }
        
        if selectedRSPickStation == nil {
            if selectedRSPickZone != nil {
                let stationsOfZone = zonalArea.filter{$0["zone"]?.first!.code == selectedRSPickZone!.code}.first!["stations"]
                for item in stationsOfZone! {
                    let coordinates = (item.bound?.components(separatedBy: ";").map{$0.components(separatedBy: ",")}.map{$0.map({Double($0)!})}.map { (value) -> CLLocationCoordinate2D in
                        return CLLocationCoordinate2D(latitude: value[0], longitude: value[1])
                    })!
                    if  CLLocationCoordinate2D(latitude: selectedRSPickUpCoordinate?.latitude ?? 0.0, longitude: selectedRSPickUpCoordinate?.longitude ?? 0.0).contained(by: coordinates) {
                        selectedRSPickStation = item
                        break
                    }
                }
            }
        }
        
        if selectedRSPickStation != nil {
            if selectedRSPickStop == nil {
                selectedRSPickStop = stops.filter{$0.parent == selectedRSPickStation?.code}.first!
            }
            selectedRSPickUpCoordinate = getCenterPointOfPolygon(bounds: selectedRSPickStation?.bound! ?? "")
        }
        
    }
    
    fileprivate func setDropLocations() {
        if selectedRSDropZone == nil {
            for item in zones {
                let coordinates = (item.bound?.components(separatedBy: ";").map{$0.components(separatedBy: ",")}.map{$0.map({Double($0)!})}.map { (value) -> CLLocationCoordinate2D in
                    return CLLocationCoordinate2D(latitude: value[0], longitude: value[1])
                })!
                if  CLLocationCoordinate2D(latitude: selectedRSDropOffCoordinate?.latitude ?? 0.0, longitude: selectedRSDropOffCoordinate?.longitude ?? 0.0).contained(by: coordinates) {
                    selectedRSDropZone = item
                    break
                }
                
            }
        }
        
        if selectedRSDropStation == nil {
            let stationsOfZone = zonalArea.filter{$0["zone"]?.first!.code == selectedRSDropZone!.code}.first!["stations"]
            for item in stationsOfZone! {
                let coordinates = (item.bound?.components(separatedBy: ";").map{$0.components(separatedBy: ",")}.map{$0.map({Double($0)!})}.map { (value) -> CLLocationCoordinate2D in
                    return CLLocationCoordinate2D(latitude: value[0], longitude: value[1])
                })!
                if  CLLocationCoordinate2D(latitude: selectedRSDropOffCoordinate?.latitude ?? 0.0, longitude: selectedRSDropOffCoordinate?.longitude ?? 0.0).contained(by: coordinates) {
                    selectedRSDropStation = item
                    break
                }
            }
        }
        
        if selectedRSDropStation != nil {
            if selectedRSDropStop == nil {
                selectedRSDropStop = stops.filter{$0.parent == selectedRSDropStation?.code}.first!
            }
            selectedRSDropOffCoordinate = getCenterPointOfPolygon(bounds: selectedRSDropStation?.bound! ?? "")
        }
    }
    
    func getDestinationForPickUp() {
            setPickUpLocations()
            var customDestinationsCode = [Int]()
            destinationForPickUp = [Area]()
            destinationForPickUp.removeAll()
            if selectedRSPickStation != nil {
                if customDestinationsCode.count == 0 {
                    customDestinationsCode = destinations.filter{$0.source == selectedRSPickStation?.code!}.map{$0.destination!}
                }
                for item in customDestinationsCode {
                    destinationForPickUp.append(contentsOf: areas.filter{$0.code! == item})
                }
                print("destinationForPickUp", destinationForPickUp)
            } else {
                if customDestinationsCode.count == 0 {
                    customDestinationsCode = destinations.filter{$0.source == selectedRSPickZone?.code!}.map{$0.destination!}
                }
                for item in customDestinationsCode {
                    destinationForPickUp.append(contentsOf: areas.filter{$0.code! == item})
                }
                print("destinationForPickUp", destinationForPickUp)
                            
            }
        
        (viewModel as! KTAddressPickerViewModel).metroStations = self.destinationForPickUp
        getFavouriteMetroStations()
        
        self.tblView.reloadData()
    }
//    func loadData() {
//        self.tableView.reloadData()
//    }
//
//    func pickUpTxt() -> String {
//        return self.textField.text!
//    }
//
//    func dropOffTxt() -> String {
//        return self.textField.text!
//    }
    
//    func setPickUp(pick: String) {
//        self.textField.text = pick
//    }
//
//    func setDropOff(drop: String) {
//        self.textField.text = drop
//    }
    
//    func moveFocusToDestination() {
//
//    }
//
//    func moveFocusToPickUp() {
//
//    }
    
    
//    func navigateToFavoriteScreen(location: KTGeoLocation?) {
//        let vc = KTXpressFavoriteAddressViewController()
//        vc.favoritelocation = location
//        vc.xpressFavoriteDelegate = self
//        self.present(vc, animated: true, completion: nil)
//    }
    
//    func btnMoreTapped(withTag idx: Int) {
//
//    }
    
}


public func getAddressName(location: Any?) -> String {
    if let loc = location as? KTGeoLocation {
        return loc.name ?? ""
    } else {
        if let loc = location as? Area  {
            return loc.name ?? ""
        }
    }
    return ""
}

public func getCoordinates(location: Any?) -> CLLocationCoordinate2D {
    if let loc = location as? KTGeoLocation {
        return CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude)
    } else {
        if let loc = location as? Area  {
            return CLLocationCoordinate2D(latitude:  getCenterPointOfPolygon(bounds: loc.bound!).latitude, longitude: getCenterPointOfPolygon(bounds: loc.bound!).longitude)
        }
    }
    return CLLocationCoordinate2D(latitude:  0.0, longitude: 0.0)
}
