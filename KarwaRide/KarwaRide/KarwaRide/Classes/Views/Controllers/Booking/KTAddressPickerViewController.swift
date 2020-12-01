//
//  KTAddressPickerViewController.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 1/23/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
import GoogleMaps

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
KTAddressPickerViewModelDelegate,
UITableViewDelegate,
UITableViewDataSource,
UITextFieldDelegate,
GMSMapViewDelegate,
AddressPickerCellDelegate {
  
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
    viewModel = KTAddressPickerViewModel(del:self)
    
    (viewModel as! KTAddressPickerViewModel).pickUpAddress = pickupAddress
    
    if dropoffAddress != nil {
      
      (viewModel as! KTAddressPickerViewModel).dropOffAddress = dropoffAddress
    }
    
    //Do not move these line after super.viewDidLoad
    super.viewDidLoad()
    setupUI()
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
    switch selectedTxtField {
    case .PickupAddress:
      skipButton.isHidden = true
    case .DropoffAddress:
      skipButton.isHidden = false
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
  }
  
  @IBAction func clearActionDropoff(_ sender: Any) {
    (viewModel as! KTAddressPickerViewModel).dropoffAddressClearedAction()
    txtDropAddress.text = ""
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
    
    initializeMap()
  }
  
  //MARK: - Notification
  @objc func keyboardWillShow(notification: NSNotification) {
    if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size {
      
      constraintTableViewBottom.constant = keyboardSize.height

    }
  }
  
  @objc func keyboardWillHide(notification: NSNotification) {
    if ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) != nil {

      constraintTableViewBottom.constant = 0

    }
  }
  
  
  //MARK: - Map related functions.
  private func initializeMap () {
    
    self.mapView.isMyLocationEnabled = true
    
    var focusLocation : CLLocationCoordinate2D  = (viewModel as! KTAddressPickerViewModel).currentLocation()
    
    if selectedTxtField == SelectedTextField.PickupAddress {
      
      if (viewModel as! KTAddressPickerViewModel).pickUpAddress != nil {
        focusLocation = CLLocationCoordinate2D(latitude: ((viewModel as! KTAddressPickerViewModel).pickUpAddress?.latitude)!, longitude: ((viewModel as! KTAddressPickerViewModel).pickUpAddress?.longitude)!)
      }
    }
    else {
      if (viewModel as! KTAddressPickerViewModel).dropOffAddress != nil {
        
        focusLocation = CLLocationCoordinate2D(latitude: ((viewModel as! KTAddressPickerViewModel).dropOffAddress?.latitude)!, longitude: ((viewModel as! KTAddressPickerViewModel).dropOffAddress?.longitude)!)
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
    
    self.imgMapMarker.frame = CGRect(x: self.imgMapMarker.frame.origin.x, y: self.imgMapMarker.frame.origin.y - 45, width: self.imgMapMarker.frame.size.width, height: self.imgMapMarker.frame.size.height)
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
        focusLocation = CLLocationCoordinate2D(latitude: ((viewModel as! KTAddressPickerViewModel).pickUpAddress?.latitude)!, longitude: ((viewModel as! KTAddressPickerViewModel).pickUpAddress?.longitude)!)
      }
    }
    else {
      if (viewModel as! KTAddressPickerViewModel).dropOffAddress != nil
      {
        focusLocation = CLLocationCoordinate2D(latitude: ((viewModel as! KTAddressPickerViewModel).dropOffAddress?.latitude)!, longitude: ((viewModel as! KTAddressPickerViewModel).dropOffAddress?.longitude)!)
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
      self.txtDropAddress.becomeFirstResponder()
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.25)
      {
        self.txtPickAddress.becomeFirstResponder()
      }
    }
    else
    {
      self.txtPickAddress.becomeFirstResponder()
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.25)
      {
        self.txtDropAddress.becomeFirstResponder()
      }
    }
  }
  
  func toggleConfirmBtn(enableBtn enable : Bool)
  {
    btnConfirm.isEnabled = enable
  }
  
  @IBAction func btnMapViewTapped(_ sender: Any)
  {
    toggleToMapView()
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
  
  func inFocusTextField() -> SelectedTextField {
    
    return selectedTxtField
  }
  
  func loadData() {
    tblView.reloadData()
  }
  
  func navigateToPreviousView(pickup: KTGeoLocation?, dropOff: KTGeoLocation?) {
    if pickup != nil {
      
      previousView?.setPickAddress(pAddress: pickup!)
    }
    if dropOff != nil {
      
      previousView?.setDropAddress(dAddress: dropOff!)
    }
    else {
      previousView?.setSkipDropOff()
    }
    
    previousView?.dismiss()
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
  
  func navigateToFavoriteScreen(location: KTGeoLocation?) {
    let vc = KTFavoriteAddressViewController()
    vc.favoritelocation = location
    vc.modalPresentationStyle = .fullScreen
    self.present(vc, animated: true, completion: nil)
  }
  
  func refineDropOff()
  {
    // refine the drop-off which is disturbed.
    
    if (viewModel as! KTAddressPickerViewModel).dropOffAddress != nil
    {
      setDropOff(drop: ((viewModel as! KTAddressPickerViewModel).dropOffAddress?.name)!)
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
    
    txtPickAddress.text = pick
  }
  
  func setDropOff(drop: String) {
    txtDropAddress.text = drop
  }
  
  // MARK: - TableView Delegates
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return (viewModel as! KTAddressPickerViewModel).numberOfRow(section: section)
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell : AddressPickCell = tableView.dequeueReusableCell(withIdentifier: "AddPickCellIdentifier", for: indexPath) as! AddressPickCell
    /*AddressPickCell(style: UITableViewCellStyle.default, reuseIdentifier: "AddPickCellIdentifier")*/
    
    cell.addressTitle.text = (viewModel as! KTAddressPickerViewModel).addressTitle(forIndex: indexPath)
    cell.addressArea.text = (viewModel as! KTAddressPickerViewModel).addressArea(forIndex: indexPath)
    
    cell.ImgTypeIcon.image = (viewModel as! KTAddressPickerViewModel).addressTypeIcon(forIndex: indexPath)
    
    cell.btnMore.tag = indexPath.row

    cell.delegate = self
    
//    animateCell(cell)
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    (viewModel as! KTAddressPickerViewModel).didSelectRow(at:indexPath.row, type:selectedTxtField)
  }
  
  // MARK: - UItextField Delegates
  
  func textFieldDidBeginEditing(_ textField: UITextField){
    if selectedInputMechanism == SelectedInputMechanism.MapView {
      
      updateSelectedField(txt:textField)
      
    }
    
    if textField.isEqual(txtDropAddress) {
      selectedTxtField = SelectedTextField.DropoffAddress
      titleLabel.text = "txt_set_drop_off".localized()
      clearButtonPickup.isHidden = true
      clearButtonDestination.isHidden = false
    }
    else {
      selectedTxtField = SelectedTextField.PickupAddress
      titleLabel.text = "txt_pick_up".localized()
      clearButtonPickup.isHidden = false
      clearButtonDestination.isHidden = true
    }
    
    (viewModel as! KTAddressPickerViewModel).txtFieldSelectionChanged()
    
    
    removeTxtFromTextBox = true
    if selectedInputMechanism == SelectedInputMechanism.MapView {
      
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
      
      textField.text = (viewModel as! KTAddressPickerViewModel).pickUpAddress?.name
    }
    else if selectedTxtField == SelectedTextField.DropoffAddress && (viewModel as! KTAddressPickerViewModel).dropOffAddress != nil {
      
      textField.text = (viewModel as! KTAddressPickerViewModel).dropOffAddress?.name
    }
    
    textField.superview?.removeExternalBorders()
    textField.superview?.backgroundColor = UIColor.clear
    return true
  }
  func textFieldDidEndEditing(_ textField: UITextField) {
    //print("---textFieldDidEndEditing---")
    clearButtonPickup.isHidden = true
    clearButtonDestination.isHidden = true
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    
    if removeTxtFromTextBox == true {
      removeTxtFromTextBox = false
      textField.text = ""
    }
    searchText = textField.text!;
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
    
    (viewModel as! KTAddressPickerViewModel).fetchLocations(forSearch: searchText)
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
    
    if tab == .favorite {
      
      let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
      let cancelAction = UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil)
      let editAction = UIAlertAction(title: "Edit", style: .default) { (UIAlertAction) in
        (self.viewModel as! KTAddressPickerViewModel).editFavorite(forIndex: idx)
      }
      let removeAction = UIAlertAction(title: "Remove", style: .default) { (UIAlertAction) in
        (self.viewModel as! KTAddressPickerViewModel).removeFavorite(forIndex: idx)
      }
      alertController.addAction(cancelAction)
      alertController.addAction(editAction)
      alertController.addAction(removeAction)
      self.present(alertController, animated: true, completion: nil)
    }
    else {
      let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
      let cancelAction = UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil)
      let homeAction = UIAlertAction(title: "set_as_home_address".localized(), style: .default) { (UIAlertAction) in
        (self.viewModel as! KTAddressPickerViewModel).setHome(forIndex: idx)
      }
      let workAction = UIAlertAction(title: "set_as_work_address".localized(), style: .default) { (UIAlertAction) in
        (self.viewModel as! KTAddressPickerViewModel).setWork(forIndex: idx)
      }
      let favoriteAction = UIAlertAction(title: "set_as_favorite".localized(), style: .default) { (UIAlertAction) in
        (self.viewModel as! KTAddressPickerViewModel).setFavorite(forIndex: idx)
      }
      
      alertController.addAction(cancelAction)
      let location = (self.viewModel as! KTAddressPickerViewModel).locationAtIndex(idx: idx)
      if location.type == geoLocationType.Home.rawValue {
        alertController.addAction(workAction)
        alertController.addAction(favoriteAction)
      }
      else if location.type == geoLocationType.Work.rawValue {
        alertController.addAction(homeAction)
        alertController.addAction(favoriteAction)
      }
      else {
        alertController.addAction(homeAction)
        alertController.addAction(workAction)
        alertController.addAction(favoriteAction)
      }
      self.present(alertController, animated: true, completion: nil)
    }

  }
}
