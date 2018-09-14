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

class KTBookingDetailsViewController: KTBaseDrawerRootViewController, GMSMapViewDelegate, KTBookingDetailsViewModelDelegate,KTCancelViewDelegate,KTFarePopViewDelegate,KTRatingViewDelegate {
    
    @IBOutlet weak var mapView : GMSMapView!
    
    @IBOutlet weak var lblPickAddress : UILabel!
    @IBOutlet weak var lblPickMessage : UILabel!
    @IBOutlet weak var imgPickMsgImage :UIImageView!
    @IBOutlet weak var viewCard : KTShadowView!
    @IBOutlet weak var lblDayOfMonth: UILabel!
    @IBOutlet weak var lblMonth: UILabel!
    @IBOutlet weak var lblYear: UILabel!
    @IBOutlet weak var lblDropoffAddress: UILabel!
    @IBOutlet weak var lblDayAndTime: UILabel!
    @IBOutlet weak var lblServiceType: UILabel!
    @IBOutlet weak var imgBookingStatus: UIImageView!

    @IBOutlet weak var lblEstimatedFare : UILabel!
    @IBOutlet weak var titleEstimatedFare: UILabel!
    
    @IBOutlet weak var starView : CosmosView!
    @IBOutlet weak var lblEta : UILabel!
    @IBOutlet weak var lblPickTime : RoundedLable!
    @IBOutlet weak var lblDropTime : RoundedLable!
    
    @IBOutlet weak var lblCallerId: UILabel!
    @IBOutlet weak var viewCallerID : UIView!
    
    @IBOutlet weak var lblDriverName : UILabel!
    @IBOutlet weak var lblVehicleNumber :UILabel!
    @IBOutlet weak var imgNumberPlate : UIImageView!
    
    @IBOutlet weak var leftBottomBarButton : UIButton!
    @IBOutlet weak var rightBottomBarButton : UIButton!
    
    @IBOutlet weak var btnBack : UIButton!
    @IBOutlet weak var btnReveal : UIButton!
    
    @IBOutlet weak var btnPhone: UIButton!
    @IBOutlet weak var driverInfoBox : UIView!
    @IBOutlet weak var etaView : UIView!
    
    @IBOutlet weak var imgBookingBar : UIImageView!
    
    @IBOutlet weak var constraintDriverInfoHeightConstraint : NSLayoutConstraint!
    @IBOutlet weak var constraintGapDriverInfoToBookingDetails : NSLayoutConstraint!
    
    @IBOutlet weak var constraintHeighBookingInfoBox : NSLayoutConstraint!
    @IBOutlet weak var constraintHeighBookingInfoLargeBox : NSLayoutConstraint!
    @IBOutlet weak var constraintHeightPickTime : NSLayoutConstraint!
    @IBOutlet weak var constraintHeightDropTime : NSLayoutConstraint!
    @IBOutlet weak var constraintSpacePickTimeNPickAddress : NSLayoutConstraint!
    @IBOutlet weak var constraintSpaceDropTimeNDropAddress : NSLayoutConstraint!
    @IBOutlet weak var constraintPickDropBarHeight : NSLayoutConstraint!
    
    @IBOutlet weak var constraintSpaceSapratorToPickupLable : NSLayoutConstraint!
    @IBOutlet weak var constraintSapratorCenterAlign : NSLayoutConstraint!
    
    private var vModel : KTBookingDetailsViewModel?
    private var cancelPopup : KTCancelViewController?
    private var ebillPopup : KTFarePopupViewController?
    private var ratingPopup : KTRatingViewController?
    
    var isOpenFromNotification : Bool = false
    
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
        
        btnBack.isHidden = isOpenFromNotification
        btnReveal.isHidden = !isOpenFromNotification
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    func setBooking(booking : KTBooking) {
        if viewModel == nil {
            viewModel = KTBookingDetailsViewModel(del: self)
        }
        vModel = viewModel as? KTBookingDetailsViewModel
        (viewModel as! KTBookingDetailsViewModel).booking = booking
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- ETA
    func updateEta(eta: String) {
        lblEta.text = eta
    }
    
    func hideEtaView() {
        etaView.isHidden = true
    }
    
    //MARK: - UI update
    func hideDriverInfoBox() {
        
        constraintDriverInfoHeightConstraint.constant = 0
        constraintGapDriverInfoToBookingDetails.constant = 0
        driverInfoBox.isHidden = true
    }
    
    
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
        if segue.identifier == "segueDetailToReBook"
        {
            let createBooking : KTCreateBookingViewController = segue.destination as! KTCreateBookingViewController
            createBooking.booking = vModel?.booking
            createBooking.setRemoveBookingOnReset(removeBookingOnReset: false)
            //self.navigationController?.viewControllers = [createBooking]
        }
     }
    
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
    //MARK:- CallerId
    func updateCallerId() {
        if isLargeScreen() {
            viewCallerID.isHidden = false
            lblCallerId.text = vModel?.idForCaller()
        }
        
    }
    //MARK:- Booking Card
    func updateBookingCard() {
        
        lblPickAddress.text = vModel?.pickAddress()
        lblDropoffAddress.text = vModel?.dropAddress()
        let msg = vModel?.pickMessage()
        if (msg?.isEmpty)! {
            lblPickMessage.isHidden = true
            imgPickMsgImage.isHidden = true
            constraintHeighBookingInfoBox.constant -= 10
            constraintHeighBookingInfoLargeBox.constant -= 10
        }
        else {
            lblPickMessage.text = vModel?.pickMessage()
        }
        lblDayOfMonth.text = vModel?.pickupDateOfMonth()
        
        lblMonth.text = vModel?.pickupMonth()
        lblYear.text = vModel?.pickupYear()
        
        lblDayAndTime.text = vModel?.pickupDayAndTime()
        
        lblServiceType.text = vModel?.vehicleType()
        
        if(vModel?.bookingStatii() == BookingStatus.COMPLETED.rawValue)
        {
            lblEstimatedFare.text = vModel?.totalFareOfTrip()
            titleEstimatedFare.text = "Fare"
        }
        else
        {
            lblEstimatedFare.text = vModel?.estimatedFare()
            titleEstimatedFare.text = "Est. Fare"
        }
        
        let img : UIImage? = vModel?.bookingStatusImage()
        if img != nil {
            imgBookingStatus.image = img
        }
        
        lblPickTime.text = vModel?.pickupTime()
        lblDropTime.text = vModel?.dropoffTime()
        
        viewCard.backgroundColor = vModel?.cellBGColor()
        
        viewCard.borderColor = vModel?.cellBorderColor()
    }
    
    func updateBookingCardForCompletedBooking() {
        
        /*constraintHeighBookingInfoBox.constant -= 10
         constraintHeighBookingInfoLargeBox.constant -= 10
         imgPickMsgImage.isHidden = true
         lblPickMessage.isHidden = true*/
    }
    
    func updateBookingCardForUnCompletedBooking() {
        
        imgBookingBar.image = UIImage(named:"BookingPickDropBar")
        constraintPickDropBarHeight.constant -= 10
        
        constraintHeighBookingInfoBox.constant -= 10
        constraintHeighBookingInfoLargeBox.constant -= 10
        lblPickTime.isHidden = true
        lblDropTime.isHidden = true
        
        constraintHeightPickTime.constant = 0
        constraintHeightDropTime.constant = 0
        constraintSpacePickTimeNPickAddress.constant = 0
        constraintSpaceDropTimeNDropAddress.constant = -16
        
        constraintSapratorCenterAlign.priority = UILayoutPriority.defaultHigh
        constraintSpaceSapratorToPickupLable.priority = UILayoutPriority.defaultLow
    }
    
    
    //MARK:- Map
    func initializeMap(location : CLLocationCoordinate2D) {
        
        let camera = GMSCameraPosition.camera(withLatitude: location.latitude, longitude: location.longitude, zoom: 14.0)
        
        self.mapView.camera = camera;
        self.mapView.delegate = self
        
        let padding = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
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
    
    func showCurrentLocationDot(show: Bool) {
        self.mapView!.isMyLocationEnabled = show
        //self.mapView!.settings.myLocationButton = show
    }
    
    var  marker : GMSMarker?
    let markerMovement : ARCarMovement = ARCarMovement()
    func showUpdateVTrackMarker(vTrack: VehicleTrack) {
        
        if marker == nil {
            //Create new
            marker = GMSMarker()
            marker?.position = vTrack.position
            marker?.rotation = CLLocationDegrees(vTrack.bearing)
            marker?.icon = (viewModel as! KTBookingDetailsViewModel).imgForTrackMarker()
            marker?.map = self.mapView
            
        }
        else {
            //Animate
            markerMovement.ARCarMovement(marker: marker!, oldCoordinate: (marker?.position)!, newCoordinate: vTrack.position, mapView: self.mapView, bearing: vTrack.bearing)
        }
        
        updateMapCamera()
    }
    
    func updateMapCamera() {
        
        
        var bounds = GMSCoordinateBounds()
        bounds = bounds.includingCoordinate((marker?.position)!)
        bounds = bounds.includingCoordinate((vModel?.currentLocation())!)
        
        var update : GMSCameraUpdate?
        update = GMSCameraUpdate.fit(bounds, withPadding: 100.0)
        
        mapView.animate(with: update!)
    }
    
    func showPathOnMap(path: GMSPath) {
        var polyline = GMSPolyline()
        polyline = GMSPolyline.init(path: path)
        polyline.strokeWidth = 3
        polyline.strokeColor =    UIColor(displayP3Red: 0, green: 97/255, blue: 112/255, alpha: 255/255)
        polyline.map = self.mapView

        var bounds = GMSCoordinateBounds()
        for index in 1 ... (path.count().toInt) {
            bounds = bounds.includingCoordinate(path.coordinate(at: UInt(index)))
        }
        
        mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 50.0))
        
        addMarkerOnMap(location: path.coordinate(at:0), image: UIImage(named: "BookingMapDirectionPickup")!)
        addMarkerOnMap(location: path.coordinate(at:path.count()-1), image: UIImage(named: "BookingMapDirectionDropOff")!)
    }
    
    var polyline = GMSPolyline()
    
    func showRouteOnMap(points pointsStr: String)
    {
        polyline.map = nil

        let path = GMSPath.init(fromEncodedPath: pointsStr)
        polyline = GMSPolyline.init(path: path)
        polyline.strokeWidth = 3
        polyline.strokeColor = UIColor(displayP3Red: 0, green: 97/255, blue: 112/255, alpha: 255/255)
        polyline.map = mapView
    }
    
    func addMarkerOnMap(location: CLLocationCoordinate2D, image: UIImage) {
        let marker = GMSMarker()
        marker.position = location
        
        marker.icon = image
        marker.groundAnchor = CGPoint(x:0.5,y:0.5)
        marker.map = self.mapView
    }
    
    func addPickupMarker(location : CLLocationCoordinate2D) {
        addMarkerOnMap(location: location, image: UIImage(named:"APPickUpMarker")!)
    }
    
    func addDropOffMarker(location: CLLocationCoordinate2D) {
        addMarkerOnMap(location: location, image: UIImage(named:"APDropOffMarker")! )
    }
    
    func setMapCamera(bound : GMSCoordinateBounds) {
        
        mapView.animate(with: GMSCameraUpdate.fit(bound, withPadding: 50.0))
    }
    
    func clearMaps()
    {
        mapView.clear()
    }
    
    //MARK: - Bottom Bar Buttons
    func updateLeftBottomBarButtom(title: String, color: UIColor,tag: Int ) {
        if !title.isEmpty {
            
            leftBottomBarButton.setTitle(title, for: .normal)
            leftBottomBarButton.setTitleColor(color, for: .normal)
            leftBottomBarButton.tag = tag
        }
        else {
            leftBottomBarButton.isHidden = true
        }
    }
    func updateRightBottomBarButtom(title: String, color: UIColor, tag: Int ) {
        if !title.isEmpty {
            rightBottomBarButton.setTitle(title, for: .normal)
            rightBottomBarButton.setTitleColor(color, for: .normal)
            rightBottomBarButton.tag = tag
        }
        else {
            rightBottomBarButton.isHidden = true
        }
        
    }
    
    @IBAction func leftBottomBarButtonTapped(btnSender: UIButton) {
        
        vModel?.buttonTapped(withTag: btnSender.tag)
    }
    
    @IBAction func rightBottomBarButtonTapped(btnSender: UIButton) {
        
        vModel?.buttonTapped(withTag: btnSender.tag)
    }
    
    func moveToBooking() {
        
        self.performSegue(name: "segueDetailToReBook")
    }
    
    func showEbill() {
        ebillPopup = storyboard?.instantiateViewController(withIdentifier: "FarePopup") as? KTFarePopupViewController
        
        ebillPopup?.delegate = self
        ebillPopup?.view.frame = self.view.bounds
        view.addSubview((ebillPopup?.view)!)
        addChildViewController(ebillPopup!)
        ebillPopup?.set(header: vModel?.eBillHeader(), body: vModel?.eBillBody(), title: (vModel?.eBillTitle())!, total: (vModel?.eBillTotal())!,titleTotal: (vModel?.ebillTitleTotal())!)
    }
    func closeFareEstimate() {
        ebillPopup?.view.removeFromSuperview()
        ebillPopup = nil
    }
    
    func showRatingScreen() {
        ratingPopup = storyboard?.instantiateViewController(withIdentifier: "RatingReasonPopup") as? KTRatingViewController
        
        ratingPopup?.view.frame = self.view.bounds
        view.addSubview((ratingPopup?.view)!)
        addChildViewController(ratingPopup!)
        ratingPopup?.booking((vModel?.booking)!)
        ratingPopup?.delegate = self
        //self.performSegue(name: "detailToRating")
    }
    
    func closeRating() {
        ratingPopup?.view.removeFromSuperview()
        ratingPopup = nil
    }
    
    func showCancelBooking() {
        cancelPopup = storyboard?.instantiateViewController(withIdentifier: "CancelReasonPopup") as? KTCancelViewController
        
        cancelPopup?.bookingId = (vModel?.bookingId())!
        cancelPopup?.bookingStatii = (vModel?.bookingStatii())!
        cancelPopup?.delegate = self
        cancelPopup?.view.frame = self.view.bounds
        view.addSubview((cancelPopup?.view)!)
        addChildViewController(cancelPopup!)
    }
    
    func popViewController() {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func closeCancel() {
        cancelPopup?.view.removeFromSuperview()
        cancelPopup = nil
    }
    
    func cancelDoneSuccess() {
        self.closeCancel()
        vModel?.cancelDoneSuccess()
    }
    
    func showFareBreakdown() {
        ebillPopup = storyboard?.instantiateViewController(withIdentifier: "FarePopup") as? KTFarePopupViewController
        
        ebillPopup?.delegate = self
        ebillPopup?.view.frame = self.view.bounds
        view.addSubview((ebillPopup?.view)!)
        addChildViewController(ebillPopup!)
        ebillPopup?.set(header: vModel?.fareDetailsHeader(), body: vModel?.fareDetailsBody(), title: (vModel?.estimateTitle())!, total: (vModel?.fareDetailTotal())!,titleTotal: (vModel?.fareDetailTitleTotal())!)
        
        ebillPopup?.updateViewForSmallSize()
    }
    
    func hidePhoneButton() {
        
        btnPhone.isHidden = true
    }
    
}

extension UInt {
    /// SwiftExtensionKit
    var toInt: Int { return Int(self) }
}

