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
import Cosmos

class KTBookingDetailsViewController: KTBaseViewController, GMSMapViewDelegate, KTBookingDetailsViewModelDelegate {

    //
    
    @IBOutlet weak var mapView : GMSMapView!
    
    @IBOutlet weak var lblPickAddress : UILabel!
    @IBOutlet weak var lblPickMessage : UILabel!
    @IBOutlet weak var viewCard : KTShadowView!
    @IBOutlet weak var lblDayOfMonth: UILabel!
    @IBOutlet weak var lblMonth: UILabel!
    @IBOutlet weak var lblYear: UILabel!
    @IBOutlet weak var lblDropoffAddress: UILabel!
    @IBOutlet weak var lblDayAndTime: UILabel!
    @IBOutlet weak var lblServiceType: UILabel!
    @IBOutlet weak var imgBookingStatus: UIImageView!
    @IBOutlet weak var lblEstimatedFare : UILabel!
    @IBOutlet weak var starView : CosmosView!
    
    @IBOutlet weak var lblDriverName : UILabel!
    @IBOutlet weak var lblVehicleNumber :UILabel!
    @IBOutlet weak var imgNumberPlate : UIImageView!
    
    private var vModel : KTBookingDetailsViewModel?
    override func viewDidLoad() {
        if viewModel == nil {
            viewModel = KTBookingDetailsViewModel(del: self)
        }
        
        vModel = viewModel as? KTBookingDetailsViewModel
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
    @IBAction func btnCallTapped(_ sender: Any) {
      vModel?.callDriver()
        
    }
    
    @IBAction func btnBackTapped(_ sender: Any) {
        
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
    }
    //MARK:- Assignment Info
    
    func updateAssignmentInfo() {
        
        lblDriverName.text = vModel?.driverName()
        lblVehicleNumber.text = vModel?.vehicleNumber()
        starView.rating = (vModel?.driverRating())!
        imgNumberPlate.image = vModel?.imgForPlate()
        
    }
    
    //MARK:- Booking Card
    func updateBookingCard() {
        
        lblPickAddress.text = vModel?.pickAddress()
        lblDropoffAddress.text = vModel?.dropAddress()
        lblPickMessage.text = vModel?.pickMessage()
        lblDayOfMonth.text = vModel?.pickupDateOfMonth()
        
        lblMonth.text = vModel?.pickupMonth()
        lblYear.text = vModel?.pickupYear()
        
        lblDayAndTime.text = vModel?.pickupDayAndTime()
        
        lblServiceType.text = vModel?.vehicleType()
        lblEstimatedFare.text = vModel?.estimatedFare()
        
        
        let img : UIImage? = vModel?.bookingStatusImage()
        if img != nil {
            imgBookingStatus.image = img
        }
        
        viewCard.backgroundColor = vModel?.cellBGColor()
        
        viewCard.borderColor = vModel?.cellBorderColor()
    }
    
    
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
