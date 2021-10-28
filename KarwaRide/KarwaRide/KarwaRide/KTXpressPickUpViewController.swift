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
import CoreLocation

class KTXpressPickUpViewController: KTBaseCreateBookingController, KTXpressPickUpViewModelDelegate, KTXpressAddressDelegate {

    @IBOutlet weak var pickUpAddressLabel: SpringLabel!
    @IBOutlet weak var markerButton: SpringButton!
    @IBOutlet weak var setPickUpButton: SpringButton!
    
    @IBOutlet weak var plusBtn: UIButton!
    @IBOutlet weak var minuBtn: UIButton!
    @IBOutlet weak var passengerLabel: UILabel!
    @IBOutlet weak var showAddressPickerBtn: UIButton!
    
    @IBOutlet weak var arrowImage: UIImageView!

    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var addressSelected = false

    var vModel : KTXpressPickUpViewModel?

    var pickUpSet: Bool?
    var dropSet: Bool?
    
    var tapOnMarker = false
    var firstTime = false

    lazy var countOfPassenger =  1
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        setPickUpButton.setTitle("str_setpick".localized(), for: .normal)
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
        
        self.showAddressPickerBtn.addTarget(self, action: #selector(showAddressPickerViewController), for: .touchUpInside)
        
        self.passengerLabel.text = "str_1pass".localized()
        plusBtn.layer.opacity = 1
        minuBtn.layer.opacity = 0.5
        
        arrowImage.image = UIImage(named: "icon-arrow-right-large")

//        if Device.getLanguage().contains("AR") {
//            arrowImage.image = #imageLiteral(resourceName: "arrow_right").imageFlippedForRightToLeftLayoutDirection()
//        } else {
//            arrowImage.image = #imageLiteral(resourceName: "arrow_right")
//        }
        
        (viewModel as! KTXpressPickUpViewModel).fetchOperatingArea()
        self.mapView.settings.rotateGestures = false
        self.mapView.settings.tiltGestures = false
        
    }
    
    @IBAction func bookbtnTouchDown(_ sender: SpringButton)
    {
      springAnimateButtonTapIn(button: setPickUpButton)
    }
    
    @IBAction func bookbtnTouchUpOutside(_ sender: SpringButton)
    {
      springAnimateButtonTapOut(button: setPickUpButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
        self.navigationController?.navigationBar.isHidden = true
        
        if bookingSuccessful == true {
            countOfPassenger = 1
            self.passengerLabel.text = "str_1pass".localized()
            plusBtn.layer.opacity = 1
            minuBtn.layer.opacity = 0.5
            bookingSuccessful = false
        }
        
        if self.tabBarController?.tabBar.isHidden == false {
            if UIDevice().userInterfaceIdiom == .phone {
                    switch UIScreen.main.nativeBounds.height {
                    case 1136:
                        print("iPhone 5 or 5S or 5C")
                        bottomConstraint.constant = 49
                    case 1334:
                        print("iPhone 6/6S/7/8")
                        bottomConstraint.constant = 49
                    case 1920, 2208:
                        print("iPhone 6+/6S+/7+/8+")
                        bottomConstraint.constant = 49
                    case 2436:
                        print("iPhone X")
                        bottomConstraint.constant = 85
                    default:
                        print("unknown")
                        bottomConstraint.constant = 85
                    }
                }
        } else {
            bottomConstraint.constant = 0
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
        self.navigationController?.navigationBar.isHidden = true
//        (viewModel as! KTXpressPickUpViewModel).fetchOperatingArea()
    }
    
    
    @IBAction func setCurrentLocation(sender: UIButton) {
        let camera = GMSCameraPosition.camera(withLatitude: KTLocationManager.sharedInstance.baseLocation.coordinate.latitude, longitude: KTLocationManager.sharedInstance.baseLocation.coordinate.longitude, zoom: 16)
        mapView.camera = camera
        mapView.animate(to: camera)
    }
    
    
    @IBAction func setCountForPassenger(sender: UIButton) {
                 
        if sender.tag == 10 {
            if countOfPassenger >= 1 && countOfPassenger < 3 {
                countOfPassenger += 1
            }
            if countOfPassenger == 3 {
                plusBtn.layer.opacity = 0.5
                minuBtn.layer.opacity = 1
            } else {
                plusBtn.layer.opacity = 1
                minuBtn.layer.opacity = 1
            }
        } else {
            if countOfPassenger > 1 && countOfPassenger <= 3 {
                countOfPassenger -= 1
            }
            if countOfPassenger == 1 {
                plusBtn.layer.opacity = 1
                minuBtn.layer.opacity = 0.5
            } else if countOfPassenger >= 1{
                plusBtn.layer.opacity = 1
                minuBtn.layer.opacity = 1
            }
        }
    
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
    
    @IBAction func clickSetPickUp(sender: UIButton) {
        springAnimateButtonTapOut(button: setPickUpButton)
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
        dropOff.operationArea = areas
        dropOff.zonalArea = zonalArea
        dropOff.countOfPassenger = countOfPassenger

        self.navigationController?.pushViewController(dropOff, animated: false)
        
    }
    
    func showAlertForStation() {
        
        if self.tapOnMarker == true {
            let alert = CDAlertView(title: "str_metro_station".localized(), message: (self.viewModel as! KTXpressPickUpViewModel).selectedStationName, type: .custom(image: UIImage(named:"metro_big")!))
            alert.hideAnimations = { (center, transform, alpha) in
//                transform = CGAffineTransform(translationX: 0, y: -256)
                alpha = 0
            }
            let yesAction = CDAlertViewAction(title: "SETPICKUP".localized()) { value in
                self.vModel?.setPickupStation(CLLocation(latitude: self.vModel?.selectedCoordinate?.latitude ?? 0.0, longitude: self.vModel?.selectedCoordinate?.longitude ?? 0.0))
                (self.viewModel as! KTXpressPickUpViewModel).didTapSetPickUpButton()
                return true
            }
            let noAction = CDAlertViewAction(title: "str_no".localized()) { value in
                return true
            }
            alert.hideAnimations = { (center, transform, alpha) in
//                transform = CGAffineTransform(translationX: 0, y: -256)
                alpha = 0
            }
            alert.add(action: noAction)
            alert.add(action: yesAction)
            alert.show()
        } else {
            self.vModel?.setPickupStation(CLLocation(latitude: self.vModel?.selectedCoordinate?.latitude ?? 0.0, longitude: self.vModel?.selectedCoordinate?.longitude ?? 0.0))
        }
        
       
    }
    
    
    func showStopAlertViewController(stops: [Area], selectedStation: Area) {
        
        let alert = UIAlertController(title: "\(selectedStation.name! + "str_stop".localized())", message: "str_select_stop".localized(), preferredStyle: .actionSheet)
        
        
        for item in stops {
            alert.addAction(UIAlertAction(title: item.name!, style: .default , handler:{ (UIAlertAction)in
                self.tapOnMarker = true
                print("User click Approve button")
                (self.viewModel as! KTXpressPickUpViewModel).selectedStop = item
                (self.viewModel as! KTXpressPickUpViewModel).didTapSetPickUpButton()
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
            if checkLatLonInside(location: actualLocation) {
                self.setPickUpButton.setTitle("str_setpick".localized(), for: .normal)
                self.setPickUpButton.setTitleColor(UIColor.white, for: .normal)
                self.setPickUpButton.backgroundColor = UIColor(hexString: "#469B9C")
                self.markerButton.setImage(#imageLiteral(resourceName: "pin_pickup_map"), for: .normal)
                self.setPickUpButton.isUserInteractionEnabled = true
                
//                self.setPickUpButton.layer.shadowRadius = 4
//                self.setPickUpButton.layer.shadowOpacity = 3
//                self.setPickUpButton.layer.shadowOffset = CGSize(width: 3, height: 3)
//                if #available(iOS 13.0, *) {
//                    self.setPickUpButton.layer.shadowColor = UIColor.primary.cgColor
//                } else {
//                    // Fallback on earlier versions
//                    self.setPickUpButton.layer.shadowColor = UIColor.primary.cgColor
//                }
                
            } else {
                self.setPickUpButton.setTitle("str_outzone".localized(), for: .normal)
                self.setPickUpButton.backgroundColor = UIColor.clear
                self.markerButton.setImage(#imageLiteral(resourceName: "pin_outofzone"), for: .normal)
                self.setPickUpButton.setTitleColor(UIColor(hexString: "#8EA8A7"), for: .normal)
                self.setPickUpButton.isUserInteractionEnabled = false
//                self.setPickUpButton.layer.shadowColor = UIColor.clear.cgColor
            }
        } else {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let loc = location as? Area {
                    print(location)
                    self.tapOnMarker = true
                    
                    let metroAreaCoordinate = getCenterPointOfPolygon(bounds: loc.bound!)
                    print(metroAreaCoordinate.latitude)

                    let camera = GMSCameraPosition.camera(withLatitude: metroAreaCoordinate.latitude, longitude: metroAreaCoordinate.longitude, zoom: 15)
                    self.mapView.camera = camera
                    (self.viewModel as! KTXpressPickUpViewModel).selectedCoordinate = metroAreaCoordinate
                    (self.viewModel as? KTXpressPickUpViewModel)?.selectedStation = loc
                    (self.viewModel as? KTXpressPickUpViewModel)!.setPickupStation( CLLocation(latitude: metroAreaCoordinate.latitude, longitude: metroAreaCoordinate.longitude))
                    (self.viewModel as! KTXpressPickUpViewModel).didTapSetPickUpButton()

                    //didTapMarker(location: CLLocation(latitude: metroAreaCoordinate.latitude, longitude: metroAreaCoordinate.longitude))

                    self.setPickUpButton.setTitle("str_setpick".localized(), for: .normal)
                    self.setPickUpButton.setTitleColor(UIColor.white, for: .normal)
                    self.setPickUpButton.backgroundColor = UIColor(hexString: "#469B9C")
                    self.markerButton.setImage(#imageLiteral(resourceName: "pin_pickup_map"), for: .normal)
                    self.setPickUpButton.isUserInteractionEnabled = true
                    
//                    self.setPickUpButton.layer.shadowRadius = 4
//                    self.setPickUpButton.layer.shadowOpacity = 3
//                    self.setPickUpButton.layer.shadowOffset = CGSize(width: 3, height: 3)
//                    if #available(iOS 13.0, *) {
//                        self.setPickUpButton.layer.shadowColor = UIColor.primary.cgColor
//                    } else {
                        // Fallback on earlier versions
//                        self.setPickUpButton.layer.shadowColor = UIColor.primary.cgColor
//                    }
                }
            }
            
        }
    
    }
    

}



