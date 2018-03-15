//
//  KTBookingDetailsViewController.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 3/15/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps

class KTBookingDetailsViewController: KTBaseViewController, GMSMapViewDelegate, KTBookingDetailsViewModelDelegate {
    
    //
    
    @IBOutlet weak var mapView : GMSMapView!
    
    override func viewDidLoad() {
        if viewModel == nil {
            viewModel = KTBookingDetailsViewModel(del: self)
        }
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    func setBooking(booking : KTBooking) {
        if viewModel == nil {
            viewModel = KTBookingDetailsViewModel(del: self)
        }
        (viewModel as! KTBookingDetailsViewModel).booking = booking
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
    //MARK:- Map
    func initializeMap(location : CLLocationCoordinate2D) {
        
        let camera = GMSCameraPosition.camera(withLatitude: location.latitude, longitude: location.longitude, zoom: 14.0)
        
        self.mapView.camera = camera;
        self.mapView.delegate = self
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
    
    func showCurrentLocationDot(show: Bool) {
        self.mapView!.isMyLocationEnabled = show
        //self.mapView!.settings.myLocationButton = show
    }
    
    func showVTrackMarker(vTrack: VehicleTrack) {
            let marker = GMSMarker()
            marker.position = vTrack.position
        
       
            marker.rotation = CLLocationDegrees(vTrack.bearing)
            marker.icon = (viewModel as! KTBookingDetailsViewModel).imgForTrackMarker()
            marker.map = self.mapView
    }
}
