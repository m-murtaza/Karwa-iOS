//
//  KTCreateBookingViewController+Map.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 4/2/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import Foundation
import GoogleMaps

extension KTCreateBookingViewController
{
    internal func addMap() {
        
        let camera = GMSCameraPosition.camera(withLatitude: 25.343899, longitude: 51.511294, zoom: 14.0)
        
        showCurrentLocationDot(show: true)
        self.mapView.camera = camera;
        
        let padding = UIEdgeInsets(top: 0, left: 0, bottom: 110, right: 0)
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
    }
    
    internal func showCurrentLocationDot(show: Bool) {
        
        self.mapView!.isMyLocationEnabled = show
        self.mapView!.settings.myLocationButton = show
    }
    
    func updateLocationInMap(location: CLLocation) {
        
        //Update map
        if !(viewModel as! KTCreateBookingViewModel).isVehicleNearBy() {
            let camera = GMSCameraPosition.camera(withLatitude: (location.coordinate.latitude), longitude: (location.coordinate.longitude), zoom: KTCreateBookingConstants.DEFAULT_MAP_ZOOM)
            
            self.mapView?.animate(to: camera)
        }
    }
    
    func imgForTrackMarker(_ vehicleType: Int16) -> UIImage {
        
        var img : UIImage?
        switch vehicleType  {
        case VehicleType.KTAirportSpare.rawValue, VehicleType.KTCityTaxi.rawValue,VehicleType.KTSpecialNeedTaxi.rawValue:
            img = UIImage(named:"BookingMapTaxiIco")
            
        case VehicleType.KTCityTaxi7Seater.rawValue:
            img = UIImage(named: "BookingMap7Ico")
            
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
        if gmsMarker.count > 0
        {
            self.focusMapToShowAllMarkers(gmsMarker: gmsMarker)
        }
        else
        {
            self.focusMapToCurrentLocation()
        }
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
        CATransaction.setAnimationDuration(3)
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
    
    func focusMapToCurrentLocation() {
        if(KTLocationManager.sharedInstance.isLocationAvailable && KTLocationManager.sharedInstance.currentLocation.coordinate.isZeroCoordinate == false) {
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
        update = GMSCameraUpdate.fit(bounds, withPadding: CGFloat(KTCreateBookingConstants.DEFAULT_MAP_PADDING))
        
        CATransaction.begin()
        CATransaction.setValue(1.0, forKey: kCATransactionAnimationDuration)
        mapView.animate(with: update!)
        CATransaction.commit()
    }
    
    func clearMap()
    {
        mapView.clear()
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
        path = GMSPath.init(fromEncodedPath: points)!
        polyline = GMSPolyline.init(path: path)
        polyline.strokeWidth = 3
        polyline.strokeColor = bgPolylineColor  // UIColor(displayP3Red: 0, green: 97/255, blue: 112/255, alpha: 255/255)
        polyline.map = self.mapView
        
        var bounds = GMSCoordinateBounds()
        for index in 1 ... (path.count().toInt) {
            bounds = bounds.includingCoordinate(path.coordinate(at: UInt(index)))
        }
        
        mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 100.0))
        
        bgPolylineColor = UIColor(red: 0, green: 154/255, blue: 169/255, alpha: 1.0)
        self.timer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(animatePolylinePath), userInfo: nil, repeats: true)
        
        addMarkerOnMap(location: path.coordinate(at:0), image: UIImage(named: "BookingMapDirectionPickup")!)
        addMarkerOnMap(location: path.coordinate(at:path.count()-1), image: UIImage(named: "BookingMapDirectionDropOff")!)
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
