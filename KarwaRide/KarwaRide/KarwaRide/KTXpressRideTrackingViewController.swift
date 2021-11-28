//
//  KTXpressRideTrackingViewController.swift
//  KarwaRide
//
//  Created by Apple on 25/07/21.
//  Copyright © 2021 Karwa. All rights reserved.
//

import UIKit
import Spring
import GoogleMaps
import CDAlertView

class KTXpressRideTrackingViewController: KTBaseCreateBookingController, KTXpressRideTrackingViewModelDelegate {
   
    @IBOutlet weak var rideBookView: UIView!
    @IBOutlet weak var pickupWithInfoView: UIView!

    //driver
    @IBOutlet weak var driverView: UIView!
    @IBOutlet weak var driverImageView: UIImageView!
    @IBOutlet weak var ratingsView: UILabel!
    @IBOutlet weak var driverNameLabel: UILabel!
    @IBOutlet weak var carTypeLabel: UILabel!

    @IBOutlet weak var rideServiceView: UIView!
    @IBOutlet weak var lblServiceType : UILabel!
    @IBOutlet weak var numberOfPassengersLabel : UILabel!
    @IBOutlet weak var imgVehicleType : SpringImageView!
    @IBOutlet weak var carNumber : UILabel!
    
    @IBOutlet weak var cancelButton : UIButton!

    @IBOutlet weak var pickUpAddressButton: SpringButton!
    @IBOutlet weak var dropOffAddressButton: SpringButton!
    @IBOutlet weak var setBookingButton: UIButton!

    @IBOutlet weak var rideServiceTableView: UITableView!
    
    var operationArea = [Area]()
        
    var rideServicePickDropOffData: RideSerivceLocationData? = nil
    
    var vModel : KTXpressRideTrackingViewModel?

    var serverPickUpLocationMarker: GMSMarker!
    var pickUpLocationMarker: GMSMarker!
    var dropOffLocationMarker: GMSMarker!
    var rideInfo: RideInfo!
    var selectedRide: RideVehiceInfo?

    override func viewDidLoad() {
        viewModel = KTXpressRideTrackingViewModel(del:self)
        vModel = viewModel as? KTXpressRideTrackingViewModel
        vModel?.delegate = self
        vModel?.rideServicePickDropOffData = rideServicePickDropOffData
        vModel?.selectedRide = selectedRide
//        self.vModel?.getBookingData()
        // Do any additional setup after loading the view.
        addMap()
        self.navigationItem.hidesBackButton = true;
        self.pickUpAddressButton.titleLabel?.numberOfLines = 2
        self.dropOffAddressButton.titleLabel?.numberOfLines = 2
        setVehicleDetails()
        super.viewDidLoad()
    }
    
    func setVehicleDetails() {
        self.lblServiceType.text = self.selectedRide?.vehicleNo
    }
    
    func updateLocationInMap(location: CLLocation) {
    }
    
    func updateLocationInMap(location: CLLocation, shouldZoomToDefault withZoom: Bool) {
    }
    
    func setPickup(pick: String?) {
        guard pick != nil else {
            return
        }
        self.pickUpAddressButton.setTitle(pick, for: .normal)
    }
        
    func setDropOff(pick: String?) {
        guard pick != nil else {
            return
        }
        self.dropOffAddressButton.setTitle(pick, for: .normal)
    }
     
    func updateUI() {
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
