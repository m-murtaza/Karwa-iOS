//
//  KTSetHomeWorkViewController.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 3/7/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps

enum BookmarkType : Int{
    case home = 1
    case work = 2
    case favorite = 3
}

class KTSetHomeWorkViewController: KTBaseViewController, KTSetHomeWorkViewModelDelegate,UITableViewDelegate,UITableViewDataSource,GMSMapViewDelegate,UITextFieldDelegate {

    public var bookmarkType : BookmarkType = BookmarkType.home
    public var selectedInputMechanism : SelectedInputMechanism = SelectedInputMechanism.ListView
    public var previousView : KTSettingsViewController?
    
    private var removeTxtFromTextBox : Bool = true
    private var searchTimer: Timer = Timer()
    private var searchText : String = ""
    
    @IBOutlet weak var txtBookmarkType: UITextField!
    @IBOutlet weak var txtAddress: UITextField!
    @IBOutlet weak var imgBookmarkTypeIcon: UIImageView!
    @IBOutlet weak var imgBookmarkAddressIcon: UIImageView!
    @IBOutlet weak var tblView: UITableView!
    
    @IBOutlet weak var imgListSelected : UIImageView!
    @IBOutlet weak var imgMapSelected : UIImageView!
    @IBOutlet weak var mapView : GMSMapView!
    @IBOutlet weak var mapSuperView : UIView!
    @IBOutlet weak var imgMapMarker : UIImageView!
    
    override func viewDidLoad() {
        viewModel = KTSetHomeWorkViewModel(del: self)
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        txtAddress.becomeFirstResponder()
    }

    override func viewWillAppear(_ animated: Bool) {
        initializeMap()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func typeOfBookmark() -> BookmarkType {
        
        return bookmarkType
    }
    func UpdateUI(name bookmarkName:String, location: CLLocationCoordinate2D) {
        
        txtAddress.text = bookmarkName
        txtBookmarkType.text = (bookmarkType == BookmarkType.home) ? "Set Home address" : "Set Work address"
        imgBookmarkTypeIcon.image = UIImage(named: (bookmarkType == BookmarkType.home) ? "APICHome" : "APICWork")
        imgBookmarkAddressIcon.image = UIImage(named: (bookmarkType == BookmarkType.home) ? "SHWIconHome" : "SHWIconWork")
        
        imgMapMarker.image = UIImage(named: ((bookmarkType == BookmarkType.home) ? "APPickUpMarker":"APDropOffMarker"))
        
        if selectedInputMechanism == SelectedInputMechanism.MapView {
            
        }
    }
    
    func UpdateAddressText(address add:String) {
        
        txtAddress.text = add
    }
    
    func showSuccessAltAndMoveBack() {
        let alertController = UIAlertController(title: "\((bookmarkType == BookmarkType.home) ? "Home" : "Work") Updated", message: "Your \((bookmarkType == BookmarkType.home) ? "Home" : "Work") address is updated", preferredStyle: .alert)
        
        //let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
            self.previousView?.dismiss()
        }
        
        //alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    //MARK: - Toggle
    @IBAction func btnListViewTapped(_ sender: Any) {
        
        imgListSelected.isHidden = false
        imgMapSelected.isHidden = true
        //self.txtDropAddress.becomeFirstResponder()
        self.tblView.isHidden = false
        self.mapSuperView.isHidden = true
    
        selectedInputMechanism = SelectedInputMechanism.ListView
        txtAddress.becomeFirstResponder()
    }
    
    @IBAction func btnMapViewTapped(_ sender: Any) {
        selectedInputMechanism = SelectedInputMechanism.MapView
        
        updateMap()
        
        imgListSelected.isHidden = true
        imgMapSelected.isHidden = false
        
        
        self.tblView.isHidden = true
        self.mapSuperView.isHidden = false
        
        self.txtAddress.resignFirstResponder()
    }
    
    private func initializeMap () {
        var focusLocation : CLLocationCoordinate2D  = (viewModel as! KTSetHomeWorkViewModel).currentLocation()
        
        if (viewModel as! KTSetHomeWorkViewModel).bookmark != nil {
            
            focusLocation = CLLocationCoordinate2D(latitude: ((viewModel as! KTSetHomeWorkViewModel).bookmark?.latitude)!, longitude: ((viewModel as! KTSetHomeWorkViewModel).bookmark?.longitude)!)
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
        
        var focusLocation : CLLocationCoordinate2D  = (viewModel as! KTSetHomeWorkViewModel).currentLocation()
        
        if (viewModel as! KTSetHomeWorkViewModel).bookmark != nil {
            
            focusLocation = CLLocationCoordinate2D(latitude: ((viewModel as! KTSetHomeWorkViewModel).bookmark?.latitude)!, longitude: ((viewModel as! KTSetHomeWorkViewModel).bookmark?.longitude)!)
        }
        
        let update :GMSCameraUpdate = GMSCameraUpdate.setTarget(focusLocation, zoom: KTCreateBookingConstants.DEFAULT_MAP_ZOOM)
        mapView.animate(with: update)

    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        
        if selectedInputMechanism == SelectedInputMechanism.MapView {
            (viewModel as! KTSetHomeWorkViewModel).MapStopMoving(location: mapView.camera.target)
        }
    }
    
    //Mark:- IBAction
    @IBAction func btnSaveTapped(_ sender: Any) {
        
        (viewModel as! KTSetHomeWorkViewModel).saveBookmark(location: mapView.camera.target)
    }
    
    // MARK: - Textfield Delegate
    func textFieldDidBeginEditing(_ textField: UITextField){
        
        removeTxtFromTextBox = true
    }
    
//    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
//
//        return true
//    }
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        //print("---textFieldDidEndEditing---")
//
//    }
    
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
        
        (viewModel as! KTSetHomeWorkViewModel).fetchLocations(forSearch: searchText)
    }
    // MARK: - TableView Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (viewModel as! KTSetHomeWorkViewModel).numberOfRow()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : AddressPickCell = tableView.dequeueReusableCell(withIdentifier: "AddPickCellIdentifier", for: indexPath) as! AddressPickCell
        
        cell.addressTitle.text = (viewModel as! KTSetHomeWorkViewModel).addressTitle(forRow: indexPath.row)
        cell.addressArea.text = (viewModel as! KTSetHomeWorkViewModel).addressArea(forRow: indexPath.row)
        
        cell.ImgTypeIcon.image = (viewModel as! KTSetHomeWorkViewModel).addressTypeIcon(forIndex: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        (viewModel as! KTSetHomeWorkViewModel).didSelectRow(at:indexPath.row)
    }
    
    func loadData() {
        tblView.reloadData()
    }
}
