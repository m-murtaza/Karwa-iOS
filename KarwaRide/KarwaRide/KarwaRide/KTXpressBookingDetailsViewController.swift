//
//  KTXpressBookingDetailsViewController.swift
//  KarwaRide
//
//  Created by Satheesh K on 8/8/21.
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

public var xpressRebookSelected = false
public var xpressRebookPickUpSelected = false
public var xpressRebookDropOffSelected = false
public var xpressRebookPassengerSelected = false
public var xpressRebookPickUpCoordinates = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
public var xpressRebookDropOffCoordinates = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
public var xpressRebookNumberOfPassenger = 1

class KTXpressBookingDetailsViewController: KTBaseDrawerRootViewController, GMSMapViewDelegate, KTBookingDetailsViewModelDelegate,KTCancelViewDelegate,KTFarePopViewDelegate,KTRatingViewDelegate,KTXpressRideCreationViewModelDelegate {
    
    
    @IBOutlet weak var mapView : GMSMapView!
    
    @IBOutlet weak var trackRideServiceView : UIView!
    
    var sheetCoordinator: UBottomSheetCoordinator!

    @IBOutlet weak var btnBack : UIButton!
    @IBOutlet weak var btnReveal : UIButton!
    @IBOutlet weak var btnRecenter: UIButton!

    private var vModel : KTXpresssBookingDetailsViewModel?
    private var cancelPopup : KTCancelViewController?
    private var ebillPopup : KTFarePopupViewController?
    private var ratingPopup : KTRatingViewController?
    
    @IBOutlet weak var pickupWithInfoView: UIView!
    @IBOutlet weak var etaLabel: UILabel!

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
    var rideServicePickDropOffData: RideSerivceLocationData? = nil

    var bottomSheetVC : KTXpressBookingDetailsBottomSheetVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "KTXpressBookingDetailsBottomSheetVC") as! KTXpressBookingDetailsBottomSheetVC

    var isOpenFromNotification : Bool = false

    let MAX_ZOOM_LEVEL = 16
    var isAbleToObserveZooming = false
    var haltAutoZooming = false

    lazy var sheet = SheetViewController(
        controller: bottomSheetVC,
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
            viewModel = KTXpresssBookingDetailsViewModel(del: self)
        }
        
        vModel = viewModel as? KTXpresssBookingDetailsViewModel
        vModel?.rideServicePickDropOffData = rideServicePickDropOffData
//
//        sheetCoordinator = UBottomSheetCoordinator(parent: self)
//        sheetCoordinator.dataSource = self
//
        bottomSheetVC.sheet = sheet
        bottomSheetVC.vModel = viewModel as? KTXpresssBookingDetailsViewModel
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
        
        if let view = view {
            sheet.animateIn(to: view, in: self)
        } else {
            self.present(sheet, animated: true, completion: nil)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3)
        {
            self.isAbleToObserveZooming = true
//            let mapInsets = UIEdgeInsets(top: 100.0, left: 100.0, bottom: 100.0, right: 100.0)
//            self.mapView.padding = mapInsets
        }
        super.viewDidLoad()
        initializeValue()
        
        self.navigationItem.hidesBackButton = true

        let button = UIButton(type: UIButton.ButtonType.custom)
        button.setImage(UIImage(named: "back_arrow_ico"), for: .normal)
        button.addTarget(self, action:#selector(popViewController), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 35, height: 20)
        button.imageEdgeInsets = Device.getLanguage().contains("AR") ? UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) : UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.leftBarButtonItem = barButton
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString:"#E5F5F2")

//        self.navigationController?.navigationBar.backIndicatorImage = nil
        // Do any additional setup after loading the view.
    }
    
    func initializeValue() {
        xpressRebookSelected = false
        xpressRebookPickUpSelected = false
        xpressRebookDropOffSelected = false
        xpressRebookPassengerSelected = false
        xpressRebookNumberOfPassenger = 1
        xpressRebookPickUpCoordinates.latitude =  0.0
        xpressRebookPickUpCoordinates.longitude =  0.0
        xpressRebookDropOffCoordinates.latitude = 0.0
        xpressRebookDropOffCoordinates.longitude = 0.0
    }
    
    func showHideNavigationBar(status: Bool) {
        
    }
    
        
    func showAlertForLocationServerOn() {
        
    }
    
    func updateLocationInMap(location: CLLocation) {
        
    }
    
    func updateLocationInMap(location: CLLocation, shouldZoomToDefault withZoom: Bool) {
        
    }
    
    func setProgressViewCounter(countDown: Int) {
        
    }
    
    func showHideRideServiceView(show: Bool) {
        
    }
    
    func updateUI() {
        
    }
    
    func addMarkerForServerPickUpLocation(coordinate: CLLocationCoordinate2D) {
        
    }
    
    func showRideTrackViewController() {
        
    }
    
    func showAlertForTimeOut() {
        
    }
    
    func showAlertForFailedRide(message: String) {
        
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
        if(vModel?.bookingStatii() == BookingStatus.CONFIRMED.rawValue || vModel?.bookingStatii() == BookingStatus.PICKUP.rawValue || vModel?.bookingStatii() == BookingStatus.ARRIVED.rawValue || vModel?.bookingStatii() == BookingStatus.DISPATCHING.rawValue) {
            navigationController?.isNavigationBarHidden = true
            btnBack.isHidden = isOpenFromNotification
        } else {
            btnBack.isHidden = true 
        }
        btnReveal.isHidden = !isOpenFromNotification
        self.navigationController?.interactivePopGestureRecognizer?.delaysTouchesBegan = false
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
    
    var wayPointsMarker : Array<GMSMarker> = Array()

    var polyline = GMSPolyline()
    weak var animationPolyline = GMSPolyline()
    var path = GMSPath()
    var animationPath = GMSMutablePath()
    var i: UInt = 0
    var timer: Timer!
    var bgPolylineColor : UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.0)

    func addPointsOnMapWithWayPoints(encodedPath points: String, wayPoints: [WayPoints]) {
                
        for item in wayPointsMarker {
            item.map = nil
        }
        
        wayPointsMarker.removeAll()
        
        for item in wayPoints {
            
            let wayPointBGView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            let wayCountImageView = UIImageView(frame: CGRect(x: 0, y: 15, width: 100, height: 30))
            wayCountImageView.image = #imageLiteral(resourceName: "whitebox")
            wayCountImageView.contentMode = .scaleAspectFill
            wayCountImageView.clipsToBounds = true
            
            let countL = UILabel(frame: CGRect(x: 10, y: 2, width: 20, height: 20))
            countL.customCornerRadius = 10
            countL.text = "\(item.DropCount)"
            countL.textAlignment = .center
            countL.textColor = .white
            countL.font = UIFont(name: "MuseoSans-700", size: 9.0)!
            countL.clipsToBounds = true
            countL.backgroundColor = UIColor(red: 0, green: 154/255, blue: 169/255, alpha: 1.0)
            
            
            let countLabel = UILabel(frame: CGRect(x: 10, y: 5, width: 100, height: 14))
            countLabel.text = "str_drop".localized()
            countLabel.textAlignment = .center
            countLabel.font = UIFont(name: "MuseoSans-700", size: 10.0)!
            wayCountImageView.addSubview(countL)
            wayCountImageView.addSubview(countLabel)
            
            let wayCountImageView1 = UIImageView(frame: CGRect(x: 0, y: 45, width: 100, height: 30))
            wayCountImageView1.image = #imageLiteral(resourceName: "whitebox")
            wayCountImageView1.contentMode = .scaleAspectFill
            wayCountImageView1.customCornerRadius = 15
            wayCountImageView1.clipsToBounds = true
            
            let countL1 = UILabel(frame: CGRect(x: 10, y: 2, width: 20, height: 20))
            countL1.customCornerRadius = 10
            countL1.text = "\(item.PickCount)"
            countL1.textAlignment = .center
            countL1.textColor = .white
            countL1.font = UIFont(name: "MuseoSans-700", size: 10.0)!
            countL1.clipsToBounds = true
            countL1.backgroundColor = UIColor(red: 0, green: 154/255, blue: 169/255, alpha: 1.0)
            
            
            let countLabel1 = UILabel(frame: CGRect(x: 10, y: 5, width: 100, height: 14))
            countLabel1.text = "str_pick".localized()
            countLabel1.textAlignment = .center
            countLabel1.font = UIFont(name: "MuseoSans-700", size: 9.0)!
            wayCountImageView1.addSubview(countL1)
            wayCountImageView1.addSubview(countLabel1)

//walktopickup
            let wayPointImageView = UIView(frame: CGRect(x: 45, y: 80, width: 14, height: 14))
            wayPointImageView.customCornerRadius = 7
            wayPointImageView.backgroundColor = UIColor(red: 0, green: 154/255, blue: 169/255, alpha: 1.0)
            
            
            if item.DropCount <= 0 {
                wayCountImageView.isHidden = true
            } else if item.PickCount <= 0 {
                wayCountImageView.isHidden = true
                wayCountImageView1.isHidden = false
                countL1.text = "\(item.DropCount)"
                countLabel1.text = "Drop off"

            }
            
            let stackView = UIStackView(arrangedSubviews: [wayCountImageView1, wayCountImageView])
            stackView.axis = .vertical
            stackView.distribution = .fillEqually
            stackView.translatesAutoresizingMaskIntoConstraints = false
//            stackView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        
//            wayPointBGView.addSubview(wayCountImageView1)
//            wayPointBGView.addSubview(wayCountImageView)
            wayPointBGView.addSubview(stackView)
            wayPointBGView.addSubview(wayPointImageView)
            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: wayPointBGView.topAnchor),
                stackView.leftAnchor.constraint(equalTo: wayPointBGView.leftAnchor),
                stackView.rightAnchor.constraint(equalTo: wayPointBGView.rightAnchor),
            ])
            

            let wayPointImage = wayPointBGView.asImage()
            wayPointsMarker.append(self.addAndGetMarkerOnMap(location: CLLocationCoordinate2D(latitude: item.Location.lat, longitude: item.Location.lon), image: wayPointImage))
        }
        
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
            
       //     mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 100.0))
            
            bgPolylineColor = UIColor(red: 0, green: 154/255, blue: 169/255, alpha: 1.0)
            self.timer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(animatePolylinePath), userInfo: nil, repeats: true)
        }
    }
    
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
            
           // mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 100.0))
            
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
            viewModel = KTXpresssBookingDetailsViewModel(del: self)
        }
        vModel = viewModel as? KTXpresssBookingDetailsViewModel
        (viewModel as! KTXpresssBookingDetailsViewModel).booking = booking
        navigationItem.title = (vModel?.pickupDayAndTime())! + (vModel?.pickupDateOfMonth())!  + (vModel?.pickupMonth())! + (vModel?.pickupYear())!
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:- ETA
    func updateEta(eta: String)
    {
        self.etaLabel.text = eta
        bottomSheetVC.updateEta(eta: eta)
    }
    
    func hideEtaView()
    {
        self.etaLabel.isHidden = true
//        bottomSheetVC.hideEtaView()
    }
    
    func showEtaView()
    {
        self.etaLabel.isHidden = false
//        bottomSheetVC.showEtaView()
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
        marker.groundAnchor =  CGPoint(x:0.3,y:1)//CGPoint(x:0.5,y:0.5)
        
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

        present(alertController, animated: true, completion: nil)
    }

    @IBAction func btnBackTapped(_ sender: Any) {
        if let navController = self.navigationController {
            
            if let controller = navController.viewControllers.first(where: { $0 is KTXpressRideCreationViewController }) {
                if navController.viewControllers.count > 5 {
                    navController.popToViewController(navController.viewControllers[3], animated: true)
                } else if navController.viewControllers.count <= 5 {
                    navController.popToViewController(navController.viewControllers[1], animated: true)
                }
                else {
                    navController.popViewController(animated: true)
                }
            } else {
                navController.popViewController(animated: true)
            }

        }
    }
    
    //MARK:- Assignment Info
    
    func updateAssignmentInfo() {
        driverNameLabel.text = vModel?.driverName()
        
        if vModel?.vehicleNumber() == "" || vModel?.bookingStatii() == BookingStatus.CANCELLED.rawValue {
            carNumber.text = "----"
        } else {
            carNumber.text = vModel?.vehicleNumber()
        }
        
        ratingsView.addLeading(image: #imageLiteral(resourceName: "star_ico"), text: String(format: "%.1f", vModel?.driverRating() as! CVarArg), imageOffsetY: 0)
        ratingsView.textAlignment = Device.getLanguage().contains("AR") ? .left : .right
//        imgNumberPlate.image = vModel?.imgForPlate()
    }
    //MARK:- CallerId
    func updateCallerId() {
        
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
        
        self.mapView.clear()
        
        let camera = GMSCameraPosition.camera(withLatitude: location.latitude, longitude: location.longitude, zoom: 15.0)
        
        self.mapView.camera = camera;
        self.mapView.delegate = self
        
        let padding = UIEdgeInsets(top: 0, left: 10, bottom: 75, right: 50)
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
            marker?.icon = (viewModel as! KTXpresssBookingDetailsViewModel).imgForTrackMarker()
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
            
            let pick = CLLocationCoordinate2D(latitude: vModel?.booking?.pickupLat ?? 0.0, longitude: vModel?.booking?.pickupLon ?? 0.0)
            let drop = CLLocationCoordinate2D(latitude: vModel?.booking?.dropOffLat ?? 0.0, longitude: vModel?.booking?.dropOffLon ?? 0.0)
//            bounds.includingCoordinate(pick)
            
            bounds = bounds.includingCoordinate((marker?.position)!)
            bounds = bounds.includingCoordinate(pick)
            bounds = bounds.includingCoordinate(drop)

            var update : GMSCameraUpdate?
            update = GMSCameraUpdate.fit(bounds, withPadding: 80)
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
        
//        if etaLabel.isHidden == false {
//            addMarkerOnMapWithInfoView(location: path.coordinate(at: 0))
//        } else {
//            addMarkerOnMap(location: path.coordinate(at:0), image: UIImage(named: "pin_pickup_map")!)
//        }
        
        //addMarkerOnMap(location: path.coordinate(at:path.count()-1), image: UIImage(named: "pin_dropoff_map")!)
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
    
    func addMarkerOnMapWithInfoView(location: CLLocationCoordinate2D) {
        let marker = GMSMarker()
        marker.position = location
        
        marker.iconView = pickupWithInfoView
        marker.groundAnchor =  CGPoint(x:0.3,y:1)//CGPoint(x:0.5,y:0.5)
        marker.map = self.mapView
        
        bounds = bounds.includingCoordinate(marker.position)
        
    }
    
    
    func addMarkerOnMap(location: CLLocationCoordinate2D, image: UIImage) {
        let marker = GMSMarker()
        marker.position = location
        
        marker.icon = image
        marker.groundAnchor =  CGPoint(x:0.3,y:1)//CGPoint(x:0.5,y:0.5)
        marker.map = self.mapView
        
        bounds = bounds.includingCoordinate(marker.position)
        
    }
    
    func addPickupMarker(location : CLLocationCoordinate2D) {
//        if etaLabel.isHidden == false {
//            addMarkerOnMapWithInfoView(location: location)
//        } else {
//        }
        
        if  (viewModel as! KTXpresssBookingDetailsViewModel).booking?.bookingStatus ==  BookingStatus.CANCELLED.rawValue {
            addMarkerOnMap(location: location, image: UIImage(named: "pin_pickup_map")!)
        }
        

//        addMarkerOnMap(location: location, image: UIImage(named:"APPickUpMarker")!)
    }
    
    func addDropOffMarker(location: CLLocationCoordinate2D) {
//        if etaLabel.isHidden == false {
//            addMarkerOnMapWithInfoView(location: location)
//        } else {
//            addMarkerOnMap(location: location, image: UIImage(named:"pin_dropoff_map")! )
//        }
        addMarkerOnMap(location: location, image: UIImage(named:"pin_dropoff_map")! )

        mapView.setMinZoom(1, maxZoom: 15)//prevent to over zoom on fit and animate if bounds be too small

        let update = GMSCameraUpdate.fit(bounds, withPadding: 50)
        
        mapView.animate(with: update)

        mapView.setMinZoom(1, maxZoom: 20)
        
    }
    
    func setMapCamera(bound : GMSCoordinateBounds) {
        
        mapView.animate(with: GMSCameraUpdate.fit(bound, withPadding: 50.0))
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
//        self.performSegue(name: "segueDetailToReBook")
        
        sideMenuController?.contentViewController = self.storyboard?.instantiateViewController(withIdentifier: "XpressBookingNavigationViewController") as? UINavigationController
        
        xpressRebookSelected = true
        xpressRebookPickUpSelected = true
        xpressRebookDropOffSelected = true
        xpressRebookPassengerSelected = true
        
        xpressRebookNumberOfPassenger = Int((viewModel as! KTXpresssBookingDetailsViewModel).booking?.passengerCount ?? 1)
        xpressRebookPickUpCoordinates.latitude = (viewModel as! KTXpresssBookingDetailsViewModel).booking?.pickupLat ?? 0.0
        xpressRebookPickUpCoordinates.longitude = (viewModel as! KTXpresssBookingDetailsViewModel).booking?.pickupLon ?? 0.0

        xpressRebookDropOffCoordinates.latitude = (viewModel as! KTXpresssBookingDetailsViewModel).booking?.dropOffLat ?? 0.0
        xpressRebookDropOffCoordinates.longitude = (viewModel as! KTXpresssBookingDetailsViewModel).booking?.dropOffLon ?? 0.0
        
        sideMenuController?.hideMenu()
        
//        let rideLocationData = RideSerivceLocationData(pickUpZone: nil, pickUpStation: nil, pickUpStop: nil, dropOffZone: nil, dropOfSftation: nil, dropOffStop: nil, pickUpCoordinate: CLLocationCoordinate2D(latitude: (vModel?.booking?.pickupLon)!, longitude: (vModel?.booking?.pickupLat)!), dropOffCoordinate: CLLocationCoordinate2D(latitude: (vModel?.booking?.dropOffLat)!, longitude: (vModel?.booking?.dropOffLon)!), passsengerCount: 2)
//        let rideService = self.storyboard?.instantiateViewController(withIdentifier: "KTXpressRideCreationViewController") as? KTXpressRideCreationViewController
//        rideService!.rideServicePickDropOffData = rideLocationData
//        self.navigationController?.pushViewController(rideService!, animated: true)
        
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

extension UIView {

    // Using a function since `var image` might conflict with an existing variable
    // (like on `UIImageView`)
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
