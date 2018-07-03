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

let MIN_ALLOWED_TEXT_COUNT_SEARCH  = 3
let SEC_WAIT_START_SEARCH = 1.5
let SELECTED_TEXT_FIELD_COLOR : UIColor = UIColor(hexString: "#F5F5F5")

class KTAddressPickerViewController: KTBaseViewController,KTAddressPickerViewModelDelegate,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,GMSMapViewDelegate, AddressPickerCellDelegate {
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var txtPickAddress: UITextField!
    @IBOutlet weak var txtDropAddress: UITextField!
    @IBOutlet weak var imgListSelected : UIImageView!
    @IBOutlet weak var imgMapSelected : UIImageView!
    @IBOutlet weak var mapView : GMSMapView!
    @IBOutlet weak var mapSuperView : UIView!
    @IBOutlet weak var imgMapMarker : UIImageView!
    
    @IBOutlet weak var btnHome : UIButton!
    @IBOutlet weak var btnWork : UIButton!
    @IBOutlet weak var btnConfirm : UIButton!
    
    @IBOutlet weak var constraintTableViewBottom : NSLayoutConstraint!
    
    public var pickupAddress : KTGeoLocation?
    public var dropoffAddress : KTGeoLocation?
    
    public weak var previousView : KTCreateBookingViewModel?
    
    private var searchTimer: Timer = Timer()
    private var searchText : String = ""
    
    public var selectedTxtField : SelectedTextField = SelectedTextField.DropoffAddress
    private var selectedInputMechanism : SelectedInputMechanism = SelectedInputMechanism.ListView
    
    
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(KTAddressPickerViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(KTAddressPickerViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print("Table view scroll detected at offset: %f", scrollView.contentOffset.y)
        txtPickAddress.resignFirstResponder()
        txtDropAddress.resignFirstResponder()
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
//            if self.view.frame.origin.y == 0{
//                self.view.frame.origin.y -= keyboardSize.height/2
//            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            
            constraintTableViewBottom.constant = 0
//            if self.view.frame.origin.y != 0{
//                self.view.frame.origin.y += keyboardSize.height/2
//            }
        }
    }

    
    //MARK: - Map related functions.
    private func initializeMap () {
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
        
    }
    
    private func updateMap() {
        
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
        
        let update :GMSCameraUpdate = GMSCameraUpdate.setTarget(focusLocation, zoom: KTCreateBookingConstants.DEFAULT_MAP_ZOOM)
        mapView.animate(with: update)
        
    }
    
    //TODO: - Delete this function 
    /*private func addMap() {
        
        var focusLocation : CLLocationCoordinate2D  = (viewModel as! KTAddressPickerViewModel).currentLocation()
        
        if selectedTxtField == SelectedTextField.DropoffAddress {
            //If focus is on Dropoff Address.
            if (viewModel as! KTAddressPickerViewModel).dropOffAddress != nil  {
                //If dropoff is not empty.
                focusLocation = CLLocationCoordinate2D(latitude: ((viewModel as! KTAddressPickerViewModel).dropOffAddress?.latitude)!, longitude: ((viewModel as! KTAddressPickerViewModel).dropOffAddress?.longitude)!)
            }
            
        }
        else {
            //If focus is on Pickup
            if (viewModel as! KTAddressPickerViewModel).pickUpAddress != nil  {
                //If dropoff is not empty.
                focusLocation = CLLocationCoordinate2D(latitude: ((viewModel as! KTAddressPickerViewModel).pickUpAddress?.latitude)!, longitude: ((viewModel as! KTAddressPickerViewModel).pickUpAddress?.longitude)!)
            }
            
        }
        
        
        let camera = GMSCameraPosition.camera(withLatitude: focusLocation.latitude, longitude: focusLocation.longitude, zoom: 14.0)
        
        //showCurrentLocationDot(show: true)
        
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
    }*/
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        enableButtons()
        if selectedInputMechanism == SelectedInputMechanism.MapView {
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
    
    @IBAction func btnConfirmTapped(_ sender: Any) {
        
        (viewModel as! KTAddressPickerViewModel).confimMapSelection()
    }
    
    @IBAction func btnSkipTapped(_ sender: Any) {
        
        (viewModel as! KTAddressPickerViewModel).skipDestination()
    }
    
    @IBAction func btnSetWorkTapped(_ sender: Any) {
        
        (viewModel as! KTAddressPickerViewModel).btnSetWorkTapped()
    }
    
    @IBAction func btnSetHomeTapped(_ sender: Any) {
        
        (viewModel as! KTAddressPickerViewModel).btnSetHomeTapped()
    }
    
    //MARK: - MAP/ LIST Selected
    
    @IBAction func btnListViewTapped(_ sender: Any) {
        
        imgListSelected.isHidden = false
        imgMapSelected.isHidden = true
        
        self.tblView.isHidden = false
        self.mapSuperView.isHidden = true
        
        txtDropAddress.inputView = nil
        txtPickAddress.inputView = nil
        
        selectedInputMechanism = SelectedInputMechanism.ListView
        
        txtPickAddress.tintColor = UIColor(hexString:"#006170")
        txtPickAddress.backgroundColor = UIColor.white
        txtDropAddress.tintColor = UIColor(hexString:"#006170")
        txtDropAddress.backgroundColor = UIColor.white
        
        if selectedTxtField == SelectedTextField.PickupAddress {
            txtPickAddress.becomeFirstResponder()
        }
        else {
            
            txtDropAddress.becomeFirstResponder()
        }
    }
    
    @IBAction func btnMapViewTapped(_ sender: Any) {
        selectedInputMechanism = SelectedInputMechanism.MapView
        
        updateMap()
        
        imgListSelected.isHidden = true
        imgMapSelected.isHidden = false
        
        
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
        
        txtPickAddress.tintColor = SELECTED_TEXT_FIELD_COLOR
        txtDropAddress.tintColor = SELECTED_TEXT_FIELD_COLOR
        
        if selectedTxtField == SelectedTextField.PickupAddress {
            
           txtPickAddress.backgroundColor = SELECTED_TEXT_FIELD_COLOR
        }
        else {
            
           txtDropAddress.backgroundColor = SELECTED_TEXT_FIELD_COLOR
        }
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
    
    func pickUpTxt() -> String {
        return self.txtPickAddress.text!
    }
    
    func dropOffTxt() -> String {
        return self.txtDropAddress.text!
    }
    func setPickUp(pick: String) {
        txtPickAddress.text = pick
    }
    
    func setDropOff(drop: String) {
        txtDropAddress.text = drop
    }
    
    // MARK: - TableView Delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (viewModel as! KTAddressPickerViewModel).numberOfRow(section: section)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : AddressPickCell = tableView.dequeueReusableCell(withIdentifier: "AddPickCellIdentifier", for: indexPath) as! AddressPickCell
            /*AddressPickCell(style: UITableViewCellStyle.default, reuseIdentifier: "AddPickCellIdentifier")*/
        
        cell.addressTitle.text = (viewModel as! KTAddressPickerViewModel).addressTitle(forIndex: indexPath)
        cell.addressArea.text = (viewModel as! KTAddressPickerViewModel).addressArea(forIndex: indexPath)
        
        cell.ImgTypeIcon.image = (viewModel as! KTAddressPickerViewModel).addressTypeIcon(forIndex: indexPath)
        
        cell.btnMore.tag = indexPath.row
        cell.delegate = self
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
        }
        else {
            
            selectedTxtField = SelectedTextField.PickupAddress
        }
        
        (viewModel as! KTAddressPickerViewModel).txtFieldSelectionChanged()
        
        
        removeTxtFromTextBox = true
        if selectedInputMechanism == SelectedInputMechanism.MapView {
            
            updateMap()
            
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if selectedTxtField == SelectedTextField.PickupAddress && (viewModel as! KTAddressPickerViewModel).pickUpAddress != nil {
            
            textField.text = (viewModel as! KTAddressPickerViewModel).pickUpAddress?.name
        }
        else if selectedTxtField == SelectedTextField.DropoffAddress && (viewModel as! KTAddressPickerViewModel).dropOffAddress != nil {
            
            textField.text = (viewModel as! KTAddressPickerViewModel).dropOffAddress?.name
        }
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        //print("---textFieldDidEndEditing---")
        
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
            txtDropAddress.backgroundColor = SELECTED_TEXT_FIELD_COLOR
            txtPickAddress.backgroundColor = UIColor.white
            imgMapMarker.image = UIImage(named: "APDropOffMarker")
        }
        else {
            searchText = txtPickAddress.text!
            txtDropAddress.backgroundColor = UIColor.white
            txtPickAddress.backgroundColor = SELECTED_TEXT_FIELD_COLOR
            imgMapMarker.image = UIImage(named: "APPickUpMarker")
        }
    }
    
    //MARK: - Address Picker cell delegate
    func btnMoreTapped(withTag idx: Int) {
        
        
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let homeAction = UIAlertAction(title: "Set Home", style: .default) { (UIAlertAction) in
            (self.viewModel as! KTAddressPickerViewModel).setHome(forIndex: idx)
        }
        let workAction = UIAlertAction(title: "Set Work", style: .default) { (UIAlertAction) in
            (self.viewModel as! KTAddressPickerViewModel).setWork(forIndex: idx)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(homeAction)
        alertController.addAction(workAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
