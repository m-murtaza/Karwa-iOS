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
import CDAlertView

class KTXpressDropOffViewController: KTBaseCreateBookingController, KTXpressAddressDelegate {
    
    @IBOutlet weak var dropOffAddressLabel: SpringLabel!
    
    @IBOutlet weak var plusButton: UIButton!

    @IBOutlet weak var minusButton: UIButton!

    @IBOutlet weak var passengerLabel: UILabel!
    
    @IBOutlet weak var setDropOffButton: SpringButton!
    
    @IBOutlet weak var markerButton: SpringButton!
    
    @IBOutlet weak var showAddressPickerBtn: UIButton!
    
    @IBOutlet weak var arrowImage: UIImageView!
    
    var vModel : KTXpressDropoffViewModel?

    var dropSet: Bool?
    
    var operationArea = [Area]()
    var destinationsForPickUp = [Area]()
    var pickUpZone: Area?
    var pickUpStation: Area?
    var pickUpStop: Area?
    lazy var countOfPassenger = 1

    var dropOffLocation: Area?
    var picupRect = GMSMutablePath()
    
    var pickUpCoordinate: CLLocationCoordinate2D?
    var dropOffCoordinate: CLLocationCoordinate2D?
    
    var zonalArea = [[String : [Area]]]()

    var addressSelected = false

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
        
        self.mapView.settings.rotateGestures = false
        self.mapView.settings.tiltGestures = false
        
        // Do any additional setup after loading the view.
        addMap()
        
        self.navigationItem.hidesBackButton = true;
//        self.btnRevealBtn?.addTarget(self, action: #selector(showMenu), for: .touchUpInside)
        
        //TODO: This needs to be converted on Location Call Back
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1)
        {
            self.vModel?.setupCurrentLocaiton()
        }

        self.showAddressPickerBtn.addTarget(self, action: #selector(showAddressPickerViewController), for: .touchUpInside)
        
        switch countOfPassenger {
        case 1:
            self.passengerLabel.text = "str_1pass".localized()
            plusButton.layer.opacity = 1
            minusButton.layer.opacity = 0.5
        case 2:
            self.passengerLabel.text = "str_2pass".localized()
            plusButton.layer.opacity = 1
            minusButton.layer.opacity = 1
        case 3:
            self.passengerLabel.text = "str_3pass".localized()
            plusButton.layer.opacity = 0.5
            minusButton.layer.opacity = 1
        default:
            self.passengerLabel.text = "str_1pass".localized()
            plusButton.layer.opacity = 1
            minusButton.layer.opacity = 1
        }
                
        if countOfPassenger > 1 {
            plusButton.layer.opacity = 0.5
            minusButton.layer.opacity = 1
        } else {
            plusButton.layer.opacity = 1
            minusButton.layer.opacity = 0.5
        }
        
        (self.viewModel as! KTXpressDropoffViewModel).countOfPassenger = countOfPassenger

        arrowImage.image = UIImage(named: "icon-arrow-right-large")
        
        self.setDropOffButton.setTitle("str_dropoff".localized(), for: .normal)
        
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
    
    func showAlertForStation() {
        
        if self.tapOnMarker == true {
            let alert = CDAlertView(title: "str_metro_station".localized(), message: self.vModel?.selectedStationName ?? "", type: .custom(image: UIImage(named:"metro_big")!))
            
            let yesAction = CDAlertViewAction(title: "SETDROPOFF".localized()) { value in
                self.vModel?.setDropOffStation(CLLocation(latitude: self.vModel?.selectedCoordinate?.latitude ?? 0.0, longitude: self.vModel?.selectedCoordinate?.longitude ?? 0.0))
                self.vModel?.didTapSetDropOffButton()
                return true
            }
            let noAction = CDAlertViewAction(title: "str_no".localized()) { value in
                return true
            }
            alert.add(action: noAction)
            alert.add(action: yesAction)
            alert.show()
        } else {
            self.vModel?.setDropOffStation(CLLocation(latitude: self.vModel?.selectedCoordinate?.latitude ?? 0.0, longitude: self.vModel?.selectedCoordinate?.longitude ?? 0.0))
        }
        
       
    }
    
    @IBAction func setCountForPassenger(sender: UIButton) {
        if sender.tag == 101 {
            if countOfPassenger >= 1 && countOfPassenger < 3 {
                countOfPassenger += 1
            }
            if countOfPassenger == 3 {
                plusButton.layer.opacity = 0.5
                minusButton.layer.opacity = 1
            } else {
                plusButton.layer.opacity = 1
                minusButton.layer.opacity = 1
            }
        } else {
            if countOfPassenger > 1 && countOfPassenger <= 3 {
                countOfPassenger -= 1
            }
            if countOfPassenger == 1 {
                plusButton.layer.opacity = 1
                minusButton.layer.opacity = 0.5
            } else if countOfPassenger >= 1{
                plusButton.layer.opacity = 1
                minusButton.layer.opacity = 1
            }
        }
        
        (viewModel as? KTXpressDropoffViewModel)?.countOfPassenger = countOfPassenger
        
        switch countOfPassenger {
        case 1:
            self.passengerLabel.text = "str_1pass".localized()
        case 2:
            self.passengerLabel.text = "str_2pass".localized()
        case 3:
            self.passengerLabel.text = "str_3pass".localized()
        default:
            self.passengerLabel.text = "str_1pass".localized()
        }
        
    }
    
    func setPassenderCount(count: String?) {
        guard count != nil else {
            return
        }
        self.passengerLabel.text = "\(countOfPassenger) \(countOfPassenger > 1 ? "str_pass_plural".localized() :  "str_pass".localized())"
    }
    
    func setDropOff(pick: String?) {
        guard pick != nil else {
            return
        }
        
        self.dropOffAddressLabel.text = pick
        
    }
    
    @IBAction func clickToSetUpBooking() {
        springAnimateButtonTapOut(button: setDropOffButton)
        (viewModel as! KTXpressDropoffViewModel).didTapSetDropOffButton()
    }
    
    @IBAction func bookbtnTouchDown(_ sender: SpringButton)
    {
      springAnimateButtonTapIn(button: setDropOffButton)
    }
    
    @IBAction func bookbtnTouchUpOutside(_ sender: SpringButton)
    {
      springAnimateButtonTapOut(button: setDropOffButton)
    }
    
    @objc private func showMenu() {
      sideMenuController?.revealMenu()
    }
    
    func showStopAlertViewController(stops: [Area], selectedStation: Area) {
        
        let alert = UIAlertController(title: "\(selectedStation.name! + "str_stop".localized())", message: "str_select_stop".localized(), preferredStyle: .actionSheet)
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
    
    func showRideServiceViewController(rideLocationData: RideSerivceLocationData?, rideInfo: RideInfo?) {
        let rideService = self.storyboard?.instantiateViewController(withIdentifier: "KTXpressRideCreationViewController") as? KTXpressRideCreationViewController
        rideService!.rideServicePickDropOffData = rideLocationData
        rideService!.rideInfo = rideInfo
        self.navigationController?.pushViewController(rideService!, animated: true)
        
    }
    
    func showAlertForFailedRide(message: String) {
        let alert = CDAlertView(title: message, message: "", type: .custom(image: UIImage(named:"icon-notifications")!))
        let doneAction = CDAlertViewAction(title: "str_ok".localized()) { value in
//            if let navController = self.navigationController {
//                if let controller = navController.viewControllers.first(where: { $0 is KTXpressRideCreationViewController }) {
//                    if navController.viewControllers.count == 6 {
//                        navController.popToViewController(navController.viewControllers[3], animated: true)
//                    } else if navController.viewControllers.count > 4 {
//                        navController.popToViewController(navController.viewControllers[2], animated: true)
//                    } else if navController.viewControllers.count <= 3 {
//                        navController.popToViewController(navController.viewControllers[0], animated: true)
//                    } else if navController.viewControllers.count <= 4 {
//                        navController.popToViewController(navController.viewControllers[1], animated: true)
//                    } else {
//                        navController.popViewController(animated: true)
//                    }
//                } else {
//                    navController.popViewController(animated: true)
//                }
//            }
            return true
        }
        
        alert.add(action: doneAction)
        alert.show()
    }
    
    func setLocation(location: Any) {
        
        xpressRebookDropOffSelected = false
        
        addressSelected = true
        
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
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                
                if let loc = location as? Area {
                    print(location)
                    
                    self.tapOnMarker = true
                    
                    let metroAreaCoordinate = getCenterPointOfPolygon(bounds: loc.bound!)
                    
                    print(metroAreaCoordinate.latitude)
                    
                    (self.viewModel as! KTXpressDropoffViewModel).selectedCoordinate = metroAreaCoordinate
                    
                    let camera = GMSCameraPosition.camera(withLatitude: metroAreaCoordinate.latitude, longitude: metroAreaCoordinate.longitude, zoom: 15.0)
                    self.mapView.camera = camera
                    
                    (self.viewModel as? KTXpressDropoffViewModel)!.setDropOffStation(CLLocation(latitude: metroAreaCoordinate.latitude, longitude: metroAreaCoordinate.longitude))
                    
                    defer {
                        (self.viewModel as! KTXpressDropoffViewModel).showStopAlert()
                    }
                    
                    (self.viewModel as! KTXpressDropoffViewModel).didTapSetDropOffButton()
                    
                    self.setDropOffButton.setTitle("str_dropoff".localized(), for: .normal)
                    self.setDropOffButton.setTitleColor(UIColor.white, for: .normal)
                    self.setDropOffButton.backgroundColor = UIColor(hexString: "#44a4a4")
                    self.markerButton.setImage(#imageLiteral(resourceName: "pin_dropoff_map"), for: .normal)
                    self.setDropOffButton.isUserInteractionEnabled = true
                    
                }
            }
        }
    }

    
    @IBAction func goBackButtonClick() {
        self.navigationController?.popViewController(animated: false)
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
