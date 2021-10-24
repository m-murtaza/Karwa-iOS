//
//  KTCreateBookingViewController+Map.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 4/2/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import Foundation
import GoogleMaps

func getCenterPointOfPolygon(bounds: String) -> CLLocationCoordinate2D {
    
    var arrayCoordinate = [CLLocationCoordinate2D]()

    _ = bounds.components(separatedBy: ";").map{$0.components(separatedBy: ",")}.map{$0.map({Double($0)!})}.map { (value) -> CLLocationCoordinate2D in
        arrayCoordinate.append(CLLocationCoordinate2D(latitude: value[0], longitude: value[1]))
       return CLLocationCoordinate2D(latitude: value[0], longitude: value[1])
    }
    
    let sumOfLatitude: Double = arrayCoordinate.map{$0.latitude}.reduce(0, +)
    let sumOfLongitude: Double = arrayCoordinate.map{$0.longitude}.reduce(0, +)
    let centerLatitude = arrayCoordinate.count > 0 ? sumOfLatitude / Double(arrayCoordinate.count) : 0.0
    let centerLongitude = arrayCoordinate.count > 0 ? sumOfLongitude / Double(arrayCoordinate.count) : 0.0
    return CLLocationCoordinate2D.init(latitude: centerLatitude, longitude: centerLongitude)
}

extension KTXpressDropOffViewController: GMSMapViewDelegate, KTXpressDropoffViewModelDelegate {
    
  
  func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
    if gesture {
//      self.showCurrentLocationButton()
        xpressRebookDropOffSelected = false
    }
  }
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
                
        self.tapOnMarker = true

        let camera = GMSCameraPosition.camera(withLatitude: marker.position.latitude, longitude: marker.position.longitude, zoom: 17.0)
        
        self.mapView.animate(to: camera)
        
        (self.viewModel as! KTXpressDropoffViewModel).selectedCoordinate = CLLocationCoordinate2D(latitude: marker.position.latitude, longitude: marker.position.longitude)

        if let titleString = marker.title, titleString.count > 0 {
            (self.viewModel as! KTXpressDropoffViewModel).selectedStationName = marker.title ?? ""
            (self.viewModel as? KTXpressDropoffViewModel)!.didTapMarker(location: CLLocation(latitude: marker.position.latitude, longitude: marker.position.longitude))
        }
        
        defer {
            (self.viewModel as! KTXpressDropoffViewModel).showStopAlert()
        }
    
        self.setDropOffButton.setTitle("str_dropoff".localized(), for: .normal)
        self.setDropOffButton.setTitleColor(UIColor.white, for: .normal)
        self.markerButton.setImage(#imageLiteral(resourceName: "dropoff_pin"), for: .normal)
        
        self.setDropOffButton.backgroundColor = UIColor(hexString: "#4BA5A7")
        self.setDropOffButton.isUserInteractionEnabled = true
//        self.setDropOffButton.addShadowBottomXpress()
        
        return true
        
    }
  
    func checkPermittedDropOff(_ location: CLLocation) {
        for item in destinationsForPickUp {
            
            let coordinates = item.bound!.components(separatedBy: ";").map{$0.components(separatedBy: ",")}.map{$0.map({Double($0)!})}.map { (value) -> CLLocationCoordinate2D in
                return CLLocationCoordinate2D(latitude: value[0], longitude: value[1])
            }
            
            if CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude).contained(by: coordinates) {
                
                if pickUpStation != nil {
                    
                    let pickupCoordinates = pickUpStation!.bound!.components(separatedBy: ";").map{$0.components(separatedBy: ",")}.map{$0.map({Double($0)!})}.map { (value) -> CLLocationCoordinate2D in
                        return CLLocationCoordinate2D(latitude: value[0], longitude: value[1])
                    }
                    
                    if CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude).contained(by: pickupCoordinates) {
                        
                        print("not permitted")
                        self.setDropOffButton.setTitle("SETTODROPZONE".localized(), for: .normal)
                        self.setDropOffButton.backgroundColor = UIColor.clear
                        self.markerButton.setImage(#imageLiteral(resourceName: "pin_outofzone"), for: .normal)
                        self.setDropOffButton.setTitleColor(UIColor(hexString: "#8EA8A7"), for: .normal)
                        self.setDropOffButton.isUserInteractionEnabled = false
//                        self.setDropOffButton.layer.shadowColor = UIColor.clear.cgColor
                        
                    }
                    else {
                        
                        print("Permitted")
                        self.setDropOffButton.setTitle("str_dropoff".localized(), for: .normal)
                        self.setDropOffButton.setTitleColor(UIColor.white, for: .normal)
                        self.markerButton.setImage(#imageLiteral(resourceName: "pin_dropoff_map"), for: .normal)
                        self.setDropOffButton.isUserInteractionEnabled = true
                        self.setDropOffButton.backgroundColor = UIColor(hexString: "#4BA5A7")
                        self.setDropOffButton.isUserInteractionEnabled = true
//                        self.setDropOffButton.addShadowBottomXpress()

                        break
                        
                    }
                } else {
                    print("Permitted")
                    self.setDropOffButton.setTitle("str_dropoff".localized(), for: .normal)
                    self.setDropOffButton.setTitleColor(UIColor.white, for: .normal)
                    self.markerButton.setImage(#imageLiteral(resourceName: "dropoff_pin"), for: .normal) //dropoff_pin
                    self.setDropOffButton.isUserInteractionEnabled = true
                    self.setDropOffButton.backgroundColor = UIColor(hexString: "#4BA5A7")
                    self.setDropOffButton.isUserInteractionEnabled = true
//                    self.setDropOffButton.addShadowBottomXpress()
                    break
                }
                
            } else {
                
                if pickUpZone != nil {
                    
                    let pickupCoordinates = pickUpZone!.bound!.components(separatedBy: ";").map{$0.components(separatedBy: ",")}.map{$0.map({Double($0)!})}.map { (value) -> CLLocationCoordinate2D in
                        return CLLocationCoordinate2D(latitude: value[0], longitude: value[1])
                    }
                    
                    if CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude).contained(by: pickupCoordinates) {
                        
                        print("not permitted")
                        self.setDropOffButton.setTitle("SETTODROPZONE".localized(), for: .normal)
                        self.setDropOffButton.backgroundColor = UIColor.clear
                        self.markerButton.setImage(#imageLiteral(resourceName: "pin_outofzone"), for: .normal)
                        self.setDropOffButton.setTitleColor(UIColor(hexString: "#8EA8A7"), for: .normal)
                        self.setDropOffButton.isUserInteractionEnabled = false
//                        self.setDropOffButton.layer.shadowColor = UIColor.clear.cgColor
                        
                    } else {
                        
                        print("it wont contains")
                        self.setDropOffButton.setTitle("str_outzone".localized(), for: .normal)
                        self.setDropOffButton.backgroundColor = UIColor.clear
                        self.markerButton.setImage(#imageLiteral(resourceName: "pin_outofzone"), for: .normal)
                        self.setDropOffButton.setTitleColor(UIColor(hexString: "#8EA8A7"), for: .normal)
                        self.setDropOffButton.isUserInteractionEnabled = false
//                        self.setDropOffButton.layer.shadowColor = UIColor.clear.cgColor
                        
                    }

                    
                } else {
                    
                    print("it wont contains")
                    self.setDropOffButton.setTitle("str_outzone".localized(), for: .normal)
                    self.setDropOffButton.backgroundColor = UIColor.clear
                    self.markerButton.setImage(#imageLiteral(resourceName: "pin_outofzone"), for: .normal)
                    self.setDropOffButton.setTitleColor(UIColor(hexString: "#8EA8A7"), for: .normal)
                    self.setDropOffButton.isUserInteractionEnabled = false
//                    self.setDropOffButton.layer.shadowColor = UIColor.clear.cgColor
                    
                }
                
                
            }
            
        }
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        
        if self.tapOnMarker == false {
            let location = CLLocation(latitude: mapView.camera.target.latitude, longitude: mapView.camera.target.longitude)
            let name = "XpressLocationManagerNotificationIdentifier"
            NotificationCenter.default.post(name: Notification.Name(name), object: nil, userInfo: ["location": location as Any, "updateMap" : false])

            (self.viewModel as! KTXpressDropoffViewModel).selectedCoordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            checkPermittedDropOff(location)
            
        } else {
            self.tapOnMarker = false
            return
        }
                        
    }

}

extension KTXpressDropOffViewController
{
    func setupCurrentLocaiton() {
      if KTLocationManager.sharedInstance.locationIsOn() {
        if KTLocationManager.sharedInstance.isLocationAvailable {
          var notification : Notification = Notification(name: Notification.Name(rawValue: Constants.Notification.LocationManager))
          var userInfo : [String :Any] = [:]
          userInfo["location"] = KTLocationManager.sharedInstance.baseLocation
          
          notification.userInfo = userInfo
          //notification.userInfo!["location"] as! CLLocation
//          LocationManagerLocaitonUpdate(notification: notification)
        }
        else {
          KTLocationManager.sharedInstance.start()
        }
      }
    }

    internal func addMap() {

        showCurrentLocationDot(show: true)
                
        self.addMarkerOnMap(title:"" , location: pickUpCoordinate!, image: #imageLiteral(resourceName: "pin_pickup_map"))
        
        markerButton.isHidden = false
        
        mapView.setMinZoom(4.6, maxZoom: 20)
                
//        self.addMarkerOnMap(location: dropOffCoordinate!, image: #imageLiteral(resourceName: "pin_dropoff_map"))
        
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
        
        var rect = [GMSMutablePath]()
        if self.pickUpStop != nil || self.pickUpStation != nil {
            rect.append(self.polygon(bounds: (self.pickUpStation?.bound!)!, type: "Pick"))
            picupRect = rect.first!
            
        } else {
            rect.append(self.polygon(bounds: (self.pickUpZone?.bound!)!, type: "Pick"))
            picupRect = rect.first!
            
        }
    
        for item in destinationsForPickUp {
            
            if item.type! != "Zone" {
                                            
                if item.type == "TramStation"{
                    self.addMarkerOnMap(title: item.name ?? "", location: getCenterPointOfPolygon(bounds: item.bound!), image: #imageLiteral(resourceName: "tram_ico_map"))

                } else{
                    self.addMarkerOnMap(title: item.name ?? "", location: getCenterPointOfPolygon(bounds: item.bound!), image: #imageLiteral(resourceName: "metro_ico_map"))
                }
                                

            }
            
            dropOffCoordinate = getCenterPointOfPolygon(bounds: item.bound!)
            
            let camera = GMSCameraPosition.camera(withLatitude: dropOffCoordinate!.latitude, longitude: dropOffCoordinate!.longitude, zoom: item.type! == "Zone" ? 15.5 : 19)
                
            self.mapView.animate(to: camera)
            rect.append(self.polygon(bounds: item.bound!, type: ""))
            
        }
        
        //will check this condition after 
//        if xpressRebookSelected && xpressRebookPickUpSelected && xpressRebookDropOffSelected {
//            dropOffCoordinate = xpressRebookDropOffCoordinates
//            let camera = GMSCameraPosition.camera(withLatitude: dropOffCoordinate!.latitude, longitude: dropOffCoordinate!.longitude, zoom: 17)
//            self.mapView.camera = camera;
//        }
        
        
        self.locateCountry(pathG: rect)

      //self.focusMapToCurrentLocation()
        
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

        if pickUpStation == nil {
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
        
        if type == "Pick" {
            
        }
        
        // Create a rectangular path
        let rect = GMSMutablePath()
                
        _ = bounds.components(separatedBy: ";").map{$0.components(separatedBy: ",")}.map{$0.map({Double($0)!})}.map { (value) -> CLLocationCoordinate2D in
            rect.add(CLLocationCoordinate2D(latitude: value[0], longitude: value[1]))
            
//            dropOffCoordinate = CLLocationCoordinate2D(latitude: value[0], longitude: value[1])
//            let camera = GMSCameraPosition.camera(withLatitude: dropOffCoordinate!.latitude, longitude: dropOffCoordinate!.longitude, zoom: 17.0)
//            self.mapView.camera = camera;
            
           return CLLocationCoordinate2D(latitude: value[0], longitude: value[1])
        }
        
        return rect
    }
    
    
    internal func showCurrentLocationDot(show: Bool) {
        
        self.mapView!.isMyLocationEnabled = show
        //self.mapView!.settings.myLocationButton = show
    }
    
    func updateLocationInMap(location: CLLocation) {
        updateLocationInMap(location: location, shouldZoomToDefault: true)
    }
    
    func updateLocationInMap(location: CLLocation, shouldZoomToDefault withZoom : Bool) {
        if(withZoom)
        {
            let camera = GMSCameraPosition.camera(withLatitude: (location.coordinate.latitude), longitude: (location.coordinate.longitude), zoom: KTCreateBookingConstants.DEFAULT_MAP_ZOOM)
            self.mapView?.animate(to: camera)
        }
        else
        {
            let camera = GMSCameraPosition.camera(withLatitude: (location.coordinate.latitude), longitude: (location.coordinate.longitude), zoom: self.mapView?.camera.zoom ?? KTCreateBookingConstants.DEFAULT_MAP_ZOOM)
            self.mapView?.animate(to: camera)
        }
    }
    
    private func removeMarkerFromMap(markerToBeRemoved marker:GMSMarker)
    {
        gmsMarker.remove(at: gmsMarker.index(of: marker)!)
        marker.map = nil
    }
    
    func focusMapToCurrentLocation()
    {
        if(KTLocationManager.sharedInstance.isLocationAvailable && KTLocationManager.sharedInstance.currentLocation.coordinate.isZeroCoordinate == false)
        {
            let update :GMSCameraUpdate = GMSCameraUpdate.setTarget(KTLocationManager.sharedInstance.currentLocation.coordinate, zoom: KTCreateBookingConstants.DEFAULT_MAP_ZOOM)
            mapView.animate(with: update)
        }
    }
        
    func clearMap()
    {
        mapView.clear()
    }
        
    func addMarkerOnMap(title: String, location: CLLocationCoordinate2D, image: UIImage) {
        let marker = GMSMarker()
        marker.position = location
        marker.title = title
        marker.icon = image
        marker.groundAnchor = CGPoint(x:0.2,y:1)
        marker.map = self.mapView
        
        if location.latitude == pickUpCoordinate!.latitude {
            marker.isTappable = false
        } else {
            marker.isTappable = true
        }
    }
    
    func focusOnLocation(lat: Double, lon: Double)
    {
        let location = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let update :GMSCameraUpdate = GMSCameraUpdate.setTarget(location, zoom: KTCreateBookingConstants.DEFAULT_MAP_ZOOM)
        mapView.animate(with: update)
    }
    
    //MARK:- Locations
    func showAlertForLocationServerOn() {
      let alertController = UIAlertController(title: "",
                                              message: "str_enable_location_services".localized(),
                                              preferredStyle: .alert)
      let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
      let settingsAction = UIAlertAction(title: NSLocalizedString("Settings", comment: ""), style: .default) { (UIAlertAction) in
        
        UIApplication.shared.open(NSURL(string: UIApplicationOpenSettingsURLString)! as URL, options: [:], completionHandler: nil)
      }
      
      alertController.addAction(cancelAction)
      alertController.addAction(settingsAction)
      self.present(alertController, animated: true, completion: nil)
    }
    
}

extension GMSPolygon {

    func contains(coordinate: CLLocationCoordinate2D) -> Bool {

        if self.path != nil {
            if GMSGeometryContainsLocation(coordinate, self.path!, true) {
                return true
            }
            else {
                return false
            }
        }
        else {
            return false
        }
    }
}
