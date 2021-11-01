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

struct MarkerData {
    var title: String?
    var type: String?
}

class KTXpressLocationPickerViewController:  KTBaseCreateBookingController {
   
    @IBOutlet weak var pickUpAddressLabel: SpringLabel!
    @IBOutlet weak var pickUpAddressHeaderLabel: SpringLabel!
    @IBOutlet weak var markerImage: SpringImageView!
    @IBOutlet weak var setLocationButton: SpringButton!
    @IBOutlet weak var backButton: SpringButton!
    @IBOutlet weak var closeButton: SpringButton!

    @IBOutlet weak var plusBtn: UIButton!
    @IBOutlet weak var minuBtn: UIButton!
    @IBOutlet weak var passengerLabel: UILabel!
    @IBOutlet weak var showAddressPickerBtn: UIButton!
    
    @IBOutlet weak var arrowImage: SpringImageView!
    @IBOutlet weak var markerIconImage: SpringImageView!

    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    var vModel : KTXpressLocationSetUpViewModel?
    
    var addressSelected = false
    var pickUpSelected = true
    var tapOnMarker = false
    var destinationForPickUp = [Area]()
    var picupRect = GMSMutablePath()

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
        

        self.passengerLabel.text = "str_1pass".localized()
        plusBtn.layer.opacity = 1
        minuBtn.layer.opacity = 0.5
        
        arrowImage.image = UIImage(named: "icon-arrow-right-large")?.imageFlippedForRightToLeftLayoutDirection()
        self.mapView.settings.rotateGestures = false
        self.mapView.settings.tiltGestures = false
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
        self.navigationController?.navigationBar.isHidden = true
    }
    
    @objc private func showMenu() {
      sideMenuController?.revealMenu()
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
            callSetPickUpAction()
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
        backToPickUp()
    }
    
    @IBAction func closeButtonTapped(sender: UIButton) {
        setDropOffViewUI()
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
        let update :GMSCameraUpdate = GMSCameraUpdate.setTarget(selectedRSPickUpCoordinate!, zoom: KTXpressCreateBookingConstants.DEFAULT_MAP_ZOOM)
        mapView.animate(with: update)
        setPickUpPolygon()
        setPickUpViewUI()
        addPickUpLocations()
    }
    
    func setDropOffViewUI() {
        pickUpSelected = false
        setLocationButton.setTitle("str_dropoff".localized(), for: .normal)
        self.setLocationButton.backgroundColor = UIColor(hexString: "#4BA5A7")
        pickUpAddressHeaderLabel.text = "DROPOFFHEADER".localized()
        markerIconImage.image = UIImage(named: "pin_dropoff_map")
        backButton.isHidden = false
        closeButton.isHidden = true
    }
    
    func callSetPickUpAction() {
        pickUpSelected = true
        getDestinationForPickUp()
        setDropOffViewUI()
        setDropOffPolygon()
    }
    
    func callDropOffAction() {
    //showBookThisRideScreen
        
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
        
        mapView.clear()
        
        showCurrentLocationDot(show: true)
                
        self.addMarkerOnMap(markerData: Area(), location: selectedRSPickUpCoordinate!, image: #imageLiteral(resourceName: "pin_pickup_map"))
                
        mapView.setMinZoom(4.6, maxZoom: 20)
        
        var rect = [GMSMutablePath]()
        if selectedRSPickStop != nil || selectedRSPickStation != nil {
            rect.append(self.polygon(bounds: (selectedRSPickStation?.bound!)!, type: "Pick"))
            picupRect = rect.first!
            
        } else {
            rect.append(self.polygon(bounds: (selectedRSPickZone?.bound!)!, type: "Pick"))
            picupRect = rect.first!
            
        }
    
        for item in destinationForPickUp {
            
            if item.type! != "Zone" {
                                            
                if item.type == "TramStation"{
                    self.addMarkerOnMap(markerData: item, location: getCenterPointOfPolygon(bounds: item.bound!), image: #imageLiteral(resourceName: "tram_ico_map"))

                } else{
                    self.addMarkerOnMap(markerData: item, location: getCenterPointOfPolygon(bounds: item.bound!), image: #imageLiteral(resourceName: "metro_ico_map"))
                }
                                

            }
            
            selectedRSDropOffCoordinate = getCenterPointOfPolygon(bounds: item.bound!)
            
            let camera = GMSCameraPosition.camera(withLatitude: selectedRSDropOffCoordinate!.latitude, longitude: selectedRSDropOffCoordinate!.longitude, zoom: item.type! == "Zone" ? 15.5 : 19)
            mapView.animate(to: camera)
            
            rect.append(self.polygon(bounds: item.bound!, type: ""))
            
        }
        
        self.locateCountry(pathG: rect)
        
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
                    polygon.fillColor = UIColor.gray.withAlphaComponent(0.7)
                } else {
                    fillingPolygonn.holes?.append(path)
                    polygon.fillColor = UIColor.white
                }
                polygon.strokeColor = .black
                polygon.strokeWidth = 2
                polygon.map = mapView
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
        
        let alert = UIAlertController(title: "\(selectedStation.name! + "str_stop".localized())", message: "str_select_stop".localized(), preferredStyle: .actionSheet)
        
        for item in stops {
            alert.addAction(UIAlertAction(title: item.name!, style: .default , handler:{ (UIAlertAction)in
                self.tapOnMarker = true
                print("User click Approve button")
                if self.pickUpSelected == true {
                    selectedRSPickStop = item
                } else {
                    selectedRSDropStop = item
                }
            }))
        }

        self.present(alert, animated: true, completion: {
            print("completion block")
        })
        
    }
    
    func showAlertForStation() {
        
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
            
            if addressSelected == false {
                let camera = GMSCameraPosition.camera(withLatitude: getCenterPointOfPolygon(bounds: item).latitude, longitude: getCenterPointOfPolygon(bounds: item).longitude, zoom: 15)
                self.mapView.animate(to: camera)
                KTLocationManager.sharedInstance.currentLocation = CLLocation(latitude:  getCenterPointOfPolygon(bounds: item).latitude, longitude: getCenterPointOfPolygon(bounds: item).longitude)
                if pickUpSelected == true {
                    selectedRSPickUpCoordinate = CLLocationCoordinate2D(latitude: KTLocationManager.sharedInstance.currentLocation.coordinate.latitude, longitude: KTLocationManager.sharedInstance.currentLocation.coordinate.longitude)
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
        
    }
    
    fileprivate func checkCoordinateStatus(_ location: CLLocation) {
        if areas.count > 0 {
            if checkLatLonInside(location: location) {
                self.updateValidPickUpUI()
            } else {
                self.updateOutOfZonePickUpUI()
            }
        }
    }
    
    func addPickUpLocations() {
        for item in pickUpArea {
            if item.type == "MetroStation" {
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
        marker.groundAnchor = CGPoint(x:0.3,y:0.5)
        marker.map = self.mapView
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
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        if tapOnMarker == false {
            resetValues()
            Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
                let location = CLLocation(latitude: mapView.camera.target.latitude, longitude: mapView.camera.target.longitude)
                self.checkCoordinateStatus(location)
                if self.pickUpSelected == true {
                    selectedRSPickUpCoordinate = location.coordinate
                } else {
                    selectedRSDropOffCoordinate = location.coordinate
                }
                (self.viewModel as! KTXpressLocationSetUpViewModel).fetchLocationName(forGeoCoordinate: location.coordinate)
            }
        } else {
            tapOnMarker = false
        }
    }
    
    fileprivate func setPickUpLocationData(_ marker: GMSMarker) {
        selectedRSPickStation = marker.userData as? Area
        let stopOfStations = areas.filter{$0.parent == selectedRSPickStation?.code}
        selectedRSPickStop = stopOfStations.first!
        selectedRSPickUpCoordinate = CLLocationCoordinate2D(latitude: marker.position.latitude, longitude: marker.position.longitude)
        selectedRSPickZone = areas.filter{$0.code == selectedRSPickStation?.parent}.first!
        if stopOfStations.count > 1 {
            self.showStopAlertViewController(stops: stopOfStations, selectedStation: selectedRSPickStation!)
        }
    }
    
    fileprivate func setDropOffLocationData(_ marker: GMSMarker) {
        selectedRSDropStation = marker.userData as? Area
        let stopOfStations = areas.filter{$0.parent == selectedRSDropStation?.code}
        selectedRSDropZone = areas.filter{$0.code == selectedRSDropStation?.parent}.first!
        selectedRSDropStop = stopOfStations.first!
        selectedRSDropOffCoordinate = CLLocationCoordinate2D(latitude: marker.position.latitude, longitude: marker.position.longitude)
        if stopOfStations.count > 1 {
            self.showStopAlertViewController(stops: stopOfStations, selectedStation: selectedRSDropStation!)
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
        
        self.setLocationButton.setTitle("str_setpick".localized(), for: .normal)
        self.setLocationButton.setTitleColor(UIColor.white, for: .normal)
        self.setLocationButton.backgroundColor = UIColor(hexString: "#4BA5A7")
        markerImage.image = pickUpSelected ? #imageLiteral(resourceName: "pickup_address_ico") : #imageLiteral(resourceName: "pin_dropoff_map")
        self.setLocationButton.isUserInteractionEnabled = true//pickup_address_ico
        
        return true
        
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
        
        if selectedRSPickStation != nil {
            if selectedRSPickStop == nil {
                selectedRSPickStop = pickUpArea.filter{$0.parent == selectedRSPickStation?.code}.first!
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
                selectedRSDropStop = pickUpArea.filter{$0.parent == selectedRSDropStation?.code}.first!
            }
            selectedRSDropOffCoordinate = getCenterPointOfPolygon(bounds: selectedRSDropStation?.bound! ?? "")
        }
    }
    
    func getDestinationForPickUp() {
        if pickUpSelected {
            setPickUpLocations()
            var customDestinationsCode = [Int]()
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
        }
    }
    
}
