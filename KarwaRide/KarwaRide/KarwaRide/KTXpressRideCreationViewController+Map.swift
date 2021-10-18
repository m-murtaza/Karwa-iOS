//
//  KTCreateBookingViewController+Map.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 4/2/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import Foundation
import GoogleMaps

extension KTXpressRideCreationViewController: GMSMapViewDelegate {
    
}

extension KTXpressRideCreationViewController
{
    internal func addMap() {
        
        let camera = GMSCameraPosition.camera(withLatitude: (self.vModel?.rideServicePickDropOffData?.pickUpCoordinate?.latitude)!, longitude: (self.vModel?.rideServicePickDropOffData?.pickUpCoordinate?.longitude)!, zoom: KTXpressCreateBookingConstants.DEFAULT_MAP_ZOOM)
        
        showCurrentLocationDot(show: true)
        self.mapView.camera = camera;
        
        pickUpLocationMarker = addAndGetMarkerOnMap(location: (self.vModel?.rideServicePickDropOffData?.pickUpCoordinate!)!, image: #imageLiteral(resourceName: "pickup_address_ico"))
        
        dropOffLocationMarker = self.addAndGetMarkerOnMap(location: (self.vModel?.rideServicePickDropOffData?.dropOffCoordinate!)!, image: #imageLiteral(resourceName: "dropoff_pin"))

        let padding = UIEdgeInsets(top: 100, left: 20, bottom: 100, right: 100)
        mapView.padding = padding
        self.mapView.settings.rotateGestures = false
        self.mapView.settings.tiltGestures = false
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
                
        self.drawArcPolyline(startLocation: self.vModel?.rideServicePickDropOffData?.pickUpCoordinate!, endLocation: self.vModel?.rideServicePickDropOffData?.dropOffCoordinate)
    
        
        self.focusMapToShowAllMarkers(gmsMarker: gmsMarker)

        
    }
    
    func focusMapToShowAllMarkers(gmsMarker : Array<GMSMarker>) {

        var bounds = GMSCoordinateBounds()
        for marker: GMSMarker in gmsMarker {
            bounds = bounds.includingCoordinate(marker.position)
        }
        
        var update : GMSCameraUpdate?
        update = GMSCameraUpdate.fit(bounds, withPadding: 150)

        
        CATransaction.begin()
        CATransaction.setValue(1.0, forKey: kCATransactionAnimationDuration)
        mapView.animate(with: update!)
        CATransaction.commit()
    }
    
    func  addMarkerForServerPickUpLocation(coordinate: CLLocationCoordinate2D)  {
        
        
        mapView.clear()
        
        self.drawArcPolyline(startLocation: coordinate, endLocation: self.vModel?.rideServicePickDropOffData?.dropOffCoordinate)
        
        serverPickUpLocationMarker = GMSMarker()
        serverPickUpLocationMarker.position = coordinate
        serverPickUpLocationMarker.icon = #imageLiteral(resourceName: "pickup_address_ico")
        serverPickUpLocationMarker.groundAnchor = CGPoint(x:0.6,y:1)
        serverPickUpLocationMarker.map = self.mapView
        
        pickUpLocationMarker = GMSMarker()
        pickUpLocationMarker.position = (self.vModel?.rideServicePickDropOffData?.pickUpCoordinate!)!
        pickUpLocationMarker.iconView = walkToPickUpView
        pickUpLocationMarker.groundAnchor = CGPoint(x:0.6,y:1)
        
        if coordinate.latitude == (self.vModel?.rideServicePickDropOffData?.pickUpCoordinate!)!.latitude {
            pickUpLocationMarker.map = nil
        } else {
            pickUpLocationMarker.map = self.mapView
            self.drawArc(startLocation: (self.vModel?.rideServicePickDropOffData?.pickUpCoordinate!)!, endLocation: coordinate)
        }
                
        dropOffLocationMarker = GMSMarker()
        dropOffLocationMarker.position = (self.vModel?.rideServicePickDropOffData?.dropOffCoordinate!)!
        dropOffLocationMarker.icon = #imageLiteral(resourceName: "dropoff_pin")
        dropOffLocationMarker.groundAnchor = CGPoint(x:0.6,y:1)
        dropOffLocationMarker.map = self.mapView
                
        
        var bounds = GMSCoordinateBounds()
        
        bounds = bounds.includingCoordinate(serverPickUpLocationMarker.position)
        bounds = bounds.includingCoordinate(pickUpLocationMarker.position)
        bounds = bounds.includingCoordinate(dropOffLocationMarker.position)
        
        let update = GMSCameraUpdate.fit(bounds, withPadding: 50.0)
        mapView.moveCamera(update)

        
    }
    
    func drawArc(startLocation: CLLocationCoordinate2D?, endLocation: CLLocationCoordinate2D?) {
        if let startLocation = startLocation, let endLocation = endLocation {
            //swap the startLocation & endLocation if you want to reverse the direction of polyline arc formed.
            let path = GMSMutablePath()
            path.add(startLocation)
            path.add(endLocation)
            //Draw polyline
            let polyline = GMSPolyline(path: path)
            polyline.map = mapView // Assign GMSMapView as map
            polyline.strokeWidth = 3.0
            bgPolylineColor = #colorLiteral(red: 0.003020502627, green: 0.3786181808, blue: 0.4473349452, alpha: 1)
            let styles = [GMSStrokeStyle.solidColor(bgPolylineColor), GMSStrokeStyle.solidColor(UIColor.clear)]
            let lengths = [0.5, 0.5] // Play with this for dotted line
            polyline.spans = GMSStyleSpans(polyline.path!, styles, lengths as [NSNumber], .rhumb)
            
            let bounds = GMSCoordinateBounds(coordinate: startLocation, coordinate: endLocation)
            let insets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
            let camera = mapView.camera(for: bounds, insets: insets)!
            mapView.animate(to: camera)
        }
    }
    
    func bezierPath(from startLocation: CLLocationCoordinate2D, to endLocation: CLLocationCoordinate2D) -> GMSMutablePath {

            let distance = GMSGeometryDistance(startLocation, endLocation)
            let midPoint = GMSGeometryInterpolate(startLocation, endLocation, 0.5)

            let midToStartLocHeading = GMSGeometryHeading(midPoint, startLocation)

            let controlPointAngle = 360.0 - (90.0 - midToStartLocHeading)
            let controlPoint = GMSGeometryOffset(midPoint, distance / 2.0 , controlPointAngle)
            
            let path = GMSMutablePath()
            
            let stepper = 0.05
            let range = stride(from: 0.0, through: 1.0, by: stepper)// t = [0,1]
            
            func calculatePoint(when t: Double) -> CLLocationCoordinate2D {
                let t1 = (1.0 - t)
                let latitude = t1 * t1 * startLocation.latitude + 2 * t1 * t * controlPoint.latitude + t * t * endLocation.latitude
                let longitude = t1 * t1 * startLocation.longitude + 2 * t1 * t * controlPoint.longitude + t * t * endLocation.longitude
                let point = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                return point
            }
            
            range.map { calculatePoint(when: $0) }.forEach { path.add($0) }
            return path
     }
        
    func drawArcPolyline(startLocation: CLLocationCoordinate2D?, endLocation: CLLocationCoordinate2D?) {
        if let startLocation = startLocation, let endLocation = endLocation {
            //Draw polyline
            let polyline = GMSPolyline(path: self.bezierPath(from: startLocation, to: endLocation))
            polyline.map = mapView // Assign GMSMapView as map
            polyline.strokeWidth = 3.0
            bgPolylineColor = #colorLiteral(red: 0.003020502627, green: 0.3786181808, blue: 0.4473349452, alpha: 1)
            polyline.strokeColor = bgPolylineColor
            
            let inset = UIEdgeInsets(top: 150, left: 100, bottom: self.view.frame.height/2, right: 100)
            
            // focus to fit all the point including path, pick and destination in map camera
            self.focusMapToFitRoute(pointA: startLocation,
                               pointB: endLocation,
                               path: self.bezierPath(from: startLocation, to: endLocation),
                               inset: inset)
            
//            let styles = [GMSStrokeStyle.solidColor(UIColor.black), GMSStrokeStyle.solidColor(UIColor.clear)]
//            let lengths = [20, 20] // Play with this for dotted line
//            polyline.spans = GMSStyleSpans(polyline.path!, styles, lengths as [NSNumber], .rhumb)
            
//            let bounds = GMSCoordinateBounds(coordinate: startLocation, coordinate: endLocation)
//            let insets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
//            let camera = mapView.camera(for: bounds, insets: insets)!
//            mapView.animate(to: camera)
        }
    }
    
    internal func showCurrentLocationDot(show: Bool) {
        self.mapView!.isMyLocationEnabled = show
        //self.mapView!.settings.myLocationButton = show
    }
            
    func clearMap()
    {
        mapView.clear()
    }
    
    func addAndGetMarkerOnMap(location: CLLocationCoordinate2D, image: UIImage) -> GMSMarker{
        let marker = GMSMarker()
        marker.position = location
        marker.icon = image
        marker.groundAnchor = CGPoint(x:0.6,y:1)
        marker.map = self.mapView
        return marker
    }
    
    func addMarkerOnMap(location: CLLocationCoordinate2D, image: UIImage) {
        let marker = GMSMarker()
        marker.position = location
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
      addMarkerOnMap(location: pickup, image: UIImage(named: "BookingMapDirectionPickup")!)
      addMarkerOnMap(location: dropoff, image: UIImage(named: "BookingMapDirectionDropOff")!)
      
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
    
}
