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

class KTXpressDropOffViewController: KTBaseCreateBookingController, KTXpressAddressDelegate {
    
    @IBOutlet weak var dropOffAddressLabel: SpringLabel!
    
    @IBOutlet weak var plusButton: UIButton!

    @IBOutlet weak var minusButton: UIButton!

    @IBOutlet weak var passengerLabel: UILabel!
    
    @IBOutlet weak var setDropOffButton: UIButton!
    
    @IBOutlet weak var markerButton: SpringButton!
    
    @IBOutlet weak var showAddressPickerBtn: UIButton!
    
    var vModel : KTXpressDropoffViewModel?

    var dropSet: Bool?
    
    var operationArea = [Area]()
    var destinationsForPickUp = [Area]()
    var pickUpZone: Area?
    var pickUpStation: Area?
    var pickUpStop: Area?
    var countOfPassenger = 1

    var dropOffLocation: Area?
    var picupRect = GMSMutablePath()
    
    var pickUpCoordinate: CLLocationCoordinate2D?
    var dropOffCoordinate: CLLocationCoordinate2D?
    
    var zonalArea = [[String : [Area]]]()

    
    var tapOnMarker = false

    override func viewDidLoad() {
        viewModel = KTXpressDropoffViewModel(del:self)
        
        vModel = viewModel as? KTXpressDropoffViewModel
        
        vModel?.operationArea = self.operationArea
        vModel?.destinationsForPickUp = self.destinationsForPickUp
        vModel?.pickUpZone = self.pickUpZone
        vModel?.pickUpStation = self.pickUpStation
        vModel?.pickUpStop = self.pickUpStop
        vModel?.pickUpCoordinate = self.pickUpCoordinate
        vModel?.zonalArea = self.zonalArea

        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        addMap()
        
        self.navigationItem.hidesBackButton = true;
//        self.btnRevealBtn?.addTarget(self, action: #selector(showMenu), for: .touchUpInside)
        
        //TODO: This needs to be converted on Location Call Back
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1)
        {
            self.vModel?.setupCurrentLocaiton()
        }

        self.setDropOffButton.addTarget(self, action: #selector(clickToSetUpBooking), for: .touchUpInside)

        self.showAddressPickerBtn.addTarget(self, action: #selector(showAddressPickerViewController), for: .touchUpInside)
        
        self.passengerLabel.text = "\(countOfPassenger) \("str_pass".localized())"

        
    }
    
    func hideNavigationController() {
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.navigationBar.isHidden = true
    }
    
    @IBAction func setCurrentLocation(sender: UIButton) {
        let camera = GMSCameraPosition.camera(withLatitude: KTLocationManager.sharedInstance.baseLocation.coordinate.latitude, longitude: KTLocationManager.sharedInstance.baseLocation.coordinate.longitude, zoom: 16)
        mapView.camera = camera
        mapView.animate(to: camera)
    }
    
    @objc func showAddressPickerViewController() {
        let addressPicker = (self.storyboard?.instantiateViewController(withIdentifier: "KTXpressAddressViewController") as? KTXpressAddressViewController)!
        addressPicker.metroStations = (self.viewModel as! KTXpressDropoffViewModel).destinationsForPickUp
        addressPicker.delegateAddress = self
        addressPicker.fromDropOff = true
        self.navigationController?.pushViewController(addressPicker, animated: true)
    }
    
    @IBAction func setCountForPassenger(sender: UIButton) {
        if sender.tag == 101 {
            countOfPassenger = countOfPassenger == 1 ? (countOfPassenger + 1) : countOfPassenger
        } else {
            countOfPassenger = countOfPassenger > 1 ? (countOfPassenger - 1) : 1
        }
        (viewModel as? KTXpressDropoffViewModel)?.countOfPassenger = countOfPassenger
        self.passengerLabel.text = "\(countOfPassenger) \("str_pass".localized())"
    }
    
    func setPassenderCount(count: String?) {
        guard count != nil else {
            return
        }
        
        self.passengerLabel.text = "\(countOfPassenger) \("str_pass".localized())"
        
    }
    
    func setDropOff(pick: String?) {
        guard pick != nil else {
            return
        }
        
        self.dropOffAddressLabel.text = pick
        
    }
    
    @objc func clickToSetUpBooking() {
        (viewModel as! KTXpressDropoffViewModel).didTapSetDropOffButton()
    }
    
    @objc private func showMenu() {
      sideMenuController?.revealMenu()
    }
    
    func showStopAlertViewController(stops: [Area], selectedStation: Area) {
        
        let alert = UIAlertController(title: "\(selectedStation.name! + "Stops")", message: "Please Select Stop for Station", preferredStyle: .actionSheet)
        
        
        for item in stops {
            alert.addAction(UIAlertAction(title: item.name!, style: .default , handler:{ (UIAlertAction)in
                self.tapOnMarker = true
                (self.viewModel as! KTXpressDropoffViewModel).selectedStop = item
            }))
        }

        self.present(alert, animated: true, completion: {
            print("completion block")
        })
        
    }
    
    func showRideServiceViewController(rideLocationData: RideSerivceLocationData?) {
        let rideService = self.storyboard?.instantiateViewController(withIdentifier: "KTXpressRideCreationViewController") as? KTXpressRideCreationViewController
        rideService!.rideServicePickDropOffData = rideLocationData

        self.navigationController?.pushViewController(rideService!, animated: true)
        
    }
    
    func setLocation(location: Any) {
        
        if let loc = location as? KTGeoLocation {
            print(location)
            (self.viewModel as! KTXpressDropoffViewModel).selectedCoordinate = CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude)
            let actualLocation = CLLocation(latitude: loc.latitude, longitude: loc.longitude)
            KTLocationManager.sharedInstance.setCurrentLocation(location: actualLocation)
            let camera = GMSCameraPosition.camera(withLatitude: loc.latitude, longitude: loc.longitude, zoom: 15)
            mapView.camera = camera
            mapView.animate(to: camera)
            
            self.checkPermittedDropOff(actualLocation)
            
        } else {
            
            if let loc = location as? Area {
                print(location)
                
                self.tapOnMarker = true
                
                let metroAreaCoordinate = getCenterPointOfPolygon(bounds: loc.bound!)

                print(metroAreaCoordinate.latitude)

                (self.viewModel as! KTXpressDropoffViewModel).selectedCoordinate = metroAreaCoordinate

                let camera = GMSCameraPosition.camera(withLatitude: metroAreaCoordinate.latitude, longitude: metroAreaCoordinate.longitude, zoom: 15.0)
                self.mapView.camera = camera

                (self.viewModel as? KTXpressDropoffViewModel)!.didTapMarker(location: CLLocation(latitude: metroAreaCoordinate.latitude, longitude: metroAreaCoordinate.longitude))
                
                defer {
                    (self.viewModel as! KTXpressDropoffViewModel).showStopAlert()
                }

                self.setDropOffButton.setTitle("SETDROPOFF".localized(), for: .normal)
                self.setDropOffButton.setTitleColor(UIColor.white, for: .normal)
                self.setDropOffButton.backgroundColor = UIColor(hexString: "#44a4a4")
                self.markerButton.setImage(#imageLiteral(resourceName: "pin_dropoff_map"), for: .normal)
                self.setDropOffButton.isUserInteractionEnabled = true
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
