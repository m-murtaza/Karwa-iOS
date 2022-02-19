//
//  KTKarwaBusViewController+Map.swift
//  KarwaRide
//
//  Created by Apple on 09/01/22.
//  Copyright © 2022 Karwa. All rights reserved.
//

import UIKit
import GoogleMaps

extension KTKarwaBusPlanDirectionViewController: GMSMapViewDelegate{

    internal func addMap() {
        
        let camera = GMSCameraPosition.camera(withLatitude: 25.281308, longitude: 51.531917, zoom: 14.0)
        self.mapView.camera = camera;
        let padding = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
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
        
        var i = 0
        for item in itenary?.legs ?? [Leg]() {
            let showDestination = i == (itenary?.legs?.count ?? 0) - 1 ? true : false
            if let routeColor = item.routeColor{
                self.addPointsOnMap(points: item.legGeometry?.points ?? "", mode: item.mode ?? "WALK", color: UIColor(hexString: "#"+routeColor), showDestination: showDestination)
            } else {
                self.addPointsOnMap(points: item.legGeometry?.points ?? "", mode: item.mode ?? "WALK", color: UIColor.primary, showDestination: showDestination)
            }
            i += 1
        }
        
    }
    
    func focusMapToCurrentLocation() {
        if(KTLocationManager.sharedInstance.isLocationAvailable && KTLocationManager.sharedInstance.currentLocation.coordinate.isZeroCoordinate == false) {
            let update :GMSCameraUpdate = GMSCameraUpdate.setTarget(KTLocationManager.sharedInstance.currentLocation.coordinate, zoom: KTCreateBookingConstants.DEFAULT_MAP_ZOOM)
            mapView.animate(with: update)
        }
    }
    
    public func addPointsOnMap(points: String, mode: String, color: UIColor, showDestination: Bool) {
      if(!points.isEmpty) {
        // create path for router
          if let path = GMSMutablePath(fromEncodedPath: points) {
              let polyline = GMSPolyline.init(path: path)
              polyline.strokeWidth = 3
              polyline.strokeColor = color
              
              
              // draw pickup and destimation pins from path
              let pickup = path.coordinate(at:0)
              let dropoff = path.coordinate(at:path.count()-1)
              
              if mode == "Walk"{
                  let styles = [GMSStrokeStyle.solidColor(color), GMSStrokeStyle.solidColor(UIColor.clear), GMSStrokeStyle.solidColor(UIColor.clear), GMSStrokeStyle.solidColor(color)]
                  let lengths = [0.5, 0.5] // Play with this for dotted line
                  polyline.spans = GMSStyleSpans(polyline.path!, styles, lengths as [NSNumber], .rhumb)
                  addMarkerOnMap(location: pickup, image: UIImage(named: "BookingMapDirectionPickup")!)
              } else {
                  addMarkerOnMap(location: pickup, image: UIImage(named: "stop")!)
              }
              
              polyline.map = self.mapView
              
              if showDestination {
                  addMarkerOnMap(location: dropoff, image: UIImage(named: "stop")!)
              } else {
                  addMarkerOnMap(location: dropoff, image: UIImage(named: "dropoff_pin")!)
              }
              
              let inset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
              
      //        // focus to fit all the point including path, pick and destination in map camera
              focusMapToFitRoute(pointA: path.coordinate(at: 0),
                                 pointB: path.coordinate(at: path.count()-1),
                                 path: path,
                                 inset: inset)
                
          }
          
      }
    }
    
    func addMarkerOnMap(location: CLLocationCoordinate2D, image: UIImage) {
        let marker = GMSMarker()
        marker.position = location
        marker.icon = image
        marker.groundAnchor = CGPoint(x:0.5,y:1)
        marker.map = self.mapView
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

    
}
