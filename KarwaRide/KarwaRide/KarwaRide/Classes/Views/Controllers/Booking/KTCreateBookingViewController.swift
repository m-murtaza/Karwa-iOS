//
//  KTCreateBookingViewController.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 1/16/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
import GoogleMaps
import ScalingCarousel
import Alamofire
import SwiftyJSON

class KTServiceCardCell: ScalingCarouselCell {
    
    @IBOutlet weak var lblServiceType : UILabel!
    @IBOutlet weak var lblBaseFare : UILabel!
    @IBOutlet weak var imgBg : UIImageView!
    @IBOutlet weak var imgVehicleType : UIImageView!
}
class KTCreateBookingConstants {
    
    // MARK: List of Constants
    
    static let DEFAULT_MAP_ZOOM : Float = 15.0
    static let BOUNDS_MARKER_DISTANCE_THRESHOULD : Double = 2000
    static let DEFAULT_MAP_PADDING : Float = 100
    
}
class KTCreateBookingViewController: KTBaseDrawerRootViewController, KTCreateBookingViewModelDelegate {
    
    @IBOutlet weak var mapView : GMSMapView!
    @IBOutlet weak var carousel: ScalingCarouselView!
    @IBOutlet weak var btnPickupAddress: UIButton!
    @IBOutlet weak var btnDropoffAddress: UIButton!
    @IBOutlet weak var btnRevealBtn : UIButton!
    @IBOutlet weak var btnRequestBooking :UIButton!
    @IBOutlet weak var imgPickDestBoxBG :UIImageView!
    @IBOutlet weak var btnPickDate: UIButton!
    @IBOutlet weak var btnCash :UIButton!
    
    @IBOutlet weak var constraintBoxHeight : NSLayoutConstraint!
    @IBOutlet weak var constraintBoxBGImageHeight : NSLayoutConstraint!
    @IBOutlet weak var constraintBoxItemsTopSpace : NSLayoutConstraint!
    @IBOutlet weak var constraintBtnRequestBookingHeight : NSLayoutConstraint!
    @IBOutlet weak var constraintBtnRequestBookingBottomSpace : NSLayoutConstraint!
    
    public var pickupHint : String = ""
    
    override func viewDidLoad() {
        viewModel = KTCreateBookingViewModel(del:self)
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addMap()
        
        self.navigationItem.hidesBackButton = true;
        
        self.btnRevealBtn.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)), for: .touchUpInside)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //TODO: If no pick
        if (viewModel as! KTCreateBookingViewModel).vehicleTypeShouldAnimate() {
            self.carousel!.scrollToItem(at: IndexPath(row: (viewModel as! KTCreateBookingViewModel).maxCarouselIdx(), section: 0), at: UICollectionViewScrollPosition.right, animated: false)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){
                self.carousel!.scrollToItem(at: IndexPath(row: (self.viewModel as! KTCreateBookingViewModel).idxToSelectVehicleType(), section: 0), at: UICollectionViewScrollPosition.right, animated: true)
            }
        }
    }
        
    override func viewWillDisappear(_ animated: Bool) {
        if timer != nil {
            timer.invalidate()
        }
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    @IBAction func btnRequestBooking(_ sender: Any) {
        
        (viewModel as! KTCreateBookingViewModel).btnRequestBookingTapped()
    }
    func bookRide()  {
        (viewModel as! KTCreateBookingViewModel).bookRide()
    }
    
    //MARK: - ViewModel Delegate
    
    func showBookingConfirmation() {
        
        let confirmationPopup = storyboard?.instantiateViewController(withIdentifier: "ConfermationPopupVC") as! BookingConfermationPopupVC
        confirmationPopup.previousView = self
        view.addSubview(confirmationPopup.view)
        addChildViewController(confirmationPopup)
    }
    
    @IBAction func btnPickDateTapped(_ sender: Any) {
        
        let currentDate = Date()
        var dateComponents = DateComponents()
        dateComponents.month = 3
        let threeMonth = Calendar.current.date(byAdding: dateComponents, to: currentDate)
        
        let datePicker = DatePickerDialog(textColor: .red,
                                          buttonColor: .red,
                                          font: UIFont.boldSystemFont(ofSize: 17),
                                          showCancelButton: true)
        datePicker.show("DatePickerDialog",
                        doneButtonTitle: "Done",
                        cancelButtonTitle: "Cancel", defaultDate: (viewModel as! KTCreateBookingViewModel).selectedPickupDateTime,
                        minimumDate: currentDate,
                        maximumDate: threeMonth,
                        datePickerMode: .dateAndTime) { (date) in
                            if let dt = date {
                                (self.viewModel as! KTCreateBookingViewModel).setPickupDate(date: dt)
                            }
        }
    }
    
    // MARK : - UI Update
    func showRequestBookingBtn()  {
        constraintBtnRequestBookingHeight.constant = 60
        constraintBtnRequestBookingBottomSpace.constant = 20
        btnRequestBooking.isHidden = false
        self.view.layoutIfNeeded()
    }
    
    func updatePickDropBox() {
        constraintBoxHeight.constant = 144
        constraintBoxBGImageHeight.constant = 144
        constraintBoxItemsTopSpace.constant = 24
        imgPickDestBoxBG.image = UIImage(named: "BookingPickDropTimeBox")
        btnCash.isHidden = false
        btnPickDate.isHidden = false
    }
    //MARK: - Detail
    func moveToDetailView() {
        self.performSegue(withIdentifier: "segueBookToDetail", sender: self)
    }
    //MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueBookingToAddresspicker" {
            print("prepare for sague")
            let destination : KTAddressPickerViewController = segue.destination as! KTAddressPickerViewController
            (viewModel as! KTCreateBookingViewModel).prepareToMoveAddressPicker()
            destination.pickupAddress = (viewModel as! KTCreateBookingViewModel).pickUpAddress
            if (viewModel as! KTCreateBookingViewModel).dropOffAddress != nil {
                
                    destination.dropoffAddress = (viewModel as! KTCreateBookingViewModel).dropOffAddress
            }
        
            destination.previousView = (viewModel as! KTCreateBookingViewModel)
            
        }
    }
    
    //MARK: - Location & Maps
    func showCurrentLocationDot(show: Bool) {
        self.mapView!.isMyLocationEnabled = show
    }
    
    private func addMap() {

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
    
    func updateCurrentAddress(addressName: String) {
        
        btnPickupAddress.setTitle(addressName, for: UIControlState.normal)
    }
    
    func updateLocationInMap(location: CLLocation) {
        
        //Update map
        if !(viewModel as! KTCreateBookingViewModel).isVehicleNearBy() {
            let camera = GMSCameraPosition.camera(withLatitude: (location.coordinate.latitude), longitude: (location.coordinate.longitude), zoom: KTCreateBookingConstants.DEFAULT_MAP_ZOOM)
         
            self.mapView?.animate(to: camera)
        }
    }
    
    var gmsMarker : Array<GMSMarker> = Array()
    func addMarkerOnMap(vTrack: [VehicleTrack]) {
        gmsMarker.removeAll()
        clearMap()
        vTrack.forEach { track in
            if !track.position.isZeroCoordinate   {
                let marker = GMSMarker()
                marker.position = track.position
                
                if track.trackType == VehicleTrackType.vehicle {
                    marker.rotation = CLLocationDegrees(track.bearing)
                    marker.icon = UIImage(named: "BookingMapTaxiIco")
                    marker.map = self.mapView
                }
                
                gmsMarker.append(marker)
            }
        }
        self.focusMapToShowAllMarkers(gsmMarker: gmsMarker)
    }
    
    func focusMapToShowAllMarkers(gsmMarker : Array<GMSMarker>) {

            var bounds = GMSCoordinateBounds()
            for marker: GMSMarker in gsmMarker {
                bounds = bounds.includingCoordinate(marker.position)
            }
        
        
        var update : GMSCameraUpdate?
        if bounds.northEast.distance(from: bounds.southWest) > KTCreateBookingConstants.BOUNDS_MARKER_DISTANCE_THRESHOULD {
            
            update = GMSCameraUpdate.fit(bounds, withPadding: CGFloat(KTCreateBookingConstants.DEFAULT_MAP_PADDING))
        }
        else {
            update = GMSCameraUpdate.zoom(to: KTCreateBookingConstants.DEFAULT_MAP_ZOOM)
        }
        
        mapView.animate(with: update!)
    
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
    
    
    //Animated Polyline
    var polyline = GMSPolyline()
    var animationPolyline = GMSPolyline()
    var path = GMSPath()
    var animationPath = GMSMutablePath()
    var i: UInt = 0
    var timer: Timer!
    var bgPolylineColor : UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.0)
    
    func addPointsOnMap(points: String) {
        path = GMSPath.init(fromEncodedPath: points)!
        polyline = GMSPolyline.init(path: path)
        polyline.strokeWidth = 3
        polyline.strokeColor = bgPolylineColor  // UIColor(displayP3Red: 0, green: 97/255, blue: 112/255, alpha: 255/255)
        polyline.map = self.mapView
        
        var bounds = GMSCoordinateBounds()
        for index in 1 ... (path.count().toInt) {
            bounds = bounds.includingCoordinate(path.coordinate(at: UInt(index)))

        }
        
        mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 50.0))
        
        bgPolylineColor = UIColor(red: 0, green: 154/255, blue: 169/255, alpha: 1.0)
        self.timer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(animatePolylinePath), userInfo: nil, repeats: true)
    }
    
    @objc func animatePolylinePath() {
        if (self.i < self.path.count()) {
            
            self.animationPath.add(self.path.coordinate(at: self.i))
            self.animationPolyline.path = self.animationPath
            self.animationPolyline.strokeColor = UIColor(displayP3Red: 0, green: 97/255, blue: 112/255, alpha: 255/255)
            self.animationPolyline.strokeWidth = 4
            self.animationPolyline.map = self.mapView
            self.i += 1
        }
        else if self.i == self.path.count() {
            timer.invalidate()
            self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(animatePolylinePath), userInfo: nil, repeats: true)
            self.i += 1
            
            //self.i = 0
            self.animationPath = GMSMutablePath()
            self.animationPolyline.map = nil
            polyline.strokeColor = bgPolylineColor
        }
        else {
            
                self.i = 0

            timer.invalidate()
            self.timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(animatePolylinePath), userInfo: nil, repeats: true)
        }
    }
    
    
    
    // MARK: - View Model Delegate
    func hintForPickup() -> String {
        return pickupHint
    }
//    func pickUpAdd() -> KTGeoLocation? {
//
//        return pickupAddress
//    }
//
//    func dropOffAdd() -> KTGeoLocation? {
//
//        return droffAddress
//    }
    
    func setPickUp(pick: String?) {
        
        guard pick != nil else {
            return
        }
        self.btnPickupAddress.setTitle(pick, for: UIControlState.normal)
    }
    
    func setDropOff(drop: String?) {
        
        guard drop != nil else {
            return
        }
        
        self.btnDropoffAddress.setTitle(drop, for: UIControlState.normal)
    }
    
    func setPickDate(date: String) {
        btnPickDate.setTitle(date, for: UIControlState.normal)
    }
}

typealias CarouselDatasource = KTCreateBookingViewController
extension CarouselDatasource: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (viewModel as! KTCreateBookingViewModel).numberOfRowsVType()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        if let sTypeCell = cell as? KTServiceCardCell {
            sTypeCell.lblServiceType.text = (viewModel as! KTCreateBookingViewModel).sTypeTitle(forIndex: indexPath.row)
            
            sTypeCell.lblBaseFare.text = (viewModel as! KTCreateBookingViewModel).sTypeBaseFare(forIndex: indexPath.row) + "QR"
            sTypeCell.imgBg.image = (viewModel as! KTCreateBookingViewModel).sTypeBackgroundImage(forIndex: indexPath.row)
            sTypeCell.imgVehicleType.image = (viewModel as! KTCreateBookingViewModel).sTypeVehicleImage(forIndex: indexPath.row)
        }
        
        return cell
    }
}

typealias CarouselDelegate = KTCreateBookingViewController
extension CarouselDelegate: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        carousel.didScroll()
        
        guard (carousel.currentCenterCellIndex?.row) != nil else { return }
        (viewModel as! KTCreateBookingViewModel).vTypeViewScroll(currentIdx: carousel.currentCenterCellIndex!.row)
    }
}

extension UInt {
    /// SwiftExtensionKit
    var toInt: Int { return Int(self) }
}
