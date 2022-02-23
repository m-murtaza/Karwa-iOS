//
//  KTXpressLocationPickerViewController.swift
//  KarwaRide
//
//  Created by Apple on 24/10/21.
//  Copyright © 2021 Karwa. All rights reserved.
//

import UIKit
import CoreLocation
import Spring
import GoogleMaps
import CDAlertView

struct MarkerData {
    var title: String?
    var type: String?
}

protocol RideExploreDelegate {
    func showPickUpScreen()
    func showDropOffScreen()
}

class KTXpressLocationPickerViewController:  KTBaseCreateBookingController {
   
    @IBOutlet weak var pickUpAddressLabel: SpringLabel!
    @IBOutlet weak var pickUpAddressHeaderLabel: SpringLabel!
    @IBOutlet weak var markerImage: SpringImageView!
    @IBOutlet weak var setLocationButton: SpringButton!
    @IBOutlet weak var backButton: SpringButton!
    @IBOutlet weak var rebookBackButton: SpringButton!
    @IBOutlet weak var closeButton: SpringButton!

    @IBOutlet weak var plusBtn: UIButton!
    @IBOutlet weak var minuBtn: UIButton!
    @IBOutlet weak var passengerLabel: UILabel!
    @IBOutlet weak var showAddressPickerBtn: UIButton!
    
    @IBOutlet weak var arrowImage: SpringImageView!
    @IBOutlet weak var markerIconImage: SpringImageView!

    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    lazy var rideService = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "KTXpressRideCreationViewController") as? KTXpressRideCreationViewController

    var vModel : KTXpressLocationSetUpViewModel?
    
    var addressSelected = false
    var pickUpSelected = true
    var tapOnMarker = false
    var destinationForPickUp = [Area]()
    var picupRect = GMSMutablePath()
    var fromRideHistory = false
    var backToPickUpWithMessageSelected = false
    
    var pickAddressText = ""


    var backToPreviousPickUp = false

    lazy var countOfPassenger =  1

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.hidesBackButton = true;
        self.btnRevealBtn?.addTarget(self, action: #selector(showMenu), for: .touchUpInside)
        
        viewModel = KTXpressLocationSetUpViewModel(del:self)
        vModel = viewModel as? KTXpressLocationSetUpViewModel
        (viewModel as! KTXpressLocationSetUpViewModel).fetchOperatingArea()

        addMap()
        // Do any additional setup after loading the view.
        setPickUpViewUI()
        //TODO: This needs to be converted on Location Call Back
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1)
        {
            self.vModel?.setupCurrentLocaiton()
        }
        
        arrowImage.image = UIImage(named: "icon-arrow-right-large")?.imageFlippedForRightToLeftLayoutDirection()
        self.mapView.settings.rotateGestures = false
        self.mapView.settings.tiltGestures = false
        
        setInitialPassengerCount()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
        self.navigationController?.navigationBar.isHidden = true
        if bookingSuccessful == true {
            countOfPassenger = 1
            self.passengerLabel.text = "str_1pass".localized()
            plusBtn.layer.opacity = 1
            minuBtn.layer.opacity = 0.5
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // your code here
            if bookingSuccessful == true {
                let location = CLLocation(latitude: self.mapView.projection.coordinate(for: self.mapView.center).latitude, longitude: self.mapView.projection.coordinate(for: self.mapView.center).longitude)
                selectedRSPickUpCoordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                self.vModel?.fetchLocationName(forGeoCoordinate: selectedRSPickUpCoordinate!)
                self.checkCoordinateStatus(location)
                bookingSuccessful = false
            }
        }
    }
    
    @objc private func showMenu() {
      sideMenuController?.revealMenu()
    }
    
    func setInitialPassengerCount() {
        if xpressRebookSelected == true {
            countOfPassenger = xpressRebookNumberOfPassenger
            switch xpressRebookNumberOfPassenger {
            case 1:
                self.passengerLabel.text = "str_1pass".localized()
                plusBtn.layer.opacity = 1
                minuBtn.layer.opacity = 0.5
            case 2:
                self.passengerLabel.text = "str_2pass".localized()
                plusBtn.layer.opacity = 1
                minuBtn.layer.opacity = 1
            case 3:
                self.passengerLabel.text = "str_3pass".localized()
                plusBtn.layer.opacity = 0.5
                minuBtn.layer.opacity = 1
            default:
                self.passengerLabel.text = "str_1pass".localized()
            }
        } else {
            self.passengerLabel.text = "str_1pass".localized()
            countOfPassenger = 1
            plusBtn.layer.opacity = 1
            minuBtn.layer.opacity = 0.5
        }
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
    
    @IBAction func setCurrentLocation(sender: UIButton) {
        let camera = GMSCameraPosition.camera(withLatitude: KTLocationManager.sharedInstance.baseLocation.coordinate.latitude, longitude: KTLocationManager.sharedInstance.baseLocation.coordinate.longitude, zoom: 16)
        mapView.camera = camera
        mapView.animate(to: camera)
    }
    
    @IBAction func submitButtonPressed(sender: UIButton) {
        springAnimateButtonTapOut(button: setLocationButton)
        if sender.title(for: .normal) == "str_setpick".localized() {
            if backToPickUpWithMessageSelected == true {
                getDestinationForPickUp()
                if tapOnMarker == false && selectedRSPickStation == nil && backToPickUpWithMessageSelected == true {
                    callDropOffAction()
                } else {
                    callSetPickUpAction()
                }
            } else {
                callSetPickUpAction()
            }
        } else if sender.title(for: .normal) == "str_dropoff".localized() {
            callDropOffAction()

        } else {
            callBookThisRideAction()
        }
        
    }
    
    @IBAction func bookbtnTouchDown(_ sender: SpringButton)
    {
      springAnimateButtonTapIn(button: setLocationButton)
    }
    
    @IBAction func bookbtnTouchUpOutside(_ sender: SpringButton)
    {
      springAnimateButtonTapOut(button: setLocationButton)
    }
    
    @IBAction func backButtonTapped(sender: UIButton) {
        selectedRSPickStop = nil
        selectedRSPickStation = nil
        selectedRSPickZone = nil
        backToPreviousPickUp = true
        backToPickUp()
        backToPreviousPickUp = false
    }
    
    @IBAction func closeButtonTapped(sender: UIButton) {
        closeButton.isHidden = true
        rideService?.remove()
        selectedRSPickStop = nil
        selectedRSPickStation = nil
        selectedRSPickZone = nil
        backToPreviousPickUp = true
        backToPickUp()
        backToPreviousPickUp = false
    }
    
    func updateValidPickUpUI() {
        setLocationButton.setTitle(pickUpSelected ? "str_setpick".localized() :  "str_dropoff".localized(), for: .normal)
        self.setLocationButton.setTitleColor(UIColor.white, for: .normal)
        self.setLocationButton.backgroundColor = UIColor(hexString: "#4BA5A7")
        markerImage.image = pickUpSelected ? #imageLiteral(resourceName: "pickup_address_ico") : #imageLiteral(resourceName: "pin_dropoff_map")
        self.setLocationButton.isUserInteractionEnabled = true
    }
    
    func updateOutOfZonePickUpUI() {
        self.setLocationButton.setTitle("str_outzone".localized(), for: .normal)
        self.setLocationButton.backgroundColor = UIColor.clear
        self.markerImage.image = #imageLiteral(resourceName: "pin_outofzone")
        self.setLocationButton.setTitleColor(UIColor(hexString: "#8EA8A7"), for: .normal)
        self.setLocationButton.isUserInteractionEnabled = false
    }
    
    func setPickUpViewUI() {
        setLocationButton.setTitle("str_setpick".localized(), for: .normal)
        self.setLocationButton.setTitleColor(UIColor.white, for: .normal)
        self.setLocationButton.backgroundColor = UIColor(hexString: "#4BA5A7")
        pickUpAddressHeaderLabel.text = "PICKUPHEADER".localized()
        markerIconImage.image = UIImage(named: "pickup_address_ico")
        backButton.isHidden = true
    }
    
    func backToPickUp() {
        if fromRideHistory == true {
            self.view.bringSubview(toFront: self.rebookBackButton)
            self.rebookBackButton.isHidden = false
        } else {
            self.rebookBackButton.isHidden = true
        }
        self.setTabBar(hidden: false)
//        self.tabBarController?.tabBar.isHidden = false
        closeButton.isHidden = true
        setPickUpPolygon()
        let update :GMSCameraUpdate = GMSCameraUpdate.setTarget(selectedRSPickUpCoordinate!, zoom: KTXpressCreateBookingConstants.DEFAULT_MAP_ZOOM)
        mapView.animate(with: update)
        self.markerImage.image = #imageLiteral(resourceName: "pickup_address_ico")

        setPickUpViewUI()
        addPickUpLocations()
    }
    
    func setTabBar(hidden:Bool) {
        guard let frame = self.tabBarController?.tabBar.frame else {return }
        if hidden {
            UIView.animate(withDuration: 0.3, animations: {
                self.tabBarController?.tabBar.frame = CGRect(x: frame.origin.x, y: frame.origin.y + frame.height, width: frame.width, height: frame.height)
                self.tabBarController?.tabBar.isHidden = true
            })
            
        }else {

            UIView.animate(withDuration: 0.3, animations: {
                self.tabBarController?.tabBar.frame = UITabBarController().tabBar.frame
                self.tabBarController?.tabBar.isHidden = false

            })
        }
    }
    
    func setDropOffViewUI() {
//        self.tabBarController?.tabBar.isHidden = true
        self.setTabBar(hidden: true)
        pickUpSelected = false
        setLocationButton.setTitle("str_dropoff".localized(), for: .normal)
        self.setLocationButton.backgroundColor = UIColor(hexString: "#4BA5A7")
        pickUpAddressHeaderLabel.text = "DROPOFFHEADER".localized()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.markerIconImage.image = UIImage(named: "pin_dropoff_map")
            self.markerImage.image = UIImage(named: "pin_dropoff_map")
        }
        backButton.isHidden = false
        closeButton.isHidden = true
    }
    
    func callSetPickUpAction() {
        pickUpSelected = true
        pickAddressText = self.pickUpAddressLabel.text ?? ""
        getDestinationForPickUp()
        tapOnMarker = false
        
        if selectedRSPickStation != nil {
            let stopsOfStations = stops.filter({$0.parent! == selectedRSPickStation?.code!})
            if stopsOfStations.count == 1  {
                if destinationForPickUp.count > 0 && tapOnMarker == false {
                    if selectedRSPickStation == nil {
                        setDropOffViewUI()
                        setDropOffPolygon()
                        self.markerIconImage.image = UIImage(named: "pin_dropoff_map")
                        self.markerImage.image = UIImage(named: "pin_dropoff_map")
                    }
                }
            }
        } else {
            if destinationForPickUp.count > 0 && tapOnMarker == false {
                setDropOffViewUI()
                setDropOffPolygon()
                self.markerIconImage.image = UIImage(named: "pin_dropoff_map")
                self.markerImage.image = UIImage(named: "pin_dropoff_map")
            }
        }
        
        
    }
    
    fileprivate func setDropOff() {
        if selectedRSDropStop != nil && selectedRSDropStation == nil {
            selectedRSDropStation = areas.filter({$0.code == selectedRSDropStop?.parent}).first!
        }
        
        if selectedRSDropStop != nil {
            selectedRSDropOffCoordinate = getCenterPointOfPolygon(bounds: selectedRSDropStop!.bound!)
        }
        
        if selectedRSPickStation != nil {
            selectedRSDropStop = nil
            selectedRSDropStation = nil
        }
    
        let rideData = RideSerivceLocationData(pickUpZone: selectedRSPickZone, pickUpStation: selectedRSPickStation, pickUpStop: selectedRSPickStop, dropOffZone: selectedRSDropZone, dropOfSftation: selectedRSDropStation, dropOffStop: selectedRSDropStop, pickUpCoordinate: selectedRSPickUpCoordinate, dropOffCoordinate: selectedRSDropOffCoordinate, passsengerCount: countOfPassenger)
        print(rideData)
        (self.viewModel as! KTXpressLocationSetUpViewModel).rideLocationData = rideData
        (self.viewModel as! KTXpressLocationSetUpViewModel).fetchRideService()
    }
    
    func callDropOffAction() {
    //showBookThisRideScreen
        setDropLocations()
    }
    
    func callBookThisRideAction() {
        
    }
    
    func showAlertForLocationServerOn() {
        
    }
    
    func setPickUp(pick: String?) {
        guard pick != nil else {
            return
        }
        self.pickUpAddressLabel.text = pick
    }
    
    func setDropOffPolygon() {
        
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
            
            self.mapView.clear()
            
            self.showCurrentLocationDot(show: true)
                    
            self.addMarkerOnMap(markerData: Area(), location: selectedRSPickUpCoordinate!, image: #imageLiteral(resourceName: "pin_pickup_map"))
                    
            self.mapView.setMinZoom(4.6, maxZoom: 20)
            
            var rect = [GMSMutablePath]()
            if selectedRSPickStop != nil || selectedRSPickStation != nil {
                rect.append(self.polygon(bounds: (selectedRSPickStation?.bound!)!, type: "Pick"))
                self.picupRect = rect.first!
                
            } else {
                rect.append(self.polygon(bounds: (selectedRSPickZone?.bound!)!, type: "Pick"))
                self.picupRect = rect.first!
                
            }
        
            for item in self.destinationForPickUp {
                
                if item.type! != "Zone" {
                                                
                    if item.type == "TramStation"{
                        self.addMarkerOnMap(markerData: item, location: getCenterPointOfPolygon(bounds: item.bound!), image: #imageLiteral(resourceName: "tram_ico_map"))
                        selectedRSDropOffCoordinate = xpressRebookSelected == true ? selectedRSDropOffCoordinate : getCenterPointOfPolygon(bounds: item.bound!)
                        rect.append(self.polygon(bounds: item.bound!, type: ""))
                        let camera = GMSCameraPosition.camera(withLatitude: selectedRSDropOffCoordinate!.latitude, longitude: selectedRSDropOffCoordinate!.longitude, zoom: item.type! == "Zone" ? 15 : 19)
                        self.mapView.animate(to: camera)
                    } else if item.type == "MetroStation"{
                        self.addMarkerOnMap(markerData: item, location: getCenterPointOfPolygon(bounds: item.bound!), image: #imageLiteral(resourceName: "metro_ico_map"))
                        selectedRSDropOffCoordinate = xpressRebookSelected == true ? selectedRSDropOffCoordinate : getCenterPointOfPolygon(bounds: item.bound!)
                        rect.append(self.polygon(bounds: item.bound!, type: ""))
                        let camera = GMSCameraPosition.camera(withLatitude: selectedRSDropOffCoordinate!.latitude, longitude: selectedRSDropOffCoordinate!.longitude, zoom: item.type! == "Zone" ? 15 : 19)
                        self.mapView.animate(to: camera)
                    } else if item.type == "MetroStop" || item.type == "TramStop" {
                        selectedRSDropOffCoordinate = xpressRebookSelected == true ? selectedRSDropOffCoordinate : getCenterPointOfPolygon(bounds: item.bound!)
                        let camera = GMSCameraPosition.camera(withLatitude: selectedRSDropOffCoordinate!.latitude, longitude: selectedRSDropOffCoordinate!.longitude, zoom: item.type! == "Zone" ? 15 : 19)
                        self.mapView.animate(to: camera)
                    }

                } else {
                    selectedRSDropOffCoordinate = xpressRebookSelected == true ? selectedRSDropOffCoordinate : getCenterPointOfPolygon(bounds: item.bound!)
                    rect.append(self.polygon(bounds: item.bound!, type: ""))
                    let camera = GMSCameraPosition.camera(withLatitude: selectedRSDropOffCoordinate!.latitude, longitude: selectedRSDropOffCoordinate!.longitude, zoom: item.type! == "Zone" ? 15 : 19)
                    self.mapView.animate(to: camera)
                }
                
            }
            
            self.locateCountry(pathG: rect)
            
            self.markerIconImage.image = UIImage(named: "pin_dropoff_map")

        }
        
        
    }
    
    func focusMapToFitRoute(pointA: CLLocationCoordinate2D, pointB: CLLocationCoordinate2D, path: GMSMutablePath, inset: UIEdgeInsets) {

      if pointA.latitude == 0 && pointA.longitude == 0 {
        return
      }

      //var bounds: GMSCoordinateBounds

      let c1 = pointA // swiftlint:disable:this identifier_name
      let c2 = pointB // swiftlint:disable:this identifier_name

      let mapCenter = CLLocationCoordinate2DMake((c1.latitude + c2.latitude)/2, (c1.longitude + c2.longitude)/2)

      var bounds = GMSCoordinateBounds.init(coordinate: mapCenter, coordinate: mapCenter)

      bounds = bounds.includingCoordinate(c1)
      bounds = bounds.includingCoordinate(c2)
      bounds = bounds.includingPath(path)

      if let mutableCamera: GMSMutableCameraPosition = self.mapView.camera.mutableCopy() as? GMSMutableCameraPosition {
        mutableCamera.target = mapCenter
        self.mapView.camera = mutableCamera
        self.mapView.animate(with: GMSCameraUpdate.fit(bounds, with: inset))
      }
    }
    
    func locateCountry(pathG: [GMSMutablePath]) {
        // 1. Create one quarter earth filling polygon
        let fillingPath = GMSMutablePath()
        fillingPath.addLatitude(90.0, longitude: -90.0)
        fillingPath.addLatitude(90.0, longitude: 90.0)
        fillingPath.addLatitude(0, longitude: 90.0)
        fillingPath.addLatitude(0, longitude: -90.0)

        let fillingPolygon = GMSPolygon(path:fillingPath)
        let fillColor = UIColor.gray.withAlphaComponent(0.7)
        fillingPolygon.fillColor = fillColor
        fillingPolygon.map = self.mapView

        if selectedRSPickStation == nil {
            fillingPolygon.holes = [pathG.first!]
            let fillingPolygonn = GMSPolygon(path: picupRect)
            let fillColor = UIColor.gray.withAlphaComponent(0.7)
            fillingPolygonn.fillColor = fillColor
            fillingPolygonn.map = self.mapView

            // 2. Add prepared array of GMSPath
            for path in pathG {
                let polygon = GMSPolygon(path: path)
                if picupRect == path {
                    polygon.fillColor = UIColor.clear
                } else {
                    fillingPolygonn.holes?.append(path)
                    polygon.fillColor = UIColor.white
                }
                polygon.strokeColor = .black
                polygon.strokeWidth = 2
                polygon.map = mapView
                let inset = UIEdgeInsets(top: 100, left: 50, bottom: 100, right: 50)
                focusMapToFitRoute(pointA: path.coordinate(at: 0),
                                   pointB: path.coordinate(at: path.count()-1),
                                   path: path,
                                   inset: inset)
            }
        } else {
            // 2. Add prepared array of GMSPath
            fillingPolygon.holes = pathG

    //        // 3. Add lines for boundaries
            for path in pathG {

                let polygon = GMSPolygon(path: path)
                
                if picupRect == path {
                    polygon.fillColor = UIColor.gray.withAlphaComponent(0.7)
                } else {
                    polygon.fillColor = UIColor.white.withAlphaComponent(0.4)
                }
                
                polygon.strokeColor = .black
                polygon.strokeWidth = 2
                polygon.map = mapView
                
//                let inset = UIEdgeInsets(top: 100, left: 50, bottom: 100, right: 50)
//                focusMapToFitRoute(pointA: path.coordinate(at: 0),
//                                   pointB: path.coordinate(at: path.count()-1),
//                                   path: path,
//                                   inset: inset)
            }
        }
    
    }
    
    func polygon(bounds: String, type: String) -> GMSMutablePath {
        
        // Create a rectangular path
        let rect = GMSMutablePath()
                
        _ = bounds.components(separatedBy: ";").map{$0.components(separatedBy: ",")}.map{$0.map({Double($0)!})}.map { (value) -> CLLocationCoordinate2D in
            rect.add(CLLocationCoordinate2D(latitude: value[0], longitude: value[1]))
            
           return CLLocationCoordinate2D(latitude: value[0], longitude: value[1])
        }
        
        return rect
    }
    
    func showDropOffViewController(destinationForPickUp: [Area], pickUpStation: Area?, pickUpStop: Area?, pickUpzone: Area?, coordinate: CLLocationCoordinate2D, zonalArea: [[String : [Area]]]) {
        
    }
    
    func showStopAlertViewController(stops: [Area], selectedStation: Area) {
        
        let alert = UIAlertController(title: "\(selectedStation.name!) " + "str_stop".localized(), message: "str_select_stop".localized(), preferredStyle: .actionSheet)
        
        for item in stops {
            alert.addAction(UIAlertAction(title: item.name!, style: .default , handler:{ (UIAlertAction)in
                self.tapOnMarker = true
                print("User click Approve button")
                if self.pickUpSelected == true {
                    selectedRSPickZone = areas.filter({$0.code == selectedStation.parent}).first!
                    selectedRSPickStation = selectedStation
                    selectedRSPickStop = item
                    if selectedRSPickStop != nil {
                        selectedRSPickUpCoordinate = getCenterPointOfPolygon(bounds: selectedRSPickStop!.bound!)
                    }
                    let new = destinations.filter({$0.source == selectedRSPickStop?.code}).map({$0.destination})
                    if new.count > 0 {
                        selectedRSPickZone = zones.filter({$0.code! == new.first!}).first!
                    }
                    self.setDestinationsForSelectedLocation()
                    self.setDropOffViewUI()
                    self.setDropOffPolygon()
                    self.markerIconImage.image = UIImage(named: "pin_dropoff_map")
                    self.markerImage.image = UIImage(named: "pin_dropoff_map")
                } else {
                    selectedRSDropStation = selectedStation
                    selectedRSDropStop = item
                    self.setDropOff()
                }
            }))
        }

        alert.addAction(UIAlertAction(title: "str_cancel".localized(), style: .cancel, handler: { alert in
            
        }))
        
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
        
    }
    
    func showAlertForStation(station: Area) {
        
        self.pickUpAddressLabel.text = station.name
            let alert = CDAlertView(title: "str_metro_station".localized(), message: station.name, type: .custom(image: UIImage(named:"metro_big")!))
            alert.hideAnimations = { (center, transform, alpha) in
                alpha = 0
            }
            let yesAction = CDAlertViewAction(title: pickUpSelected ? "SETPICKUP".localized() : "SETDROPOFF".localized()) { value in
                self.tapOnMarker = true
                if self.pickUpSelected {
                    selectedRSPickStation = station
                    selectedRSPickZone = areas.filter({$0.code! == selectedRSPickStation?.parent!}).first!
                    selectedRSPickStop = stops.filter({$0.parent! == selectedRSPickStation?.code!}).first!
                    if selectedRSPickStop != nil {
                        selectedRSPickUpCoordinate = getCenterPointOfPolygon(bounds: selectedRSPickStop!.bound!)
                    }
                    self.setDestinationsForSelectedLocation()
                    self.setDropOffViewUI()
                    self.setDropOffPolygon()
                    self.markerIconImage.image = UIImage(named: "pin_dropoff_map")
                    self.markerImage.image = UIImage(named: "pin_dropoff_map")
                } else {
                    self.setDropOff()
                }
                return true
            }
            let noAction = CDAlertViewAction(title: "str_no".localized()) { value in
                return true
            }
            alert.hideAnimations = { (center, transform, alpha) in
                alpha = 0
            }
            alert.add(action: noAction)
            alert.add(action: yesAction)
            alert.show()
        
       
    }
    
    func showRideServiceViewController(rideLocationData: RideSerivceLocationData?, rideInfo: RideInfo?) {
        rideService = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "KTXpressRideCreationViewController") as? KTXpressRideCreationViewController
        rideService!.rideServicePickDropOffData = rideLocationData
        rideService!.rideInfo = rideInfo
        rideService!.exploreDelegate = self
        rideService!.fromRideHistory = fromRideHistory
        self.add(rideService!)
        closeButton.isHidden = false
        self.view.bringSubview(toFront: closeButton)
//        self.navigationController?.pushViewController(rideService!, animated: true)
    }
    
    func showAlertForFailedRide(message: String) {
        
        let alert = UIAlertController(title: message, message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "str_ok".localized(), style: .cancel, handler: { alert in
            
        }))
        self.present(alert, animated: true, completion: {
            print("completion block")
            self.backToPickUpWithMessageSelected = false
        })

        
//        let alert = CDAlertView(title: message, message: "", type: .custom(image: UIImage(named:"icon-notifications")!))
//        alert.hideAnimations = { (center, transform, alpha) in
//            alpha = 0
//        }
//        let doneAction = CDAlertViewAction(title: "str_ok".localized()) { value in
//            return true
//        }
//
//        alert.add(action: doneAction)
//        alert.show()
    }
    
    func backToPickUp(withMessage: String) {
        let alert = CDAlertView(title: withMessage, message: "", type: .custom(image: UIImage(named:"icon-notifications")!))
        alert.hideAnimations = { (center, transform, alpha) in
            alpha = 0
            self.backToPickUpWithMessageSelected = true
            self.backToPreviousPickUp = true
            self.backToPickUp()
        }
        let doneAction = CDAlertViewAction(title: "str_ok".localized()) { value in
            return true
        }
        alert.add(action: doneAction)
        alert.show()
    }
    
    @IBAction func showAddressPickerViewController(_ sender: UIButton) {
        let destination = (self.storyboard?.instantiateViewController(withIdentifier: "KTAddressPickerViewController") as? KTAddressPickerViewController)!
        destination.delegateAddress = self
        destination.fromDropOff = pickUpSelected
        destination.xpressLocation = true
        destination.modalPresentationStyle = .fullScreen
        print(self.pickUpAddressLabel.text)

        if pickUpSelected == false {
            
            if selectedRSPickStation != nil {
                destination.pickupAddress =  KTBookingManager().geoLocaiton(forLocationId: Int32(Int.random(in: 1..<100000)), latitude: selectedRSPickUpCoordinate?.latitude ?? 0.0, longitude: selectedRSPickUpCoordinate?.longitude ?? 0.0, name: selectedRSPickStation?.name ?? "")
            } else if selectedRSPickZone != nil {
                destination.pickupAddress =  KTBookingManager().geoLocaiton(forLocationId: Int32(Int.random(in: 1..<100000)), latitude: selectedRSPickUpCoordinate?.latitude ?? 0.0, longitude: selectedRSPickUpCoordinate?.longitude ?? 0.0, name: pickAddressText)
            }
                    
            destination.dropoffAddress = KTBookingManager().geoLocaiton(forLocationId: Int32(Int.random(in: 1000000..<100000000)), latitude: selectedRSDropOffCoordinate?.latitude ?? 0.0, longitude: selectedRSDropOffCoordinate?.longitude ?? 0.0, name: self.pickUpAddressLabel.text ?? "")
            
            
        } else {
            self.setPickUpLocationsForAddressScreen()
            
            pickAddressText = self.pickUpAddressLabel.text ?? ""
            if selectedRSPickStation != nil {
                destination.pickupAddress =  KTBookingManager().geoLocaiton(forLocationId: Int32(Int.random(in: 1..<100000)), latitude: selectedRSPickUpCoordinate?.latitude ?? 0.0, longitude: selectedRSPickUpCoordinate?.longitude ?? 0.0, name: selectedRSPickStation?.name ?? "")
            } else {
                destination.pickupAddress =  KTBookingManager().geoLocaiton(forLocationId: Int32(Int.random(in: 1..<100000)), latitude: selectedRSPickUpCoordinate?.latitude ?? 0.0, longitude: selectedRSPickUpCoordinate?.longitude ?? 0.0, name: self.pickAddressText)
            }
        }
        
        if selectedRSPickStation != nil && pickUpSelected == true{
            let stopsOfStations = stops.filter({$0.parent == selectedRSPickStation?.code!})
            destination.fromDropOff = true
            self.getDestinationForAddressScreen()
            destination.metroStations = pickUpArea
//            destination.metroStations = destinationForPickUp
            if stopsOfStations.count == 1 {
                selectedRSPickStop = stopsOfStations.first!
                destination.pickupAddress = KTBookingManager().geoLocaiton(forLocationId: Int32(Int.random(in: 1..<100000)), latitude: selectedRSPickUpCoordinate?.latitude ?? 0.0, longitude: selectedRSPickUpCoordinate?.longitude ?? 0.0, name: selectedRSPickStation?.name ?? "")
                self.present(destination, animated: true)
            } else {
                self.showStopAlertAddressViewController(stops: stopsOfStations, selectedStation: selectedRSPickStation!, addressScreen: destination)
            }
        } else {
            self.getDestinationForAddressScreen()
//            destination.destinationForPickUp = destinationForPickUp
            destination.metroStations = pickUpArea
            if pickUpSelected == false {
                destination.selectedTxtField = SelectedTextField.DropoffAddress
            } else if pickUpSelected == true {
                destination.selectedTxtField = SelectedTextField.PickupAddress
            }
            self.present(destination, animated: true)
        }

    }
    
    func showStopAlertAddressViewController(stops: [Area], selectedStation: Area, addressScreen: KTAddressPickerViewController) {
        
        let alert = UIAlertController(title: "\(selectedStation.name!) " + "str_stop".localized(), message: "str_select_stop".localized(), preferredStyle: .actionSheet)
        
        for item in stops {
            alert.addAction(UIAlertAction(title: item.name!, style: .default , handler:{ (UIAlertAction)in
                self.tapOnMarker = true
                print("User click Approve button")
                if self.pickUpSelected == true {
                    selectedRSPickZone = areas.filter({$0.code == selectedStation.parent}).first!
                    selectedRSPickStation = selectedStation
                    selectedRSPickStop = item
                    if selectedRSPickStop != nil {
                        selectedRSPickUpCoordinate = getCenterPointOfPolygon(bounds: selectedRSPickStop!.bound!)
                    }
                    self.setDestinationsForSelectedLocation()
                    addressScreen.pickupAddress = KTBookingManager().geoLocaiton(forLocationId: Int32(Int.random(in: 1..<100000)), latitude: selectedRSPickUpCoordinate?.latitude ?? 0.0, longitude: selectedRSPickUpCoordinate?.longitude ?? 0.0, name: selectedRSPickStop?.name ?? "")

                    self.present(addressScreen, animated: true)

                } else {
                    selectedRSDropZone = areas.filter({$0.code == selectedStation.parent}).first!
                    selectedRSDropStation = selectedStation
                    selectedRSDropStop = item
                    self.present(addressScreen, animated: true)

                }
            }))
        }

        alert.addAction(UIAlertAction(title: "str_cancel".localized(), style: .cancel, handler: { alert in
            
        }))
        
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
        
    }
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination : KTAddressPickerViewController = segue.destination as! KTAddressPickerViewController
        destination.delegateAddress = self
        destination.fromDropOff = pickUpSelected
        destination.xpressLocation = true
        print(self.pickUpAddressLabel.text)
        

        if pickUpSelected == false {
            
            if selectedRSPickStation != nil {
                destination.pickupAddress =  KTBookingManager().geoLocaiton(forLocationId: Int32(Int.random(in: 1..<100000)), latitude: selectedRSPickUpCoordinate?.latitude ?? 0.0, longitude: selectedRSPickUpCoordinate?.longitude ?? 0.0, name: selectedRSPickStation?.name ?? "")
            } else if selectedRSPickZone != nil {
                destination.pickupAddress =  KTBookingManager().geoLocaiton(forLocationId: Int32(Int.random(in: 1..<100000)), latitude: selectedRSPickUpCoordinate?.latitude ?? 0.0, longitude: selectedRSPickUpCoordinate?.longitude ?? 0.0, name: selectedRSPickZone?.name ?? "")
            }
                    
            destination.dropoffAddress = KTBookingManager().geoLocaiton(forLocationId: Int32(Int.random(in: 1000000..<100000000)), latitude: selectedRSDropOffCoordinate?.latitude ?? 0.0, longitude: selectedRSDropOffCoordinate?.longitude ?? 0.0, name: self.pickUpAddressLabel.text ?? "")
            
            
        } else {
            
            self.setPickUpLocationsForAddressScreen()

            if selectedRSPickStation != nil {
                destination.pickupAddress =  KTBookingManager().geoLocaiton(forLocationId: Int32(Int.random(in: 1..<100000)), latitude: selectedRSPickUpCoordinate?.latitude ?? 0.0, longitude: selectedRSPickUpCoordinate?.longitude ?? 0.0, name: selectedRSPickStation?.name ?? "")
            } else {
                destination.pickupAddress =  KTBookingManager().geoLocaiton(forLocationId: Int32(Int.random(in: 1..<100000)), latitude: selectedRSPickUpCoordinate?.latitude ?? 0.0, longitude: selectedRSPickUpCoordinate?.longitude ?? 0.0, name: self.pickUpAddressLabel.text ?? "")
            }
            
            
        }
            
        
        if selectedRSPickStation != nil {
            let stopsOfStations = stops.filter({$0.parent == selectedRSPickStation?.code!})
            destination.fromDropOff = true
            self.getDestinationForAddressScreen()
            destination.metroStations = pickUpArea
//            destination.metroStations = destinationForPickUp
            if stopsOfStations.count == 1 {
                selectedRSPickStop = stopsOfStations.first!
            } else {
                
            }
        } else {
            self.getDestinationForAddressScreen()
            destination.destinationForPickUp = destinationForPickUp
            destination.metroStations =  pickUpSelected ? pickUpArea : destinationForPickUp
            if pickUpSelected == false {
                destination.selectedTxtField = SelectedTextField.DropoffAddress
            } else if pickUpSelected == true {
                destination.selectedTxtField = SelectedTextField.PickupAddress
            }
        }
        
    }

}

extension KTXpressLocationPickerViewController: KTXpressAddressDelegate {

    fileprivate func updatePickDataFromAddressScreen(_ loc: Area, _ metroAreaCoordinate: CLLocationCoordinate2D) {
        selectedRSPickStation = loc
        let stopOfStations = areas.filter{$0.parent == selectedRSPickStation?.code}
        selectedRSPickStop = stopOfStations.first!
        selectedRSPickUpCoordinate = metroAreaCoordinate
        selectedRSPickZone = areas.filter{$0.code == selectedRSPickStation?.parent}.first!
        if stopOfStations.count > 1 {
            self.showStopAlertViewController(stops: stopOfStations, selectedStation: selectedRSPickStation!)
        } else {
            self.showAlertForStation(station: loc)
        }
    }
    
    fileprivate func updateDropOffDataFromAddressScreen(_ loc: Area, _ metroAreaCoordinate: CLLocationCoordinate2D) {
        selectedRSDropStation = loc
        let stopOfStations = areas.filter{$0.parent == selectedRSDropStation?.code}
        selectedRSDropStop = stopOfStations.first!
        selectedRSDropOffCoordinate = metroAreaCoordinate
        selectedRSDropZone = areas.filter{$0.code == selectedRSDropStation?.parent}.first!
        if stopOfStations.count > 1 {
            self.showStopAlertViewController(stops: stopOfStations, selectedStation: selectedRSDropStation!)
        } else {
            self.showAlertForStation(station: loc)
        }
    }
    
    func setLocation(picklocation: Any?, dropLocation: Any?, destinationForPickUp: [Area]?) {
        
        self.destinationForPickUp = destinationForPickUp ?? [Area]()
        
        if picklocation != nil && dropLocation != nil {
            pickUpSelected = false
//            let update :GMSCameraUpdate = GMSCameraUpdate.setTarget(selectedRSPickUpCoordinate!, zoom: KTXpressCreateBookingConstants.DEFAULT_MAP_ZOOM)
//            mapView.animate(with: update)
//            setPickUpPolygon()
//            setPickUpViewUI()
            
            let update1 :GMSCameraUpdate = GMSCameraUpdate.setTarget(selectedRSDropOffCoordinate!, zoom: 15)
            self.mapView.animate(with: update1)
            self.getDestinationForPickUp()
            if selectedRSDropZone == nil {
                self.setDropOffPolygon()
                self.setDropOffViewUI()
                self.updateValidPickUpUI()
            }
            
        } else if picklocation != nil {
            pickUpSelected = false
            let update :GMSCameraUpdate = GMSCameraUpdate.setTarget(selectedRSPickUpCoordinate!, zoom: KTXpressCreateBookingConstants.DEFAULT_MAP_ZOOM)
            mapView.animate(with: update)
            setDropOffPolygon()
            setDropOffViewUI()
            updateValidPickUpUI()

        }
        
    }
    
    func setLocation(location: Any) {
        addressSelected = true
        if let loc = location as? KTGeoLocation {
            print(location)
            
            if pickUpSelected == true {
                selectedRSPickUpCoordinate = CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude)
            } else {
                selectedRSDropOffCoordinate = CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude)
            }
            let actualLocation = CLLocation(latitude: loc.latitude, longitude: loc.longitude)
            self.setPickUp(pick: loc.name)
            KTLocationManager.sharedInstance.setCurrentLocation(location: actualLocation)
            let camera = GMSCameraPosition.camera(withLatitude: loc.latitude, longitude: loc.longitude, zoom: 15)
            mapView.camera = camera
            mapView.animate(to: camera)
            self.checkValidLocation(actualLocation)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let loc = location as? Area {
                    print(location)
                    self.tapOnMarker = true
                    let metroAreaCoordinate = getCenterPointOfPolygon(bounds: loc.bound!)
                    let camera = GMSCameraPosition.camera(withLatitude: metroAreaCoordinate.latitude, longitude: metroAreaCoordinate.longitude, zoom: 17)
                    self.mapView.camera = camera
                    self.pickUpAddressLabel.text = loc.name
                    self.updateValidPickUpUI()
                    
                    if self.pickUpSelected == true {
                        self.updatePickDataFromAddressScreen(loc, metroAreaCoordinate)
                    } else {
                        self.updateDropOffDataFromAddressScreen(loc, metroAreaCoordinate)
                    }
                }
            }
        }
    }
    
}

extension KTXpressLocationPickerViewController: RideExploreDelegate {
    func showPickUpScreen() {
        self.setInitialPassengerCount()
        self.backToPickUp()
        self.rideService?.remove()
    }
    func showDropOffScreen() {
        self.closeButton.isHidden = true
        self.rideService?.remove()
    }
}

// MARK: - MapView
extension KTXpressLocationPickerViewController: GMSMapViewDelegate, KTXpressLocationViewModelDelegate {
    
    internal func addMap() {
        
        mapView.clear()
        
        showCurrentLocationDot(show: true)
        
        let padding = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        mapView.padding = padding
                
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
        
        mapView.delegate = self
        
        let update :GMSCameraUpdate = GMSCameraUpdate.setTarget(CLLocationCoordinate2D(latitude: 25.286106, longitude:  51.534817), zoom: KTXpressCreateBookingConstants.DEFAULT_MAP_ZOOM)
        mapView.animate(with: update)
    
    }
    
    internal func showCurrentLocationDot(show: Bool) {
        
        self.mapView!.isMyLocationEnabled = show
        //self.mapView!.settings.myLocationButton = show
    }
    
    func setPickUpPolygon() {
        
        pickUpSelected = true
        
        self.mapView.clear()
        
        // Create a rectangular path
        let string = areas.filter{$0.type! == "OperatingArea"}.first?.bound ?? ""
        
        let operatingArea = string.components(separatedBy: "|")
        
        var rects = [GMSMutablePath]()
        
        for item in operatingArea {
            
            let rect = GMSMutablePath()
            
            _ = item.components(separatedBy: ";").map{$0.components(separatedBy: ",")}.map{$0.map({Double($0) ?? 0.0})}.map { (value) -> CLLocationCoordinate2D in
                rect.add(CLLocationCoordinate2D(latitude: value[0], longitude: value[1]))
                return CLLocationCoordinate2D(latitude: value[0], longitude: value[1])
            }
            
            rects.append(rect)
            
            if addressSelected == false { //address selection should be false
                if backToPreviousPickUp == false { //click back button should be false
                    let coordinate = CLLocationCoordinate2D(latitude: xpressRebookSelected == true ? selectedRSPickUpCoordinate?.latitude ?? 0.0 : getCenterPointOfPolygon(bounds: item).latitude, longitude: xpressRebookSelected == true ? selectedRSPickUpCoordinate?.longitude ?? 0.0 : getCenterPointOfPolygon(bounds: item).longitude)
                    let camera = GMSCameraPosition.camera(withLatitude: coordinate.latitude, longitude: coordinate.longitude, zoom: 15)
                    self.mapView.animate(to: camera)
                    KTLocationManager.sharedInstance.currentLocation = CLLocation(latitude:  coordinate.latitude, longitude: coordinate.longitude)
                    if pickUpSelected == true {
                        selectedRSPickUpCoordinate = CLLocationCoordinate2D(latitude: KTLocationManager.sharedInstance.currentLocation.coordinate.latitude, longitude: KTLocationManager.sharedInstance.currentLocation.coordinate.longitude)
                    }
                    
                    if let currentLocation = self.mapView.myLocation {
                        if checkLatLonInside(location: currentLocation) {
                            let camera = GMSCameraPosition.camera(withLatitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude, zoom: 15)
                            self.mapView.animate(to: camera)
                            KTLocationManager.sharedInstance.currentLocation = currentLocation// CLLocation(latitude:  coordinate.latitude, longitude: coordinate.longitude)
                            selectedRSPickUpCoordinate = CLLocationCoordinate2D(latitude: KTLocationManager.sharedInstance.currentLocation.coordinate.latitude, longitude: KTLocationManager.sharedInstance.currentLocation.coordinate.longitude)
                        } else {
                            if checkLatLonInsideZone(location: currentLocation).0 {
                                let nearByZone = checkLatLonInsideZone(location: currentLocation).1
                                let loc = CLLocation(latitude: getCenterPointOfPolygon(bounds: nearByZone.bound!).latitude, longitude: getCenterPointOfPolygon(bounds: nearByZone.bound!).longitude)
                                let camera = GMSCameraPosition.camera(withLatitude: getCenterPointOfPolygon(bounds: nearByZone.bound!).latitude, longitude: getCenterPointOfPolygon(bounds: nearByZone.bound!).longitude, zoom: 15)
                                self.mapView.animate(to: camera)
                                KTLocationManager.sharedInstance.currentLocation = loc
                            }
                        }
                    }
                    
                }
            }
            
        }
        

        // 1. Create one quarter earth filling polygon
        let fillingPath = GMSMutablePath()
        fillingPath.addLatitude(90.0, longitude: -90.0)
        fillingPath.addLatitude(90.0, longitude: 90.0)
        fillingPath.addLatitude(0, longitude: 90.0)
        fillingPath.addLatitude(0, longitude: -90.0)
        
        let fillingPolygon = GMSPolygon(path:fillingPath)
        let fillColor = UIColor.gray.withAlphaComponent(0.7)
        fillingPolygon.fillColor = fillColor
        fillingPolygon.map = self.mapView
        
        // 2. Add prepared array of GMSPath
        fillingPolygon.holes = rects
        
        // 3. Add lines for boundaries
        for path in rects {
            let polygon = GMSPolygon(path: path)
            polygon.fillColor = UIColor.white.withAlphaComponent(0.4)
            polygon.strokeColor = .black
            polygon.strokeWidth = 2
            polygon.map = mapView
        }
        
        print(string)
        
        if xpressRebookSelected == true {
            self.callSetPickUpAction()
            self.callDropOffAction()
            xpressRebookSelected = false
        }
        
    }
    
    fileprivate func checkValidLocation(_ location: CLLocation) {
        if checkLatLonInside(location: location) {
            self.updateValidPickUpUI()
        } else {
            self.updateOutOfZonePickUpUI()
        }
    }
    
    fileprivate func checkCoordinateStatus(_ location: CLLocation) {
        if areas.count > 0 {
            if pickUpSelected {
                checkValidLocation(location)
            } else {
                checkPermittedDropOff(location)
            }
        }
    }
    
    func checkPermittedDropOff(_ location: CLLocation) {
        
        for item in destinationForPickUp {
            
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
                        self.setLocationButton.setTitle("SETTODROPZONE".localized(), for: .normal)
                        self.setLocationButton.backgroundColor = UIColor.clear
                        self.markerImage.image = #imageLiteral(resourceName: "pin_outofzone")
                        self.setLocationButton.setTitleColor(UIColor(hexString: "#8EA8A7"), for: .normal)
                        self.setLocationButton.isUserInteractionEnabled = false
                    }
                    else {
                        print("Permitted")
                        self.setLocationButton.setTitle("str_dropoff".localized(), for: .normal)
                        self.setLocationButton.setTitleColor(UIColor.white, for: .normal)
                        self.markerImage.image = pickUpSelected ? #imageLiteral(resourceName: "pickup_address_ico") : #imageLiteral(resourceName: "pin_dropoff_map")
                        self.setLocationButton.isUserInteractionEnabled = true
                        self.setLocationButton.backgroundColor = UIColor(hexString: "#4BA5A7")
                        self.setLocationButton.isUserInteractionEnabled = true
                        break
                    }
                } else {
                    print("Permitted")
                    self.setLocationButton.setTitle("str_dropoff".localized(), for: .normal)
                    self.setLocationButton.setTitleColor(UIColor.white, for: .normal)
                    self.markerImage.image = pickUpSelected ? #imageLiteral(resourceName: "pickup_address_ico") : #imageLiteral(resourceName: "pin_dropoff_map")
                    self.setLocationButton.isUserInteractionEnabled = true
                    self.setLocationButton.backgroundColor = UIColor(hexString: "#4BA5A7")
                    self.setLocationButton.isUserInteractionEnabled = true
                    break
                }
                
            } else {
                
                if selectedRSPickZone != nil {
                    
                    let pickupCoordinates = selectedRSPickZone!.bound!.components(separatedBy: ";").map{$0.components(separatedBy: ",")}.map{$0.map({Double($0)!})}.map { (value) -> CLLocationCoordinate2D in
                        return CLLocationCoordinate2D(latitude: value[0], longitude: value[1])
                    }
                    
                    if CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude).contained(by: pickupCoordinates) {
                        print("not permitted")
                        self.setLocationButton.setTitle("SETTODROPZONE".localized(), for: .normal)
                    } else {
                        print("it wont contains")
                        self.setLocationButton.setTitle("str_outzone".localized(), for: .normal)
                    }

                    self.setLocationButton.backgroundColor = UIColor.clear
                    self.markerImage.image = #imageLiteral(resourceName: "pin_outofzone")
                    self.setLocationButton.setTitleColor(UIColor(hexString: "#8EA8A7"), for: .normal)
                    self.setLocationButton.isUserInteractionEnabled = false
                    
                } else {
                    
                    print("it wont contains")
                    self.setLocationButton.setTitle("str_outzone".localized(), for: .normal)
                    self.setLocationButton.backgroundColor = UIColor.clear
                    self.markerImage.image = #imageLiteral(resourceName: "pin_outofzone")
                    self.setLocationButton.setTitleColor(UIColor(hexString: "#8EA8A7"), for: .normal)
                    self.setLocationButton.isUserInteractionEnabled = false
//                    self.setDropOffButton.layer.shadowColor = UIColor.clear.cgColor
                    
                }
                
                
            }
            
        }
    }
    
    func addPickUpLocations() {
        for item in pickUpArea {
            if item.type == "MetroStation" || item.type == "MetroStop" {
                addMarkerOnMap(markerData: item, location: getCenterPointOfPolygon(bounds: item.bound!), image:  #imageLiteral(resourceName: "metro_ico_map"))
            } else {
                addMarkerOnMap(markerData: item, location: getCenterPointOfPolygon(bounds: item.bound!), image:  #imageLiteral(resourceName: "tram_ico_map"))
            }
        }
    }
    
    func addMarkerOnMap(markerData: Area, location: CLLocationCoordinate2D, image: UIImage) {
        let marker = GMSMarker()
        marker.position = location
        marker.userData = markerData
        marker.icon = image
        marker.map = self.mapView
        if markerData.name?.count ?? 0 == 0 {
            marker.isTappable = false
            marker.groundAnchor = CGPoint(x:0.2,y:1)
        } else {
            marker.isTappable = true
            marker.groundAnchor = CGPoint(x:0.3,y:0.5)
        }
    }
    
    fileprivate func resetValues() {
        if pickUpSelected == true {
            selectedRSPickStation = nil
            selectedRSPickZone = nil
            selectedRSPickStop  = nil
        } else {
            selectedRSDropStop = nil
            selectedRSDropZone = nil
            selectedRSDropStation = nil
        }
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        addressSelected = false
       // resetValues()
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        let location = CLLocation(latitude: mapView.camera.target.latitude, longitude: mapView.camera.target.longitude)
        self.checkCoordinateStatus(location)
        if tapOnMarker == false {
            if self.pickUpSelected == true {
                selectedRSPickUpCoordinate = location.coordinate
            } else {
                selectedRSDropOffCoordinate = location.coordinate
            }
        } else {
            tapOnMarker = false
        }
        (self.viewModel as! KTXpressLocationSetUpViewModel).fetchLocationName(forGeoCoordinate: location.coordinate)
    }
    
    fileprivate func setPickUpLocationData(_ marker: GMSMarker) {
        selectedRSPickStation = marker.userData as? Area
        let stopOfStations = areas.filter{$0.parent == selectedRSPickStation?.code}
        selectedRSPickStop = stopOfStations.first!
        selectedRSPickUpCoordinate = CLLocationCoordinate2D(latitude: marker.position.latitude, longitude: marker.position.longitude)
        selectedRSPickZone = areas.filter{$0.code == selectedRSPickStation?.parent}.first!
        
        let new = destinations.filter({$0.source == selectedRSPickStop?.code})
        var stationsStop = [Area]()
        
        for item in new {
            stationsStop = stopOfStations.filter({$0.code! == item.source})
        }
        print("stationsStop", stationsStop)
        
        if stopOfStations.count > 1 {
            self.showStopAlertViewController(stops: stopOfStations, selectedStation: selectedRSPickStation!)
        } else {
//            selectedRSPickStop = stationsStop.first!
            showAlertForStation(station: (marker.userData as! Area))
        }
    }
    
    fileprivate func setDropOffLocationData(_ marker: GMSMarker) {
        selectedRSDropStation = marker.userData as? Area
        let stopOfStations = areas.filter{$0.parent == selectedRSDropStation?.code}
        selectedRSDropZone = areas.filter{$0.code == selectedRSDropStation?.parent}.first!
        selectedRSDropStop = stopOfStations.first!
        selectedRSDropOffCoordinate = CLLocationCoordinate2D(latitude: marker.position.latitude, longitude: marker.position.longitude)
        
        let new = destinations.filter({$0.source == selectedRSPickZone?.code})
        var stationsStop = [Area]()
        
        if selectedRSPickStation == nil && selectedRSPickStop == nil {
            for item in new {
                stationsStop = stopOfStations.filter({$0.code! == item.destination})
            }
            print("stationsStop", stationsStop)
        }

        if stopOfStations.count > 1 && stationsStop.count == 0 {
            self.showStopAlertViewController(stops: stopOfStations, selectedStation: selectedRSDropStation!)
        } else {
            if stationsStop.count > 0 {
                selectedRSDropStop = stationsStop.first!
            } else {
                selectedRSDropStop = stopOfStations.first!
            }
            showAlertForStation(station: (marker.userData as! Area))
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        self.tapOnMarker = true

        let camera = GMSCameraPosition.camera(withLatitude: marker.position.latitude, longitude: marker.position.longitude, zoom: 17.0)
        self.mapView.animate(to: camera)
        
        if pickUpSelected == true {
            setPickUpLocationData(marker)
        } else {
            setDropOffLocationData(marker)
        }
        
        pickUpAddressLabel.text = (marker.userData as! Area).name
        updateValidPickUpUI()
        
        return true
        
    }
    
    fileprivate func setPickUpLocationsForAddressScreen() {
        selectedRSPickZone = nil
        selectedRSPickStation = nil
        selectedRSPickStop = nil
        
        for item in zones {
            let coordinates = (item.bound?.components(separatedBy: ";").map{$0.components(separatedBy: ",")}.map{$0.map({Double($0)!})}.map { (value) -> CLLocationCoordinate2D in
                return CLLocationCoordinate2D(latitude: value[0], longitude: value[1])
            })!
            if  CLLocationCoordinate2D(latitude: selectedRSPickUpCoordinate?.latitude ?? 0.0, longitude: selectedRSPickUpCoordinate?.longitude ?? 0.0).contained(by: coordinates) {
                if selectedRSPickZone != item {
                    self.backToPickUpWithMessageSelected = false
                }
                selectedRSPickZone = item
                break
            }
        }
        
        if selectedRSPickZone != nil {
            let stations = areas.filter({$0.parent! == selectedRSPickZone!.code!})
            if stations.count > 0 {
                for item in stations ?? [Area]() {
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
    }
    
    fileprivate func setPickUpLocations() {
        selectedRSPickZone = nil
        selectedRSPickStation = nil
        selectedRSPickStop = nil
        
        for item in zones {
            let coordinates = (item.bound?.components(separatedBy: ";").map{$0.components(separatedBy: ",")}.map{$0.map({Double($0)!})}.map { (value) -> CLLocationCoordinate2D in
                return CLLocationCoordinate2D(latitude: value[0], longitude: value[1])
            })!
            if  CLLocationCoordinate2D(latitude: selectedRSPickUpCoordinate?.latitude ?? 0.0, longitude: selectedRSPickUpCoordinate?.longitude ?? 0.0).contained(by: coordinates) {
                if selectedRSPickZone != item {
                    self.backToPickUpWithMessageSelected = false
                }
                selectedRSPickZone = item
                break
            }
        }
        
        if selectedRSPickZone != nil {
            let stations = areas.filter({$0.parent! == selectedRSPickZone!.code!})
            if stations.count > 0 {
                for item in stations {
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
            
            let stopOfStations = areas.filter{$0.parent == selectedRSPickStation?.code}
            selectedRSPickStop = stopOfStations.first!
            selectedRSPickUpCoordinate = getCenterPointOfPolygon(bounds: selectedRSPickStation?.bound! ?? "")
            selectedRSPickZone = areas.filter{$0.code == selectedRSPickStation?.parent}.first!
            
            let new = destinations.filter({$0.source == selectedRSPickStop?.code})
            var stationsStop = [Area]()
            
            for item in new {
                stationsStop = stopOfStations.filter({$0.code! == item.source})
            }
            print("stationsStop", stationsStop)
            
            if stopOfStations.count > 1 {
                self.showStopAlertViewController(stops: stopOfStations, selectedStation: selectedRSPickStation!)
            } else {
                showAlertForStation(station: selectedRSPickStation!)
            }
            
        } else {
            var sourceStop = [Area]()
            for item in stops {
                if let destinationCode =  destinations.filter({$0.source == item.code!}).map({$0.source!}).first {
                    sourceStop.append(contentsOf: (areas.filter{$0.code == destinationCode}))
                }
            }
            for item in sourceStop {
                let station = areas.filter({$0.code == item.parent}).first!
                let coordinates = (station.bound?.components(separatedBy: ";").map{$0.components(separatedBy: ",")}.map{$0.map({Double($0)!})}.map { (value) -> CLLocationCoordinate2D in
                    return CLLocationCoordinate2D(latitude: value[0], longitude: value[1])
                })!
                if  CLLocationCoordinate2D(latitude: selectedRSPickUpCoordinate?.latitude ?? 0.0, longitude: selectedRSPickUpCoordinate?.longitude ?? 0.0).contained(by: coordinates) {
                    selectedRSPickStop = item
                    selectedRSPickStation = station
                    
                    let stopOfStations = areas.filter{$0.parent == selectedRSPickStation?.code}
                    selectedRSPickUpCoordinate = getCenterPointOfPolygon(bounds: selectedRSPickStation?.bound! ?? "")
                    selectedRSPickZone = areas.filter{$0.code == selectedRSPickStation?.parent}.first!
                    
                    let new = destinations.filter({$0.source == selectedRSPickStop?.code})
                    var stationsStop = [Area]()
                    
                    for item in new {
                        stationsStop = stopOfStations.filter({$0.code! == item.source})
                    }
                    print("stationsStop", stationsStop)
                    
                    if stopOfStations.count > 1 {
                        self.showStopAlertViewController(stops: stopOfStations, selectedStation: selectedRSPickStation!)
                    } else {
            //            selectedRSPickStop = stationsStop.first!
                        showAlertForStation(station: selectedRSPickStation!)
                    }
                    
                    break
                }
            }
        }
    }
    
    fileprivate func setAddressDropLocation() {
        
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
            var destinationStation = [Area]()
            for item in stationsOfZone ?? [Area]() {
                if let destinationCode =  destinations.filter({$0.destination == item.code!}).map({$0.destination!}).first {
                    destinationStation.append(contentsOf: (areas.filter{$0.code == destinationCode}))
                }
            }
            for item in destinationStation ?? [Area]() {
                let coordinates = (item.bound?.components(separatedBy: ";").map{$0.components(separatedBy: ",")}.map{$0.map({Double($0)!})}.map { (value) -> CLLocationCoordinate2D in
                    return CLLocationCoordinate2D(latitude: value[0], longitude: value[1])
                })!
                if  CLLocationCoordinate2D(latitude: selectedRSDropOffCoordinate?.latitude ?? 0.0, longitude: selectedRSDropOffCoordinate?.longitude ?? 0.0).contained(by: coordinates) {
                    selectedRSDropStation = item
                    tapOnMarker = true
                    break
                }
            }
        } else if selectedRSDropStation != nil && selectedRSDropStop == nil {
            let stopOfStations = areas.filter{$0.parent == selectedRSDropStation?.code}
            selectedRSDropZone = areas.filter{$0.code == selectedRSDropStation?.parent}.first!
            selectedRSDropStop = stopOfStations.first!
            selectedRSDropOffCoordinate = getCenterPointOfPolygon(bounds: selectedRSDropStation?.bound! ?? "")
            let new = destinations.filter({$0.source == selectedRSPickZone?.code})
            var stationsStop = [Area]()
            if selectedRSPickStation == nil && selectedRSPickStop == nil {
                for item in new {
                    stationsStop = stopOfStations.filter({$0.code! == item.destination})
                }
                print("stationsStop", stationsStop)
            }
            if tapOnMarker == true {
                if stopOfStations.count > 1 && stationsStop.count == 0 {
                    self.showStopAlertViewController(stops: stopOfStations, selectedStation: selectedRSDropStation!)
                } else {
                    selectedRSDropStop = stopOfStations.first!
                    showAlertForStation(station: selectedRSDropStation!)
                }
            }
        }
    }
    
    fileprivate func setDropStop(_ dropOffCalled: inout Bool) {
        let stopOfStations = areas.filter{$0.parent == selectedRSDropStation?.code}
        selectedRSDropStop = stopOfStations.first!
        selectedRSDropOffCoordinate = getCenterPointOfPolygon(bounds: selectedRSDropStation?.bound! ?? "")
        
        let new = destinations.filter({$0.source == selectedRSPickZone?.code})
        var stationsStop = [Area]()
        
        if selectedRSPickStation == nil && selectedRSPickStop == nil {
            for item in new {
                stationsStop = stopOfStations.filter({$0.code! == item.destination})
            }
            print("stationsStop", stationsStop)
        }
        
        
        if tapOnMarker == true {
            if stopOfStations.count > 1 && stationsStop.count == 0 {
                self.showStopAlertViewController(stops: stopOfStations, selectedStation: selectedRSDropStation!)
            } else {
                if stationsStop.count > 0 {
                    selectedRSDropStop = stationsStop.first!
                } else {
                    selectedRSDropStop = stopOfStations.first!
                }
                showAlertForStation(station: selectedRSDropStation!)
            }
        } else {
            dropOffCalled = true
            let source = destinations.filter({$0.source == selectedRSPickStop?.code})
            if source.count > 0 {
                let new = source.map{$0.destination}
                if new.count > 0 {
                    for item in new {
                        selectedRSDropZone = zones.filter({$0.code! == item!}).first!
                    }
                }
            }
            setDropOff()
        }
    }
    
    fileprivate func setDropLocations() {
        
        var dropOffCalled = false
        var noDropZone = false
        
        var destination = destinations.filter({$0.source == selectedRSPickStop?.code})
        if destination.count > 0 {
            for item in destination {
                let pickupzones = zones.filter({$0.code == item.destination!})
                for item in pickupzones {
                    let coordinates = (item.bound?.components(separatedBy: ";").map{$0.components(separatedBy: ",")}.map{$0.map({Double($0)!})}.map { (value) -> CLLocationCoordinate2D in
                        return CLLocationCoordinate2D(latitude: value[0], longitude: value[1])
                    })!
                    if  CLLocationCoordinate2D(latitude: selectedRSDropOffCoordinate?.latitude ?? 0.0, longitude: selectedRSDropOffCoordinate?.longitude ?? 0.0).contained(by: coordinates) {
                        selectedRSDropZone = item
                        noDropZone = true
                        break
                    }
                }
            }
        }
        
        destination = destinations.filter({$0.source == selectedRSPickStation?.code})
        if destination.count > 0 {
            for item in destination {
                let pickupzones = zones.filter({$0.code == item.destination!})
                for item in pickupzones {
                    let coordinates = (item.bound?.components(separatedBy: ";").map{$0.components(separatedBy: ",")}.map{$0.map({Double($0)!})}.map { (value) -> CLLocationCoordinate2D in
                        return CLLocationCoordinate2D(latitude: value[0], longitude: value[1])
                    })!
                    if  CLLocationCoordinate2D(latitude: selectedRSDropOffCoordinate?.latitude ?? 0.0, longitude: selectedRSDropOffCoordinate?.longitude ?? 0.0).contained(by: coordinates) {
                        selectedRSDropZone = item
                        noDropZone = true
                        break
                    }
                }
            }
        }
        
        destination = destinations.filter({$0.source == selectedRSPickZone?.code})
        
        if selectedRSPickStation == nil && selectedRSPickStop == nil && selectedRSPickZone != nil{
            if destination.count > 0 {
                for item in destination {
                    let pickupzones = zones.filter({$0.code == item.destination!})
                    for item in pickupzones {
                        let coordinates = (item.bound?.components(separatedBy: ";").map{$0.components(separatedBy: ",")}.map{$0.map({Double($0)!})}.map { (value) -> CLLocationCoordinate2D in
                            return CLLocationCoordinate2D(latitude: value[0], longitude: value[1])
                        })!
                        if  CLLocationCoordinate2D(latitude: selectedRSDropOffCoordinate?.latitude ?? 0.0, longitude: selectedRSDropOffCoordinate?.longitude ?? 0.0).contained(by: coordinates) {
                            selectedRSDropZone = item
                            noDropZone = true
                            break
                        }
                    }
                }
            }
        }
        
        if noDropZone == false {
            selectedRSDropZone = selectedRSPickZone
        }
        
        if selectedRSDropStation == nil {
            
            var stationsOfZone = [Area]()
            for item in destination {
                stationsOfZone.append(contentsOf: allStations.filter({$0.code! == item.destination!}))
            }
            
            for item in stationsOfZone {
                let coordinates = (item.bound?.components(separatedBy: ";").map{$0.components(separatedBy: ",")}.map{$0.map({Double($0)!})}.map { (value) -> CLLocationCoordinate2D in
                    return CLLocationCoordinate2D(latitude: value[0], longitude: value[1])
                })!
                if  CLLocationCoordinate2D(latitude: selectedRSDropOffCoordinate?.latitude ?? 0.0, longitude: selectedRSDropOffCoordinate?.longitude ?? 0.0).contained(by: coordinates) {
                    selectedRSDropStation = item
                    tapOnMarker = true
                    break
                }
            }
            
            if selectedRSDropStation != nil {
                setDropStop(&dropOffCalled)
            }
            
        } else if selectedRSDropStation != nil && selectedRSDropStop == nil {
            setDropStop(&dropOffCalled)
        } else {
            dropOffCalled = true
            setDropOff()
        }
        
        if selectedRSDropStation == nil && selectedRSDropZone != nil{
            if dropOffCalled == false {
                setDropOff()
            }
        }
    }
    
    func getDestinationForAddressScreen() {
        
        var customDestinationsCode = [Int]()
        destinationForPickUp.removeAll()
        if selectedRSPickStation != nil {
            
            customDestinationsCode = destinations.filter{$0.source == selectedRSPickStation?.code!}.map{$0.destination!}
            
            if customDestinationsCode.count == 0 {
                customDestinationsCode = destinations.filter{$0.source == selectedRSPickStop?.code!}.map{$0.destination!}
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
                if let destination = areas.filter({$0.code! == item}).first {
                    if destination.type == "MetroStop" || destination.type == "TramStop" {
                        if let station = areas.filter({$0.code! == destination.parent}).first {
                            destinationForPickUp.append(station)
                            destinationForPickUp.append(destination)
                        }
                    } else {
                        destinationForPickUp.append(contentsOf: areas.filter{$0.code! == item})
                    }
                }
            }
            
            print("destinationForPickUp", destinationForPickUp)
        }
    }
    
    
    func setDestinationsForSelectedLocation() {
        var customDestinationsCode = [Int]()
        destinationForPickUp.removeAll()
        if selectedRSPickStation != nil {
            customDestinationsCode = destinations.filter{$0.source == selectedRSPickStation?.code!}.map{$0.destination!}
            if customDestinationsCode.count == 0 {
                customDestinationsCode = destinations.filter{$0.source == selectedRSPickStop?.code!}.map{$0.destination!}
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
                if let destination = areas.filter({$0.code! == item}).first {
                    if destination.type == "MetroStop" || destination.type == "TramStop" {
                        if let station = areas.filter({$0.code! == destination.parent}).first {
                            destinationForPickUp.append(station)
                            destinationForPickUp.append(destination)
                            if customDestinationsCode.count == 1 {
                                selectedRSDropStation = station
                                selectedRSDropStop = destination
                            }
                        }
                    } else {
                        destinationForPickUp.append(contentsOf: areas.filter{$0.code! == item})
                    }
                }
            }
            
            print("destinationForPickUp", destinationForPickUp)
        }
    }
    
    func getDestinationForPickUp() {
        if pickUpSelected {
            if tapOnMarker == false {
                if backToPreviousPickUp == false {
                    setPickUpLocations()
                }
            }
            if backToPickUpWithMessageSelected == true {
                setPickUpLocations()
            }
            setDestinationsForSelectedLocation()
        }
    }
    
}
