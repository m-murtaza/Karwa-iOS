//
//  KTCreateBookingViewController+Map.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 4/2/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import Foundation
import GoogleMaps
import UIKit

extension KTXpressPickUpViewController: GMSMapViewDelegate {
    

  func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
    if gesture {
//      self.showCurrentLocationButton()
        xpressRebookPickUpSelected = false
    }
  }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        self.tapOnMarker = true
        xpressRebookPickUpSelected = false

        let camera = GMSCameraPosition.camera(withLatitude: marker.position.latitude, longitude: marker.position.longitude, zoom: 17.0)        
        self.mapView.animate(to: camera)
        
        (self.viewModel as! KTXpressPickUpViewModel).selectedCoordinate = CLLocationCoordinate2D(latitude: marker.position.latitude, longitude: marker.position.longitude)
        
        (self.viewModel as! KTXpressPickUpViewModel).selectedStationName = marker.title ?? ""

        (self.viewModel as? KTXpressPickUpViewModel)!.didTapMarker(location: CLLocation(latitude: marker.position.latitude, longitude: marker.position.longitude))
                
        defer {
            (self.viewModel as! KTXpressPickUpViewModel).showStopAlert()
        }
        
        self.setPickUpButton.setTitle("str_setpick".localized(), for: .normal)
        self.setPickUpButton.setTitleColor(UIColor.white, for: .normal)
        self.setPickUpButton.backgroundColor = UIColor(hexString: "#4BA5A7")
        self.markerButton.setImage(#imageLiteral(resourceName: "pickup_address_ico"), for: .normal)
        self.setPickUpButton.isUserInteractionEnabled = true//pickup_address_ico
        
//        self.setPickUpButton.addShadowBottomXpress()
        
//        self.setPickUpButton.layer.shadowRadius = 0
//        self.setPickUpButton.layer.shadowOpacity = 1
//        self.setPickUpButton.layer.shadowOffset = CGSize(width: 0, height: 5)
//        self.setPickUpButton.layer.shadowColor = UIColor(hexString: "#4BA5A7").cgColor
//        self.setPickUpButton.layer.masksToBounds = false

        
        return true
    }

      
    fileprivate func checkCoordinateStatus(_ location: CLLocation) {
        
        let name = "XpressLocationManagerNotificationIdentifier"

        (self.viewModel as! KTXpressPickUpViewModel).selectedCoordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)

        if areas.count > 0 {
            (self.viewModel as? KTXpressPickUpViewModel)!.didTapMarker(location: CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude))
            KTLocationManager.sharedInstance.setCurrentLocation(location: location)
        } else {
            NotificationCenter.default.post(name: Notification.Name(name), object: nil, userInfo: ["location": location as Any, "updateMap" : false])
            KTLocationManager.sharedInstance.setCurrentLocation(location: location)
            (self.viewModel as! KTXpressPickUpViewModel).fetchLocationName(forGeoCoordinate: location.coordinate)
        }
                
        if areas.count > 0 {
            if checkLatLonInside(location: location) {
                self.setPickUpButton.setTitle("str_setpick".localized(), for: .normal)
                self.setPickUpButton.setTitleColor(UIColor.white, for: .normal)
                self.setPickUpButton.backgroundColor = UIColor(hexString: "#4BA5A7")
                self.markerButton.setImage(#imageLiteral(resourceName: "pickup_address_ico"), for: .normal)
//                self.setPickUpButton.addShadowBottomXpress()

//                self.setPickUpButton.layer.shadowRadius = 10
//                self.setPickUpButton.layer.shadowOpacity = 3
//                self.setPickUpButton.layer.shadowOffset = CGSize(width: 0, height: 3)
//                self.setPickUpButton.layer.shadowColor = UIColor(hexString: "#4BA5A7").cgColor
                self.setPickUpButton.isUserInteractionEnabled = true

            } else {
                self.setPickUpButton.setTitle("str_outzone".localized(), for: .normal)
                self.setPickUpButton.backgroundColor = UIColor.clear
                self.markerButton.setImage(#imageLiteral(resourceName: "pin_outofzone"), for: .normal)
                self.setPickUpButton.setTitleColor(UIColor(hexString: "#8EA8A7"), for: .normal)
                self.setPickUpButton.isUserInteractionEnabled = false
//                self.setPickUpButton.layer.shadowColor = UIColor.clear.cgColor
            }
        }
        
        if firstTime == false {
            let timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(checkStatus), userInfo: nil, repeats: false)
            timer.fire()
            firstTime = true
        }
        

    }
    
    
    @objc func checkStatus() {
        
        if areas.count <= 0 {
            self.setPickUpButton.setTitle("str_outzone".localized(), for: .normal)
            self.setPickUpButton.backgroundColor = UIColor.clear
            self.markerButton.setImage(#imageLiteral(resourceName: "pin_outofzone"), for: .normal)
            self.setPickUpButton.setTitleColor(UIColor(hexString: "#8EA8A7"), for: .normal)
            self.setPickUpButton.isUserInteractionEnabled = false
//            self.setPickUpButton.layer.shadowColor = UIColor.clear.cgColor
        } else {
            self.setPickUpButton.setTitle("str_setpick".localized(), for: .normal)
            self.setPickUpButton.setTitleColor(UIColor.white, for: .normal)
            self.setPickUpButton.backgroundColor = UIColor(hexString: "#4BA5A7")
            self.markerButton.setImage(#imageLiteral(resourceName: "pickup_address_ico"), for: .normal)
            self.setPickUpButton.isUserInteractionEnabled = true
//            self.setPickUpButton.addShadowBottomXpress()
//            self.setPickUpButton.layer.shadowRadius = 10
//            self.setPickUpButton.layer.shadowOpacity = 3
//            self.setPickUpButton.layer.shadowOffset = CGSize(width: 0, height: 3)
//            self.setPickUpButton.layer.shadowColor = UIColor(hexString: "#4BA5A7").cgColor
            self.setPickUpButton.isUserInteractionEnabled = true

        }
    }
    
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
    
    
    if self.tapOnMarker == false {
        
        if(mapView.camera.target.latitude == 0.0)
        {
            //TODO: Move Camera to default Location
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                let location = CLLocation(latitude: 25.281308, longitude: 51.531917)
                //addMarkerOnMap(location: mapView.camera.target, image: UIImage(named: "BookingMapDirectionPickup")!)
                let name = "LocationManagerNotificationIdentifier"
                NotificationCenter.default.post(name: Notification.Name(name), object: nil, userInfo: ["location": location as Any, "updateMap" : false])
                KTLocationManager.sharedInstance.setCurrentLocation(location: location)
            }
        }
        else
        {
            let location = CLLocation(latitude: mapView.camera.target.latitude, longitude: mapView.camera.target.longitude)
            checkCoordinateStatus(location)
        }
        
    } else {
        self.tapOnMarker = false
        return
    }

    

  }
}

extension KTXpressPickUpViewController
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
        
    func addPickUpLocations() {
        for item in (self.viewModel as! KTXpressPickUpViewModel).pickUpArea {
            if item.type == "MetroStop" {
                addMarkerOnMap(title: item.name ?? "", location: getCenterPointOfPolygon(bounds: item.bound!), image:  #imageLiteral(resourceName: "metro_ico_map"))
            } else {
                addMarkerOnMap(title: item.name ?? "", location: getCenterPointOfPolygon(bounds: item.bound!), image:  #imageLiteral(resourceName: "tram_ico_map"))
            }
        }
    }
        
    func setPolygon() {
        
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
                if checkLatLonInside(location: KTLocationManager.sharedInstance.baseLocation) && xpressRebookPickUpSelected == false {
                    let camera = GMSCameraPosition.camera(withLatitude:  KTLocationManager.sharedInstance.baseLocation.coordinate.latitude, longitude:  KTLocationManager.sharedInstance.baseLocation.coordinate.longitude, zoom: 15)
                    self.mapView.animate(to: camera)
                    let coord = CLLocation(latitude:  KTLocationManager.sharedInstance.baseLocation.coordinate.latitude, longitude:  KTLocationManager.sharedInstance.baseLocation.coordinate.longitude)
                    (self.viewModel as! KTXpressPickUpViewModel).fetchLocationName(forGeoCoordinate: coord.coordinate)
                    self.checkCoordinateStatus(coord)
                    
                } else {
                    let camera = GMSCameraPosition.camera(withLatitude: getCenterPointOfPolygon(bounds: item).latitude, longitude: getCenterPointOfPolygon(bounds: item).longitude, zoom: 15)
                    self.mapView.animate(to: camera)
                    KTLocationManager.sharedInstance.currentLocation = CLLocation(latitude:  getCenterPointOfPolygon(bounds: item).latitude, longitude: getCenterPointOfPolygon(bounds: item).longitude)
                    (self.viewModel as! KTXpressPickUpViewModel).fetchLocationName(forGeoCoordinate: KTLocationManager.sharedInstance.currentLocation.coordinate)
                    self.checkCoordinateStatus(KTLocationManager.sharedInstance.currentLocation)
                    (self.viewModel as! KTXpressPickUpViewModel).selectedCoordinate = CLLocationCoordinate2D(latitude: KTLocationManager.sharedInstance.currentLocation.coordinate.latitude, longitude: KTLocationManager.sharedInstance.currentLocation.coordinate.longitude)
                    (self.viewModel as? KTXpressPickUpViewModel)!.didTapMarker(location: CLLocation(latitude: KTLocationManager.sharedInstance.currentLocation.coordinate.latitude, longitude: KTLocationManager.sharedInstance.currentLocation.coordinate.longitude))
                    
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

    func polygonNext(){
        // Create a rectangular path
        let rect = GMSMutablePath()
        
        rect.add(CLLocationCoordinate2D(latitude: 25.32203, longitude: 51.52779))
        rect.add(CLLocationCoordinate2D(latitude: 25.32208, longitude: 51.52872))
        rect.add(CLLocationCoordinate2D(latitude: 25.32394, longitude: 51.52868))
        rect.add(CLLocationCoordinate2D(latitude: 25.32385, longitude: 51.5278))
        rect.add(CLLocationCoordinate2D(latitude: 25.32203, longitude: 51.52779))

        // Create the polygon, and assign it to the map.
        let polygon = GMSPolygon(path: rect)
        polygon.fillColor = UIColor(red: 0.25, green: 0, blue: 0, alpha: 0.2);
        polygon.strokeColor = .black
        polygon.strokeWidth = 2
        polygon.map = mapView
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
            let camera = GMSCameraPosition.camera(withLatitude: (location.coordinate.latitude), longitude: (location.coordinate.longitude), zoom: KTXpressCreateBookingConstants.DEFAULT_MAP_ZOOM)
            self.mapView?.animate(to: camera)
        
        }
        else
        {
            let camera = GMSCameraPosition.camera(withLatitude: (location.coordinate.latitude), longitude: (location.coordinate.longitude), zoom: self.mapView?.camera.zoom ?? KTXpressCreateBookingConstants.DEFAULT_MAP_ZOOM)
            self.mapView?.animate(to: camera)
        }
    }
    
    func imgForTrackMarker(_ vehicleType: Int16) -> UIImage {
        
        var img : UIImage?
        switch vehicleType  {
        case VehicleType.KTAirportSpare.rawValue, VehicleType.KTCityTaxi.rawValue:
            img = UIImage(named:"BookingMapTaxiIco")
        case VehicleType.KTCityTaxi7Seater.rawValue:
            img = UIImage(named: "BookingMap7Ico")
        case VehicleType.KTSpecialNeedTaxi.rawValue:
                img = UIImage(named: "BookingMapSpecialNeedIco")
        case VehicleType.KTStandardLimo.rawValue:
            img = UIImage(named: "BookingMapStandardIco")
        case VehicleType.KTBusinessLimo.rawValue:
            img = UIImage(named: "BookingMapBusinessIco")
        case VehicleType.KTLuxuryLimo.rawValue:
            img = UIImage(named: "BookingMapLuxuryIco")
        default:
            img = UIImage(named:"BookingMapTaxiIco")
        }
        return img!
    }
    
    @objc func addMarkerOnMap(vTrack: [VehicleTrack]) {
        //addMarkerOnMap(vTrack:vTrack, vehicleType: VehicleType.KTCityTaxi.rawValue)
    }
    
    @objc func addOrRemoveOrMoveMarkerOnMap(vTrack: [VehicleTrack], vehicleType: Int16) {
        
        removeUnRetainedMarkers(nearbyVehiclesNew: vTrack)
        addNewMarkers(nearbyVehiclesNew: vTrack)
        moveVehiclesIfRequired(nearbyVehiclesNew: vTrack)
    }
    
    private func moveVehiclesIfRequired(nearbyVehiclesNew newVehicles:[VehicleTrack])
    {
        let markersNeedsToMove = getMarkersNeedsToMove(nearbyVehiclesNew: newVehicles)

        for markerNeedsToMove in markersNeedsToMove
        {
            for newTrack in newVehicles
            {
                if(markerNeedsToMove.snippet == newTrack.vehicleNo)
                {
                    moveMarker(marker: markerNeedsToMove, from: markerNeedsToMove.position, to: newTrack.position, degree: newTrack.bearing)
                    break
                }
            }
        }
    }
    
    private func moveMarker(marker markerNeedsToMove: GMSMarker, from fromCoordinate : CLLocationCoordinate2D, to toCoordinate : CLLocationCoordinate2D, degree rotation : Float)
    {
        // Keep Rotation Short
        CATransaction.begin()
        CATransaction.setAnimationDuration(1.5)
        markerNeedsToMove.rotation = CLLocationDegrees(rotation)
        CATransaction.commit()
        
        // Movement
        CATransaction.begin()
        CATransaction.setAnimationDuration(4)
        markerNeedsToMove.position = toCoordinate
        
        // Center Map View
//        let camera = GMSCameraUpdate.setTarget(coordinates)
//        mapView.animateWithCameraUpdate(camera)
        
        CATransaction.commit()
    }
    
    private func getMarkersNeedsToMove(nearbyVehiclesNew newVehicles:[VehicleTrack]) -> [GMSMarker]
    {
        var updatedVehicleMarkers : [GMSMarker] = []
        
        for oldVehicleMarker in gmsMarker
        {
            for newVehicle in newVehicles
            {
                if(oldVehicleMarker.snippet == newVehicle.vehicleNo)
                {
                    updatedVehicleMarkers.append(oldVehicleMarker)
                    break
                }
            }
        }
        return updatedVehicleMarkers
    }
    
    private func removeUnRetainedMarkers(nearbyVehiclesNew newVehicles:[VehicleTrack])
    {
        if(newVehicles.count == 0)
        {
            for oldMarker in gmsMarker
            {
                oldMarker.map = nil
            }
        }
        else
        {
            for oldMarker in gmsMarker
            {
                var indexCount = 0
                
                for newVehicle in newVehicles
                {
                    if(oldMarker.snippet! == newVehicle.vehicleNo)
                    {
                        break
                    }
                    indexCount = indexCount + 1
                }
                
                if(indexCount == newVehicles.count)
                {
                    removeMarkerFromMap(markerToBeRemoved: oldMarker)
                }
            }
        }
    }
    
    private func removeMarkerFromMap(markerToBeRemoved marker:GMSMarker)
    {
        gmsMarker.remove(at: gmsMarker.index(of: marker)!)
        marker.map = nil
    }
    
    private func addNewMarkers(nearbyVehiclesNew newVehicles:[VehicleTrack])
    {
        if(gmsMarker.count == 0)
        {
            for newVehicle in newVehicles
            {
                addOneMarkerOnMap(vTrack: newVehicle)
            }
        }
        else
        {
            for newVehicle in newVehicles
            {
                var indexCount = 0
                for i in 0 ... gmsMarker.count - 1
                {
                    indexCount = indexCount + 1
                    if(newVehicle.vehicleNo == gmsMarker[i].snippet)
                    {
                        break;
                    }
                }
                if(indexCount == gmsMarker.count)
                {
                    addOneMarkerOnMap(vTrack: newVehicle)
                }
            }
        }
    }
    
    private func addOneMarkerOnMap(vTrack: VehicleTrack)
    {
        let marker = GMSMarker()
        marker.position = vTrack.position
        marker.snippet = vTrack.vehicleNo
        marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        marker.appearAnimation = GMSMarkerAnimation.pop

        if vTrack.trackType == VehicleTrackType.vehicle
        {
            marker.rotation = CLLocationDegrees(vTrack.bearing)
            marker.icon = imgForTrackMarker(Int16(vTrack.vehicleType))
            marker.map = self.mapView
        }

        gmsMarker.append(marker)
    }
    
    @objc func addMarkerOnMap(vTrack: [VehicleTrack], vehicleType: Int16) {
        gmsMarker.removeAll()
        clearMap()
        vTrack.forEach { track in
            if !track.position.isZeroCoordinate   {
                let marker = GMSMarker()
                marker.position = track.position
                
                if track.trackType == VehicleTrackType.vehicle {
                    marker.rotation = CLLocationDegrees(track.bearing)
                    marker.icon = imgForTrackMarker(vehicleType)
                    marker.map = self.mapView
                }
                
                gmsMarker.append(marker)
            }
        }
        if gmsMarker.count > 0
        {
            self.focusMapToShowAllMarkers(gmsMarker: gmsMarker)
        }
        else
        {
            self.focusMapToCurrentLocation()
        }
    }
    
    func focusMapToCurrentLocation()
    {
        if(KTLocationManager.sharedInstance.isLocationAvailable && KTLocationManager.sharedInstance.currentLocation.coordinate.isZeroCoordinate == false)
        {
            let update :GMSCameraUpdate = GMSCameraUpdate.setTarget(KTLocationManager.sharedInstance.currentLocation.coordinate, zoom: KTXpressCreateBookingConstants.DEFAULT_MAP_ZOOM)
            mapView.animate(with: update)
        }
    }
    
    func focusMapToShowAllMarkers(gmsMarker : Array<GMSMarker>) {
        
        var bounds = GMSCoordinateBounds()
        for marker: GMSMarker in gmsMarker {
            bounds = bounds.includingCoordinate(marker.position)
        }
        
        var update : GMSCameraUpdate?
        update = GMSCameraUpdate.fit(bounds,
                                     with: UIEdgeInsets(top: 100, left: 50, bottom: 150, right: 50))
        
        CATransaction.begin()
        CATransaction.setValue(1.0, forKey: kCATransactionAnimationDuration)
        mapView.animate(with: update!)
        CATransaction.commit()
        
//
        // focus to fit all the point including path, pick and destination in map camera
        
        if path.count() != 0 {
            let inset = UIEdgeInsets(top: 100, left: 50, bottom: 100, right: 50)
            focusMapToFitRoute(pointA: path.coordinate(at: 0),
                               pointB: path.coordinate(at: path.count()-1),
                               path: path,
                               inset: inset)
        }
        
        
    }
    
    func clearMap()
    {
        mapView.clear()
    }
    
    func addAndGetMarkerOnMap(location: CLLocationCoordinate2D, image: UIImage) -> GMSMarker{
        let marker = GMSMarker()
        marker.position = location
        
        marker.icon = image
//        marker.groundAnchor = CGPoint(x:0.5,y:0.5)
        marker.map = self.mapView
        
        return marker
    }
    
    func addMarkerOnMap(title: String, location: CLLocationCoordinate2D, image: UIImage) {
        let marker = GMSMarker()
        marker.position = location
        marker.title = title
        marker.icon = image
        marker.groundAnchor = CGPoint(x:0.6,y:1)
        marker.map = self.mapView
    }
    
    func focusOnLocation(lat: Double, lon: Double)
    {
        let location = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let update :GMSCameraUpdate = GMSCameraUpdate.setTarget(location, zoom: KTXpressCreateBookingConstants.DEFAULT_MAP_ZOOM)
        mapView.animate(with: update)
    }
        
  public func addPointsOnMap(points: String) {
    if(!points.isEmpty) {
      // set the line color to
      bgPolylineColor = #colorLiteral(red: 0, green: 0.6039215686, blue: 0.662745098, alpha: 1)
      // clear map to remove already drawn pickup and destination pins
      self.mapView.clear()
      // create path for router
      path = GMSMutablePath(fromEncodedPath: points)!
      polyline = GMSPolyline.init(path: path)
      polyline.strokeWidth = 3
      polyline.strokeColor = bgPolylineColor
      polyline.map = self.mapView
      
      // draw pickup and destimation pins from path
      let pickup = path.coordinate(at:0)
      let dropoff = path.coordinate(at:path.count()-1)
//      addMarkerOnMap(location: pickup, image: UIImage(named: "BookingMapDirectionPickup")!)
//      addMarkerOnMap(location: dropoff, image: UIImage(named: "BookingMapDirectionDropOff")!)
      
      let inset = UIEdgeInsets(top: 100, left: 100, bottom: 200, right: 100)
      
      // focus to fit all the point including path, pick and destination in map camera
      focusMapToFitRoute(pointA: path.coordinate(at: 0),
                         pointB: path.coordinate(at: path.count()-1),
                         path: path,
                         inset: inset)
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
    
    @objc func animatePolylinePath() {
        
        if (self.i < self.path.count()) {
            
            self.animationPath.add(self.path.coordinate(at: self.i))
            self.animationPolyline?.path = self.animationPath
            self.animationPolyline?.strokeColor = UIColor(displayP3Red: 0, green: 97/255, blue: 112/255, alpha: 255/255)
            self.animationPolyline?.strokeWidth = 4
            self.animationPolyline?.map = nil
            self.animationPolyline?.map = self.mapView
            self.i += 1
        }
        else if self.i == self.path.count() {
            timer.invalidate()
            self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(animatePolylinePath), userInfo: nil, repeats: true)
            self.i += 1
            
            //self.i = 0
            self.animationPath = GMSMutablePath()
            self.animationPolyline?.map = nil
            polyline.strokeColor = bgPolylineColor
        }
        else {
            
            self.i = 0
            
            timer.invalidate()
//            self.timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(animatePolylinePath), userInfo: nil, repeats: true)
        }
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
    
    internal func addDropOffMap() {

        mapView.clear()
        
        showCurrentLocationDot(show: true)
                
        self.addMarkerOnMap(title:"" , location: (viewModel as! KTXpressPickUpViewModel).selectedCoordinate!, image: #imageLiteral(resourceName: "pin_pickup_map"))
        
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
        if (viewModel as! KTXpressPickUpViewModel).selectedStop != nil || (viewModel as! KTXpressPickUpViewModel).selectedStation != nil {
            rect.append(self.polygon(bounds: ((viewModel as! KTXpressPickUpViewModel).selectedStation?.bound!)!, type: "Pick"))
            picupRect = rect.first!
            
        } else {
            rect.append(self.polygon(bounds: ((viewModel as! KTXpressPickUpViewModel).selectedZone?.bound!)!, type: "Pick"))
            picupRect = rect.first!
            
        }
    
        for item in (viewModel as! KTXpressPickUpViewModel).destinationForPickUp {
            
            if item.type! != "Zone" {
                                            
                if item.type == "TramStation"{
                    self.addMarkerOnMap(title: item.name ?? "", location: getCenterPointOfPolygon(bounds: item.bound!), image: #imageLiteral(resourceName: "tram_ico_map"))

                } else{
                    self.addMarkerOnMap(title: item.name ?? "", location: getCenterPointOfPolygon(bounds: item.bound!), image: #imageLiteral(resourceName: "metro_ico_map"))
                }
                                

            }
            
            dropOffCoordinate = getCenterPointOfPolygon(bounds: item.bound!)
            
            let camera = GMSCameraPosition.camera(withLatitude: dropOffCoordinate.latitude, longitude: dropOffCoordinate.longitude, zoom: item.type! == "Zone" ? 15.5 : 19)
                
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

        if (viewModel as! KTXpressPickUpViewModel).selectedStation == nil {
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

    
}

extension CLLocationCoordinate2D {

    func contained(by vertices: [CLLocationCoordinate2D]) -> Bool {
        let path = CGMutablePath()

        for vertex in vertices {
            if path.isEmpty {
                path.move(to: CGPoint(x: vertex.longitude, y: vertex.latitude))
            } else {
                path.addLine(to: CGPoint(x: vertex.longitude, y: vertex.latitude))
            }
        }

        let point = CGPoint(x: self.longitude, y: self.latitude)
        return path.contains(point)
    }
}
