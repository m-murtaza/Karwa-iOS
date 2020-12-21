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
import Spring
import DDViewSwitcher
import UBottomSheet

class KTBookingDetailsViewController: KTBaseDrawerRootViewController, GMSMapViewDelegate, KTBookingDetailsViewModelDelegate,KTCancelViewDelegate,KTFarePopViewDelegate,KTRatingViewDelegate {

    @IBOutlet weak var mapView : GMSMapView!
    
    var sheetCoordinator: UBottomSheetCoordinator!
    
    @IBOutlet weak var btnBack : UIButton!
    @IBOutlet weak var btnReveal : UIButton!
    @IBOutlet weak var btnRecenter: UIButton!

    private var vModel : KTBookingDetailsViewModel?
    private var cancelPopup : KTCancelViewController?
    private var ebillPopup : KTFarePopupViewController?
    private var ratingPopup : KTRatingViewController?
    
    
    //    @IBOutlet weak var btnShare: SpringButton!
//    @IBOutlet weak var toolTipBtnShare: SpringImageView!
    
    var bottomSheetVC : KTBookingDetailsBottomSheetVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "KTBookingDetailsBottomSheetVC") as! KTBookingDetailsBottomSheetVC

    var isOpenFromNotification : Bool = false

    let MAX_ZOOM_LEVEL = 16
    var isAbleToObserveZooming = false
    var haltAutoZooming = false

    override func viewDidLoad() {
        if viewModel == nil {
            viewModel = KTBookingDetailsViewModel(del: self)
        }
        
        vModel = viewModel as? KTBookingDetailsViewModel

        sheetCoordinator = UBottomSheetCoordinator(parent: self)

        bottomSheetVC.sheetCoordinator = sheetCoordinator

        bottomSheetVC.vModel = viewModel as? KTBookingDetailsViewModel
        sheetCoordinator.addSheet(bottomSheetVC, to: self)
        sheetCoordinator.setPosition(520, animated: true)

        mapView.delegate = self

        DispatchQueue.main.asyncAfter(deadline: .now() + 3)
        {
            self.isAbleToObserveZooming = true
//            let mapInsets = UIEdgeInsets(top: 100.0, left: 100.0, bottom: 100.0, right: 100.0)
//            self.mapView.padding = mapInsets
        }
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition)
    {
        if(isAbleToObserveZooming && !haltAutoZooming)
        {
            haltAutoZooming = true
        }
    }
    
    var isBottomSheetExpanded = true
    
    func getMapPadding() -> CGFloat
    {
        return isBottomSheetExpanded ? 420 : 40
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

    override func viewDidDisappear(_ animated: Bool)
    {
        vModel?.viewWillDisappear()
    }
    
    override func updateForBooking(_ booking: KTBooking)
    {
        vModel?.bookingUpdateTriggered(booking)
    }
    
    var gmsMarker : Array<GMSMarker> = Array()

    var polyline = GMSPolyline()
    weak var animationPolyline = GMSPolyline()
    var path = GMSPath()
    var animationPath = GMSMutablePath()
    var i: UInt = 0
    var timer: Timer!
    var bgPolylineColor : UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.0)

    public func addPointsOnMap(encodedPath points: String) {
        removeOldPolyline()
        if(!points.isEmpty)
        {
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
            
//            addMarkerOnMap(location: path.coordinate(at:0), image: UIImage(named: "BookingMapDirectionPickup")!)
//            addMarkerOnMap(location: path.coordinate(at:path.count()-1), image: UIImage(named: "BookingMapDirectionDropOff")!)
        }
    }
    
    func removeOldPolyline()
    {
        polyline.map = nil
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

    func focusMapToShowAllMarkers(gmsMarker : Array<GMSMarker>) {
        if(!haltAutoZooming)
        {
            var bounds = GMSCoordinateBounds()
            for marker: GMSMarker in gmsMarker {
                bounds = bounds.includingCoordinate(marker.position)
            }
            
            var update : GMSCameraUpdate?
            update = GMSCameraUpdate.fit(bounds, withPadding: CGFloat(60))
            
            CATransaction.begin()
            CATransaction.setValue(1.0, forKey: kCATransactionAnimationDuration)
            mapView.animate(with: update!)
            CATransaction.commit()
        }
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
        bottomSheetVC.updateEta(eta: eta)
//        lblEta.text = eta
    }
    
    func hideEtaView() {
        bottomSheetVC.hideEtaView()
//        etaView.isHidden = true
    }
    
    func showEtaView() {
        bottomSheetVC.showEtaView()
//        etaView.isHidden = false
    }
    
    func showHideShareButton(_ show : Bool)
    {
//        bottomSheetVC.showHideShareButton(show)
//        btnShare.isHidden = !show
//        if(show)
//        {
//            let isShareTripToolTipShown = SharedPrefUtil.getSharePref(SharedPrefUtil.IS_SHARE_TRIP_TOOL_TIP_SHOWN)
//            showHideToolTipShareButton((isShareTripToolTipShown.isEmpty || isShareTripToolTipShown.count == 0))
//        }
    }

    var isTooltipVisible : Bool = false

    func addAndGetMarkerOnMap(location: CLLocationCoordinate2D, image: UIImage) -> GMSMarker{
        let marker = GMSMarker()
        marker.position = location
        
        marker.icon = image
        marker.groundAnchor = CGPoint(x:0.5,y:0.5)
        marker.map = self.mapView
        
        return marker
    }
    
    func getMarkerOnMap(location: CLLocationCoordinate2D, image: UIImage) -> GMSMarker{
        let marker = GMSMarker()
        marker.position = location
        marker.icon = image
        marker.groundAnchor = CGPoint(x:0.5,y:0.5)
        
        return marker
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
        else if(segue.identifier == "segueComplaintCategorySelection")
        {
            let navVC = segue.destination as? UINavigationController
            let destination = navVC?.viewControllers.first as! KTComplaintCategoryViewController
            destination.bookingId = (vModel?.booking?.bookingId)!
        }
     }
    
    @IBAction func moreOptionsTapped(_ sender: Any)
    {
//        let image = UIImage(named: "ico_rebook")
//        let action = UIAlertAction(title: "Action 1", style: .default, handler: nil);
//        action.setValue(image?.withRenderingMode(.alwaysOriginal), forKey: "image")
        
        
        let alertController = UIAlertController()
        
        
        
        let rebookIcon = UIImage(named: "ico_rebook")
        let rebookAction = UIAlertAction(title: "Re-book This Ride", style: .default)
            { (action: UIAlertAction!) in
                self.vModel?.buttonTapped(withTag: BottomBarBtnTag.Rebook.rawValue)
            }
        rebookAction.setValue(rebookIcon, forKey: "image")
        
        let complainIcon = UIImage(named: "ico_complaint")
        let complainAction = UIAlertAction(title: "Complaint or Lost Item", style: .default)
            { (action: UIAlertAction!) in
                self.performSegue(withIdentifier: "segueComplaintCategorySelection", sender: self)
            }
        complainAction.setValue(complainIcon, forKey: "image")
        
        let cancelIcon = UIImage(named: "ico_cancel")
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
            { (action: UIAlertAction!) in}
        cancelAction.setValue(cancelIcon, forKey: "image")
        
        alertController.addAction(rebookAction)
        alertController.addAction(complainAction)
        alertController.addAction(cancelAction)

//        actionController.addAction(Action(ActionData(title: "Re-book This Ride", image: UIImage(named: "ico_rebook")!), style: .default, handler:
//            { action in
//                self.vModel?.buttonTapped(withTag: BottomBarBtnTag.Rebook.rawValue)
//            }
//        ))
//        actionController.addAction(Action(ActionData(title: "Complaint or Lost Item", image: UIImage(named: "ico_complaint")!), style: .default, handler:
//            { action in
//                self.performSegue(withIdentifier: "segueComplaintCategorySelection", sender: self)
//            }
//        ))
//        actionController.addAction(Action(ActionData(title: "Cancel", image: UIImage(named: "ico_cancel")!), style: .default, handler:{ action in}))

        present(alertController, animated: true, completion: nil)
    }

    @IBAction func btnBackTapped(_ sender: Any) {
        
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
    }
    //MARK:- Assignment Info
    
    func updateAssignmentInfo() {
        
        bottomSheetVC.updateAssignmentInfo()
//        lblDriverName.text = vModel?.driverName()
//        lblVehicleNumber.text = vModel?.vehicleNumber()
//        starView.rating = (vModel?.driverRating())!
//        imgNumberPlate.image = vModel?.imgForPlate()
        
    }
    //MARK:- CallerId
    func updateCallerId() {
//        if isLargeScreen() {
//            viewCallerID.isHidden = false
//            lblCallerId.text = vModel?.idForCaller()
//        }
        
    }
    //MARK:- Booking Card
    func updateBookingCard()
    {
        bottomSheetVC.updateBookingCard()
    }
    
    func updateBookingStatusOnCard(_ withAnimation: Bool)
    {
        bottomSheetVC.updateBookingStatusOnCard(withAnimation)
    }
    
    func updateBookingStatusOnCard()
    {
        updateBookingStatusOnCard(false)
    }
    
    func updateBookingCardForCompletedBooking() {
        
        bottomSheetVC.updateBookingCardForCompletedBooking()
    }
    
    func updateBookingCardForUnCompletedBooking() {
        bottomSheetVC.updateBookingCardForUnCompletedBooking()
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
            marker?.groundAnchor = CGPoint(x: 0.5, y: 0.5)
            marker?.rotation = CLLocationDegrees(vTrack.bearing)
            marker?.icon = (viewModel as! KTBookingDetailsViewModel).imgForTrackMarker()
            marker?.map = self.mapView
            
        }
        else {
            //Animate
//            markerMovement.ARCarMovement(marker: marker!, oldCoordinate: (marker?.position)!, newCoordinate: vTrack.position, mapView: self.mapView, bearing: vTrack.bearing)
            markerMovement.moveMarker(marker: marker!, from: (marker?.position)!, to: vTrack.position, degree: vTrack.bearing)
        }
    }
    
    func updateMapCamera()
    {
        if(marker != nil)
        {
            var bounds = GMSCoordinateBounds()
            bounds = bounds.includingCoordinate((marker?.position)!)
            bounds = bounds.includingCoordinate((vModel?.currentLocation())!)
            
            var update : GMSCameraUpdate?
            update = GMSCameraUpdate.fit(bounds, withPadding: 100.0)
            mapView.animate(with: update!)
        }
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
        //TODO: Move them to Booking Details Bottom Sheet VC
//        if !title.isEmpty {
//
//            leftBottomBarButton.setTitle(title, for: .normal)
//            leftBottomBarButton.setTitleColor(color, for: .normal)
//            leftBottomBarButton.tag = tag
//        }
//        else {
//            leftBottomBarButton.isHidden = true
//        }
    }

    func updateRightBottomBarButtom(title: String, color: UIColor, tag: Int ) {
        
    }
    
    @IBAction func leftBottomBarButtonTapped(btnSender: UIButton) {
    }
    
    @IBAction func rightBottomBarButtonTapped(btnSender: UIButton) {
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
    
    func hideMoreOptions()
    {
        //TODO: Move them to Booking Details Bottom Sheet VC
//        btnMoreOptions.isHidden = true
//        rightArrow.isHidden = true
//        hintText.isHidden = true
    }
    
    func showMoreOptions()
    {
    }
    
    func showFareBreakdown()
    {
        if(vModel?.fareDetailsBody() != nil && (vModel?.fareDetailsBody()?.count)! > 0)
        {
            ebillPopup = storyboard?.instantiateViewController(withIdentifier: "FarePopup") as? KTFarePopupViewController
            
            ebillPopup?.delegate = self
            ebillPopup?.view.frame = self.view.bounds
            view.addSubview((ebillPopup?.view)!)
            addChildViewController(ebillPopup!)
            ebillPopup?.set(header: vModel?.fareDetailsHeader(), body: vModel?.fareDetailsBody(), title: (vModel?.estimateTitle())!, total: (vModel?.fareDetailTotal())!,titleTotal: (vModel?.fareDetailTitleTotal())!)
            
            ebillPopup?.updateViewForSmallSize()
        }
        else
        {
            showError(title: "", message: "Estimated Fare not available at the moment")
        }
    }
    
    func hidePhoneButton() {
        bottomSheetVC.hidePhoneButton()
    }
    
    func hideDriverInfoBox() {
        bottomSheetVC.hideDriverInfoBox()
    }
    
    func showDriverInfoBox() {
        bottomSheetVC.showDriverInfoBox()
    }
    
    func setMapPadding(height : CGFloat)
    {
        let padding = UIEdgeInsets(top: 0, left: 0, bottom: height, right: 0)
        mapView.padding = padding
    }
    
    func setMapPadding()
    {
        let padding = UIEdgeInsets(top: 0, left: 0, bottom: getMapPadding(), right: 0)
        mapView.padding = padding
    }
    
    func updateHeaderMsg(_ msg : String)
    {
        bottomSheetVC.updateHeaderMsg(msg)
    }
    
    func hideRecenterBtn()
    {
        btnRecenter.isHidden = true
    }
    
    @IBAction func btnRecenterTap(_ sender: Any)
    {
        updateMapCamera()
    }

    func showRecenterBtn()
    {
        btnRecenter.isHidden = false
    }
}

extension UInt {
    /// SwiftExtensionKit
    var toInt: Int { return Int(self) }
}

