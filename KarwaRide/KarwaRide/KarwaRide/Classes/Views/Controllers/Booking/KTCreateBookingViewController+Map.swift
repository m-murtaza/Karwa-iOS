//
//  KTCreateBookingViewController+Map.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 4/2/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import Foundation
import GoogleMaps

extension KTCreateBookingViewController: GMSMapViewDelegate {
  
  func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
    if gesture {
      self.showCurrentLocationButton()
    }
  }
  
  func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
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
        //addMarkerOnMap(location: mapView.camera.target, image: UIImage(named: "BookingMapDirectionPickup")!)
        let name = "LocationManagerNotificationIdentifier"
        NotificationCenter.default.post(name: Notification.Name(name), object: nil, userInfo: ["location": location as Any, "updateMap" : false])
        
        KTLocationManager.sharedInstance.setCurrentLocation(location: location)
    }
  }
}

extension KTCreateBookingViewController
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

        let camera = GMSCameraPosition.camera(withLatitude: 25.281308, longitude: 51.531917, zoom: 14.0)
        
        showCurrentLocationDot(show: true)
        self.mapView.camera = camera;
        
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
    
      self.focusMapToCurrentLocation()
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
        addMarkerOnMap(vTrack:vTrack, vehicleType: VehicleType.KTCityTaxi.rawValue)
    }
    
    
    
    @objc func addOrRemoveOrMoveMarkerOnMap(vTrack: [VehicleTrack], vehicleType: Int16) {
        
        removeUnRetainedMarkers(nearbyVehiclesNew: vTrack)
        addNewMarkers(nearbyVehiclesNew: vTrack)
        moveVehiclesIfRequired(nearbyVehiclesNew: vTrack)

//        gmsMarker.removeAll()
//        clearMap()
//        vTrack.forEach
//        { track in
//            if !track.position.isZeroCoordinate
//            {
//                let marker = GMSMarker()
//                marker.snippet = track.vehicleNo
//                marker.position = track.position
//
//                if track.trackType == VehicleTrackType.vehicle
//                {
//                    marker.rotation = CLLocationDegrees(track.bearing)
//                    marker.icon = imgForTrackMarker(vehicleType)
//                    marker.map = self.mapView
//                }
//
//                gmsMarker.append(marker)
//            }
//        }
//        if gmsMarker.count > 0
//        {
//            self.focusMapToShowAllMarkers(gmsMarker: gmsMarker)
//        }
//        else
//        {
//            self.focusMapToCurrentLocation()
//        }
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
            let update :GMSCameraUpdate = GMSCameraUpdate.setTarget(KTLocationManager.sharedInstance.currentLocation.coordinate, zoom: KTCreateBookingConstants.DEFAULT_MAP_ZOOM)
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
                                     with: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100))
        
        CATransaction.begin()
        CATransaction.setValue(1.0, forKey: kCATransactionAnimationDuration)
        mapView.animate(with: update!)
        CATransaction.commit()
    }
    
    func clearMap()
    {
        mapView.clear()
    }
    
    func addAndGetMarkerOnMap(location: CLLocationCoordinate2D, image: UIImage) -> GMSMarker{
        let marker = GMSMarker()
        marker.position = location
        
        marker.icon = image
        marker.groundAnchor = CGPoint(x:0.5,y:0.5)
        marker.map = self.mapView
        
        return marker
    }
    
    func addMarkerOnMap(location: CLLocationCoordinate2D, image: UIImage) {
        let marker = GMSMarker()
        marker.position = location
        
        marker.icon = image
        marker.groundAnchor = CGPoint(x:0.5,y:0.5)
        marker.map = self.mapView
    }
    
    func focusOnLocation(lat: Double, lon: Double)
    {
        let location = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let update :GMSCameraUpdate = GMSCameraUpdate.setTarget(location, zoom: KTCreateBookingConstants.DEFAULT_MAP_ZOOM)
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
      addMarkerOnMap(location: pickup, image: UIImage(named: "BookingMapDirectionPickup")!)
      addMarkerOnMap(location: dropoff, image: UIImage(named: "BookingMapDirectionDropOff")!)
      
      let inset = UIEdgeInsets(top: 100, left: 100, bottom: -100, right: 100)
      
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
}
