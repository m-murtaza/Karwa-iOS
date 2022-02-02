//
//  KTBookingDetailsViewController.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 3/15/18.
//  Updated by Sam
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps
import Cosmos
import Spring
import DDViewSwitcher
import UBottomSheet
import StoreKit
import FittedSheets

protocol Demoable {
    static func openDemo(from parent: UIViewController, in view: UIView?)
}

extension Demoable {
    static func addSheetEventLogging(to sheet: SheetViewController) {
        let previousDidDismiss = sheet.didDismiss
        sheet.didDismiss = {
            print("did dismiss")
            previousDidDismiss?($0)
        }
        
        let previousShouldDismiss = sheet.shouldDismiss
        sheet.shouldDismiss = {
            print("should dismiss")
            return previousShouldDismiss?($0) ?? true
        }
        
        let previousSizeChanged = sheet.sizeChanged
        sheet.sizeChanged = { sheet, size, height in
            print("Changed to \(size) with a height of \(height)")
            previousSizeChanged?(sheet, size, height)
        }
    }
}


class KTBookingDetailsViewController: KTBaseDrawerRootViewController, GMSMapViewDelegate, KTBookingDetailsViewModelDelegate,KTCancelViewDelegate,KTFarePopViewDelegate,KTRatingViewDelegate {

    @IBOutlet weak var mapView : GMSMapView!
    
    var sheetCoordinator: UBottomSheetCoordinator!
    var pickAndDropMarker = [GMSMarker]()

    @IBOutlet weak var btnBack : UIButton!
    @IBOutlet weak var btnReveal : UIButton!
    @IBOutlet weak var btnRecenter: UIButton!

    private var vModel : KTBookingDetailsViewModel?
    private var cancelPopup : KTCancelViewController?
    private var ebillPopup : KTFarePopupViewController?
    private var ratingPopup : KTRatingViewController?

//    weak var bottomSheetVC : KTBookingDetailsBottomSheetVC?

    var isOpenFromNotification : Bool = false

    let MAX_ZOOM_LEVEL = 16
    var isAbleToObserveZooming = false
    var haltAutoZooming = false
    var showCancelCharges = false
    var manualMoveBegins: Bool = false
    
    lazy var bottomSheetVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "KTBookingDetailsBottomSheetVC") as? KTBookingDetailsBottomSheetVC
    
    lazy var sheet = SheetViewController(
        controller: bottomSheetVC!,
        sizes: [.percent(0.25), .intrinsic],
        options: SheetOptions(useInlineMode: true))
    
    lazy var scheduleTimeTitleLable: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var bounds : GMSCoordinateBounds = GMSCoordinateBounds()
    
    override func viewDidLoad() {
        if viewModel == nil {
            viewModel = KTBookingDetailsViewModel(del: self)
        }
        
        vModel = viewModel as? KTBookingDetailsViewModel
//
//        sheetCoordinator = UBottomSheetCoordinator(parent: self)
//        sheetCoordinator.dataSource = self
//
        
        bottomSheetVC?.sheet = sheet
        bottomSheetVC?.vModel = viewModel as? KTBookingDetailsViewModel
//        sheetCoordinator.addSheet(bottomSheetVC, to: self)
//        sheetCoordinator.setPosition(self.view.frame.height - 240, animated: true)
//        sheetCoordinator.delegate = self

        mapView.delegate = self
        
        sheet.allowPullingPastMaxHeight = false
        sheet.allowPullingPastMinHeight = false
                
        sheet.dismissOnPull = false
        sheet.dismissOnOverlayTap = false
        sheet.overlayColor = UIColor.clear
        
        sheet.contentViewController.view.layer.shadowColor = UIColor.black.cgColor
        sheet.contentViewController.view.layer.shadowOpacity = 0.1
        sheet.contentViewController.view.layer.shadowRadius = 10
        sheet.allowGestureThroughOverlay = true
        
//        if let view = view {
//            sheet.animateIn(to: view, in: self)
//        } else {
//            self.present(sheet, animated: true, completion: nil)
//        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3)
        {
            self.isAbleToObserveZooming = true
//            let mapInsets = UIEdgeInsets(top: 100.0, left: 100.0, bottom: 100.0, right: 100.0)
//            self.mapView.padding = mapInsets
        }
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true

        let button = UIButton(type: UIButton.ButtonType.custom)
        button.setImage(UIImage(named: "back_arrow_ico"), for: .normal)
        button.addTarget(self, action:#selector(popViewController), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 35, height: 20)
        button.imageEdgeInsets = Device.getLanguage().contains("AR") ? UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) : UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.leftBarButtonItem = barButton
        self.navigationController?.navigationBar.backIndicatorImage = nil
        
        // Do any additional setup after loading the view.
    }
    
    
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition)
    {
        if(isAbleToObserveZooming && !haltAutoZooming)
        {
            haltAutoZooming = true
        }
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        manualMoveBegins = true
    }
    
    var isBottomSheetExpanded = true
    
    func getMapPadding() -> CGFloat
    {
        return isBottomSheetExpanded ? 420 : 40
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if(vModel?.bookingStatii() == BookingStatus.CONFIRMED.rawValue || vModel?.bookingStatii() == BookingStatus.PICKUP.rawValue || vModel?.bookingStatii() == BookingStatus.ARRIVED.rawValue || vModel?.bookingStatii() == BookingStatus.DISPATCHING.rawValue) {
            navigationController?.isNavigationBarHidden = true
            btnBack.isHidden = isOpenFromNotification
        } else {
            btnBack.isHidden = true 
        }
        btnReveal.isHidden = !isOpenFromNotification
        self.navigationController?.interactivePopGestureRecognizer?.delaysTouchesBegan = false
        self.mapView.settings.rotateGestures = false
        self.mapView.settings.tiltGestures = false
        if let view = view {
            sheet.animateIn(to: view, in: self)
        } else {
            self.present(sheet, animated: true, completion: nil)
        }
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
            }
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

    func setBooking(booking : KTBooking) {
        if viewModel == nil {
            viewModel = KTBookingDetailsViewModel(del: self)
        }
        vModel = viewModel as? KTBookingDetailsViewModel
        (viewModel as! KTBookingDetailsViewModel).booking = booking
        navigationItem.title = (vModel?.pickupDayAndTime())! + (vModel?.pickupDateOfMonth())!  + (vModel?.pickupMonth())! + (vModel?.pickupYear())!
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:- ETA
    func updateEta(eta: String)
    {
        bottomSheetVC?.updateEta(eta: eta)
    }
    
    func hideEtaView()
    {
        bottomSheetVC?.hideEtaView()
    }
    
    func showEtaView()
    {
        bottomSheetVC?.showEtaView()
    }
    
    func showHideShareButton(_ show : Bool)
    {
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
            
            let tabController = segue.destination as! TabViewController
            let createBooking : KTCreateBookingViewController = tabController.viewControllers![0] as! KTCreateBookingViewController
            createBooking.booking = vModel?.booking
            createBooking.setRemoveBookingOnReset(removeBookingOnReset: false)
            //self.navigationController?.viewControllers = [createBooking]
            
//            sideMenuController?.contentViewController = self.storyboard?.instantiateViewController(withIdentifier: "XpressBookingNavigationViewController") as? UINavigationController
//            
//            xpressRebookSelected = true
//            xpressRebookPickUpSelected = true
//            xpressRebookDropOffSelected = true
//            xpressRebookPassengerSelected = true
//            xpressRebookNumberOfPassenger = 1
//
//            xpressRebookPickUpCoordinates.latitude = (viewModel as! KTXpresssBookingDetailsViewModel).booking?.pickupLat ?? 0.0
//            xpressRebookPickUpCoordinates.longitude = (viewModel as! KTXpresssBookingDetailsViewModel).booking?.pickupLon ?? 0.0
//
//            xpressRebookDropOffCoordinates.latitude = (viewModel as! KTXpresssBookingDetailsViewModel).booking?.dropOffLat ?? 0.0
//            xpressRebookDropOffCoordinates.longitude = (viewModel as! KTXpresssBookingDetailsViewModel).booking?.dropOffLon ?? 0.0
//            
//            sideMenuController?.hideMenu()
            
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

        present(alertController, animated: true, completion: nil)
    }

    @IBAction func btnBackTapped(_ sender: Any) {
        
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
    }
    //MARK:- Assignment Info
    
    func updateAssignmentInfo()
    {
        bottomSheetVC?.updateAssignmentInfo()
    }
    //MARK:- CallerId
    func updateCallerId()
    {
    }
    //MARK:- Booking Card
    func updateBookingCard()
    {
        bottomSheetVC?.updateBookingCard()
    }
    
    func updateBookingStatusOnCard(_ withAnimation: Bool)
    {
        bottomSheetVC?.updateBookingStatusOnCard(withAnimation)
    }
    
    func updateBookingStatusOnCard()
    {
        updateBookingStatusOnCard(false)
    }
    
    func updateBookingCardForCompletedBooking() {
        
        bottomSheetVC?.updateBookingCardForCompletedBooking()
    }
    
    func updateBookingCardForUnCompletedBooking() {
        bottomSheetVC?.updateBookingCardForUnCompletedBooking()
    }
    
    
    //MARK:- Map
    func initializeMap(location : CLLocationCoordinate2D) {
        
        let camera = GMSCameraPosition.camera(withLatitude: location.latitude, longitude: location.longitude, zoom: 12.0)
        
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
    
    func updateMapCamera() {
        if manualMoveBegins == false
        {
            if(marker != nil)
            {
                var bounds = GMSCoordinateBounds()
                bounds = bounds.includingCoordinate((marker?.position)!)
                bounds = bounds.includingCoordinate((vModel?.currentLocation())!)
                
                var update : GMSCameraUpdate?
                update = GMSCameraUpdate.fit(bounds, withPadding: 100)
                mapView.animate(with: update!)
            }
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
        
        bounds = bounds.includingCoordinate(marker.position)
        
    }
    
    func addMarkerOnMapAndGet(location: CLLocationCoordinate2D, image: UIImage) -> GMSMarker {
        let marker = GMSMarker()
        marker.position = location
        
        marker.icon = image
        marker.groundAnchor = CGPoint(x:0.5,y:0.5)
        marker.map = self.mapView
        
        bounds = bounds.includingCoordinate(marker.position)
        return marker
        
    }
    
    func addPickupMarker(location : CLLocationCoordinate2D) {
        
        pickAndDropMarker.append(addMarkerOnMapAndGet(location: location, image: UIImage(named:"APPickUpMarker")!))
//        addMarkerOnMap(location: location, image: UIImage(named:"APPickUpMarker")!)
        //focusMapToShowAllMarkers
    }
    
    func addDropOffMarker(location: CLLocationCoordinate2D) {
        
        pickAndDropMarker.append(addMarkerOnMapAndGet(location: location, image: UIImage(named:"APDropOffMarker")!))
        
        focusMapToShowAllMarkers(gmsMarker: pickAndDropMarker)
        
//        addMarkerOnMap(location: location, image: UIImage(named:"APDropOffMarker")! )
//
//        mapView.setMinZoom(1, maxZoom: 15)//prevent to over zoom on fit and animate if bounds be too small
//
////        let update = GMSCameraUpdate.fit(bounds, withPadding: 50)
//        mapView.animate(with: GMSCameraUpdate.fit(bounds, with: UIEdgeInsets(top: 0, left: -10, bottom: 50, right: 100)))
//
//        mapView.setMinZoom(1, maxZoom: 20)
        
    }
    
    func setMapCamera(bound : GMSCoordinateBounds) {
        
        mapView.animate(with: GMSCameraUpdate.fit(bound, with: UIEdgeInsets(top: 0, left: 0, bottom: 70, right: 100)))
        
//        mapView.animate(with: GMSCameraUpdate.fit(bound, withPadding: 100.0))
    }
    
    func clearMaps()
    {
        mapView.clear()
    }
    
    //MARK: - Bottom Bar Buttons
    func updateLeftBottomBarButtom(title: String, color: UIColor,tag: Int )
    {
    }

    func updateRightBottomBarButtom(title: String, color: UIColor, tag: Int )
    {
    }
    
    @IBAction func leftBottomBarButtonTapped(btnSender: UIButton)
    {
    }
    
    @IBAction func rightBottomBarButtonTapped(btnSender: UIButton)
    {
    }
    
    func moveToBooking()
    {
        
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
        
        let navController = UINavigationController(rootViewController: ratingPopup!) // Creating a navigation controller with VC1 at the root of the navigation stack.
        ratingPopup?.booking((vModel?.booking)!)
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true, completion: nil)
    }
    
    func closeRating(_ rating : Int32) {
//        ratingPopup?.view.removeFromSuperview()
//        ratingPopup = nil

        self.dismiss(animated: true, completion: nil)
        
        showSuccessBanner("  ", "booking_rated".localized())
        
        if(rating > 3)
        {
//            let confettiView = SAConfettiView(frame: self.view.bounds)
//            confettiView.type = .Diamond
//            confettiView.colors = [UIColor.yellow]
//            confettiView.intensity = 1.00
//
//            view.addSubview(confettiView)
//            confettiView.startConfetti()

            let isAppStoreRatingDone = SharedPrefUtil.getSharePref(SharedPrefUtil.IS_APP_STORE_RATING_DONE)
            if(isAppStoreRatingDone.isEmpty || isAppStoreRatingDone.count == 0)
            {
                // Asking for App Store Rating
                showRatingDialog(rating)
            }
        }
    }

    func showRatingDialog(_ rating : Int32)
    {
        SharedPrefUtil.setSharedPref(SharedPrefUtil.IS_APP_STORE_RATING_DONE, "true")
        SKStoreReviewController.requestReview()
    }

    func showCancelBooking() {
        cancelPopup = storyboard?.instantiateViewController(withIdentifier: "CancelReasonPopup") as? KTCancelViewController
        
        cancelPopup?.bookingId = (vModel?.bookingId())!
        cancelPopup?.bookingStatii = (vModel?.bookingStatii())!
        cancelPopup?.delegate = self
        
        if(vModel?.bookingStatii() == BookingStatus.CONFIRMED.rawValue) {
            cancelPopup?.showCancelCharges = true
        } else if (vModel?.bookingStatii() == BookingStatus.ARRIVED.rawValue) {
            cancelPopup?.showCancelCharges = true
        }else if (vModel?.bookingStatii() == BookingStatus.PICKUP.rawValue) {
            cancelPopup?.showCancelCharges = true
        }
        
        cancelPopup?.view.frame = self.view.bounds
        view.addSubview((cancelPopup?.view)!)
        addChildViewController(cancelPopup!)
    }
    
    @objc func popViewController() {
        
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
        bottomSheetVC?.hidePhoneButton()
    }
    
    func hideDriverInfoBox() {
        self.showCancelCharges = false
        bottomSheetVC?.hideDriverInfoBox()
    }
    
    func showDriverInfoBox() {
        self.showCancelCharges = true
        bottomSheetVC?.showDriverInfoBox()
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
        bottomSheetVC?.updateHeaderMsg(msg)
    }
    
    func hideRecenterBtn()
    {
        btnRecenter.isHidden = true
    }
    
    @IBAction func btnRecenterTap(_ sender: Any)
    {
        manualMoveBegins = false
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

