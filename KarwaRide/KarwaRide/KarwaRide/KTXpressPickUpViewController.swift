//
//  KTXpressPickUpViewController.swift
//  KarwaRide
//
//  Created by Satheesh Speed Mac on 14/05/21.
//  Copyright © 2021 Karwa. All rights reserved.
//

import UIKit
import GoogleMaps
import Spring

class KTXpressPickUpViewController: KTBaseCreateBookingController, KTXpressPickUpViewModelDelegate, KTXpressAddressDelegate {

    @IBOutlet weak var pickUpAddressLabel: SpringLabel!
    @IBOutlet weak var markerButton: SpringButton!
    @IBOutlet weak var setPickUpButton: UIButton!
    
    @IBOutlet weak var plusBtn: UIButton!
    @IBOutlet weak var minuBtn: UIButton!
    @IBOutlet weak var passengerLabel: UILabel!
    @IBOutlet weak var showAddressPickerBtn: UIButton!
    var addressSelected = false

    var vModel : KTXpressPickUpViewModel?

    var pickUpSet: Bool?
    var dropSet: Bool?
    
    var tapOnMarker = false
    lazy var countOfPassenger = xpressRebookPassengerSelected ? xpressRebookNumberOfPassenger : 1
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        viewModel = KTXpressPickUpViewModel(del:self)
        vModel = viewModel as? KTXpressPickUpViewModel
        // Do any additional setup after loading the view.
        addMap()
        
        self.navigationItem.hidesBackButton = true;
        self.btnRevealBtn?.addTarget(self, action: #selector(showMenu), for: .touchUpInside)
        
        //TODO: This needs to be converted on Location Call Back
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1)
        {
            self.vModel?.setupCurrentLocaiton()
        }
        
        self.setPickUpButton.addTarget(self, action: #selector(clickSetPickUp), for: .touchUpInside)
        self.showAddressPickerBtn.addTarget(self, action: #selector(showAddressPickerViewController), for: .touchUpInside)
        
        self.passengerLabel.text = "\(xpressRebookPassengerSelected ? xpressRebookNumberOfPassenger : 2) \("str_pass".localized())"


    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
        self.navigationController?.navigationBar.isHidden = true
        (viewModel as! KTXpressPickUpViewModel).fetchOperatingArea()
    }
    
    
    @IBAction func setCurrentLocation(sender: UIButton) {
        let camera = GMSCameraPosition.camera(withLatitude: KTLocationManager.sharedInstance.baseLocation.coordinate.latitude, longitude: KTLocationManager.sharedInstance.baseLocation.coordinate.longitude, zoom: 16)
        mapView.camera = camera
        mapView.animate(to: camera)
    }
    
    
    @IBAction func setCountForPassenger(sender: UIButton) {
        
        if sender.tag == 10 {
            countOfPassenger = countOfPassenger == 1 ? (countOfPassenger + 1) : countOfPassenger
        } else {
            countOfPassenger = countOfPassenger > 1 ? (countOfPassenger - 1) : 1
        }
        
        self.passengerLabel.text = "\(countOfPassenger) \("str_pass".localized())"
        
    }
    
    @objc func clickSetPickUp() {
        (self.viewModel as! KTXpressPickUpViewModel).didTapSetPickUpButton()
    }
    
    func setPickUp(pick: String?) {
        guard pick != nil else {
            return
        }
        
        self.pickUpAddressLabel.text = pick
        
    }
    
    @objc private func showMenu() {
      sideMenuController?.revealMenu()
    }

    /*
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    */
    
    func showDropOffViewController(destinationForPickUp: [Area], pickUpStation: Area?, pickUpStop: Area?, pickUpzone: Area?, coordinate: CLLocationCoordinate2D, zonalArea: [[String : [Area]]]) {
        
        let dropOff = (self.storyboard?.instantiateViewController(withIdentifier: "KTXpressDropOffViewController") as? KTXpressDropOffViewController)!
        dropOff.destinationsForPickUp = destinationForPickUp
        dropOff.pickUpCoordinate = coordinate
        dropOff.pickUpStop = pickUpStop
        dropOff.pickUpStation = pickUpStation
        dropOff.pickUpZone = pickUpzone
        dropOff.operationArea = (self.viewModel as! KTXpressPickUpViewModel).areas
        dropOff.zonalArea = zonalArea
        dropOff.countOfPassenger = xpressRebookPassengerSelected ?  xpressRebookNumberOfPassenger : countOfPassenger

        self.navigationController?.pushViewController(dropOff, animated: true)
        
    }
    
    func showStopAlertViewController(stops: [Area], selectedStation: Area) {
        
        let alert = UIAlertController(title: "\(selectedStation.name! + "Stops")", message: "Please Select Stop for Station", preferredStyle: .actionSheet)
        
        
        for item in stops {
            alert.addAction(UIAlertAction(title: item.name!, style: .default , handler:{ (UIAlertAction)in
                self.tapOnMarker = true
                print("User click Approve button")
                (self.viewModel as! KTXpressPickUpViewModel).selectedStop = item
            }))
        }

        self.present(alert, animated: true, completion: {
            print("completion block")
        })
        
    }

    @objc func showAddressPickerViewController() {
        let addressPicker = (self.storyboard?.instantiateViewController(withIdentifier: "KTXpressAddressViewController") as? KTXpressAddressViewController)!
        addressPicker.metroStations = (self.viewModel as! KTXpressPickUpViewModel).pickUpArea
        addressPicker.delegateAddress = self
        addressPicker.fromPickup = true
        self.navigationController?.pushViewController(addressPicker, animated: true)
    }
    
    func setLocation(location: Any) {
        
        addressSelected = true
        
        if let loc = location as? KTGeoLocation {
            print(location)
            (self.viewModel as! KTXpressPickUpViewModel).selectedCoordinate = CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude)
            let actualLocation = CLLocation(latitude: loc.latitude, longitude: loc.longitude)
            self.setPickUp(pick: loc.name)
            KTLocationManager.sharedInstance.setCurrentLocation(location: actualLocation)
            let camera = GMSCameraPosition.camera(withLatitude: loc.latitude, longitude: loc.longitude, zoom: 15)
            mapView.camera = camera
            mapView.animate(to: camera)
            if (self.viewModel as! KTXpressPickUpViewModel).checkLatLonInside(location: actualLocation) {
                self.setPickUpButton.setTitle("str_setpick".localized(), for: .normal)
                self.setPickUpButton.setTitleColor(UIColor.white, for: .normal)
                self.setPickUpButton.backgroundColor = UIColor(hexString: "#006170")
                self.markerButton.setImage(#imageLiteral(resourceName: "pin_pickup_map"), for: .normal)
                self.setPickUpButton.isUserInteractionEnabled = true
            } else {
                self.setPickUpButton.setTitle("str_outzone".localized(), for: .normal)
                self.setPickUpButton.backgroundColor = UIColor.clear
                self.markerButton.setImage(#imageLiteral(resourceName: "pin_outofzone"), for: .normal)
                self.setPickUpButton.setTitleColor(UIColor(hexString: "#8EA8A7"), for: .normal)
                self.setPickUpButton.isUserInteractionEnabled = false
            }
        } else {
            
            if let loc = location as? Area {
                print(location)
                
                self.tapOnMarker = true
                
                let metroAreaCoordinate = getCenterPointOfPolygon(bounds: loc.bound!)
                
                print(metroAreaCoordinate.latitude)

                let camera = GMSCameraPosition.camera(withLatitude: metroAreaCoordinate.latitude, longitude: metroAreaCoordinate.longitude, zoom: 15)
                self.mapView.camera = camera

                (self.viewModel as? KTXpressPickUpViewModel)!.didTapMarker(location: CLLocation(latitude: metroAreaCoordinate.latitude, longitude: metroAreaCoordinate.longitude))

                (self.viewModel as! KTXpressPickUpViewModel).selectedCoordinate = metroAreaCoordinate

                defer {
                    (self.viewModel as! KTXpressPickUpViewModel).showStopAlert()
                }

                self.setPickUpButton.setTitle("str_setpick".localized(), for: .normal)
                self.setPickUpButton.setTitleColor(UIColor.white, for: .normal)
                self.setPickUpButton.backgroundColor = UIColor(hexString: "#006170")
                self.markerButton.setImage(#imageLiteral(resourceName: "pin_pickup_map"), for: .normal)
                self.setPickUpButton.isUserInteractionEnabled = true
            }
            
        }
        
        
    }
    

}



