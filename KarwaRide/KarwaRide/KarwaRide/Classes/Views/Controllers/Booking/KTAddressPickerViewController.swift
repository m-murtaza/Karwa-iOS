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
class KTAddressPickerViewController: KTBaseViewController,KTAddressPickerViewModelDelegate,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,GMSMapViewDelegate {
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var txtPickAddress: UITextField!
    @IBOutlet weak var txtDropAddress: UITextField!
    @IBOutlet weak var imgListSelected : UIImageView!
    @IBOutlet weak var imgMapSelected : UIImageView!
    @IBOutlet weak var mapView : GMSMapView!
    @IBOutlet weak var mapSuperView : UIView!
    @IBOutlet weak var imgMapMarker : UIImageView!
    
    public var pickupAddress : KTGeoLocation?
    public var droffAddress : KTGeoLocation?
    
    public weak var previousView : KTCreateBookingViewModel?
    
    //private var selectedTxtField : SelectedTextField = SelectedTextField.DropoffAddress
    private var searchTimer: Timer = Timer()
    private var searchText : String = ""
    
    let selectedTxtFieldColor : UIColor = UIColor(hexString: "#F5F5F5")
    
    override func viewDidLoad() {
        viewModel = KTAddressPickerViewModel(del:self)
        (viewModel as! KTAddressPickerViewModel).pickUpAddress = pickupAddress
        super.viewDidLoad()
        
        addMap()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.txtDropAddress.becomeFirstResponder()
    }
    
    //MARK: - Map related functions.
    private func addMap() {
        
        let camera = GMSCameraPosition.camera(withLatitude: (viewModel as! KTAddressPickerViewModel).currentLatitude(), longitude: (viewModel as! KTAddressPickerViewModel).currentLongitude(), zoom: 14.0)
        
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
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        //print("Idel Position")
        (viewModel as! KTAddressPickerViewModel).MapStopMoving(location: mapView.camera.target)
    }
    
//    func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
//        print("End Draging")
//    }
    
    //MARK: - User Actions
    
    @IBAction func btnConfirmTapped(_ sender: Any) {
        
        (viewModel as! KTAddressPickerViewModel).confimMapSelection()
    }
    
    @IBAction func btnSkipTapped(_ sender: Any) {
        
        (viewModel as! KTAddressPickerViewModel).skipDestination()
    }
    //MARK: - MAP/ LIST Selected
    
    @IBAction func btnListViewTapped(_ sender: Any) {
        
        imgListSelected.isHidden = false
        imgMapSelected.isHidden = true
        //self.txtDropAddress.becomeFirstResponder()
        self.tblView.isHidden = false
        self.mapSuperView.isHidden = true
        
        txtDropAddress.inputView = nil
        txtPickAddress.inputView = nil
    }
    
    @IBAction func btnMapViewTapped(_ sender: Any) {
        
        imgListSelected.isHidden = true
        imgMapSelected.isHidden = false
        
        
        self.tblView.isHidden = true
        self.mapSuperView.isHidden = false
        
        //UIView* dummyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        //myTextField.inputView = dummyView; // Hide keyboard, but show blinking cursor
        
        //let dummyView : UIView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0))
        txtDropAddress.inputView = UIView()
        txtPickAddress.inputView = UIView()
        
        if (viewModel as! KTAddressPickerViewModel).selectedTxtField == SelectedTextField.DropoffAddress {
            
            self.txtDropAddress.resignFirstResponder()
            txtDropAddress.becomeFirstResponder()
        }
        else {
            
            self.txtPickAddress.resignFirstResponder()
            txtPickAddress.becomeFirstResponder()
        }
        
    }
    // MARK: - View Model Delegate
    func loadData() {
        tblView.reloadData()
    }
    
    func navigateToPreviousView(pickup: KTGeoLocation?, dropOff: KTGeoLocation?) {
        if pickup != nil {
            
            previousView?.pickUpAddress = pickup
        }
        if dropOff != nil {
            
            previousView?.dropOffAddress = dropOff
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
        return (viewModel as! KTAddressPickerViewModel).numberOfRow()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : AddressPickCell = tableView.dequeueReusableCell(withIdentifier: "AddPickCellIdentifier", for: indexPath) as! AddressPickCell
            /*AddressPickCell(style: UITableViewCellStyle.default, reuseIdentifier: "AddPickCellIdentifier")*/
        
        cell.addressTitle.text = (viewModel as! KTAddressPickerViewModel).addressTitle(forRow: indexPath.row)
        cell.addressArea.text = (viewModel as! KTAddressPickerViewModel).addressArea(forRow: indexPath.row)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        (viewModel as! KTAddressPickerViewModel).didSelectRow(at:indexPath.row, type:(viewModel as! KTAddressPickerViewModel).selectedTxtField)
    }
    
    // MARK: - UItextField Delegates
    
    /*func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false
    }*/
    
    func textFieldDidBeginEditing(_ textField: UITextField){
        updateSelectedField(txt:textField)
        
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        searchText = textField.text!;
        if searchTimer.isValid {
            
            searchTimer.invalidate()
        }
        if let txt = textField.text, txt.count >= 3 {
            searchTimer = Timer.scheduledTimer(timeInterval: 3, target: self,   selector: (#selector(self.updateTimer)), userInfo: nil, repeats: false)
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
            (viewModel as! KTAddressPickerViewModel).selectedTxtField = SelectedTextField.DropoffAddress
            txtDropAddress.backgroundColor = selectedTxtFieldColor
            txtPickAddress.backgroundColor = UIColor.white
            imgMapMarker.image = UIImage(named: "APDropOffMarker")
        }
        else {
            searchText = txtPickAddress.text!
            (viewModel as! KTAddressPickerViewModel).selectedTxtField = SelectedTextField.PickupAddress
            txtDropAddress.backgroundColor = UIColor.white
            txtPickAddress.backgroundColor = selectedTxtFieldColor
            imgMapMarker.image = UIImage(named: "APPickUpMarker")
        }
    }
}

class AddressPickCell: UITableViewCell {
    @IBOutlet weak var addressTitle : UILabel!
    @IBOutlet weak var addressArea : UILabel!
    @IBOutlet weak var ImgTypeIcon : UIImageView!
    
    
    @IBAction func btnMoreTapped(_ sender: Any) {
        
        //TODO: Show action sheet. As discussed with Danish bahi 
    }
}

