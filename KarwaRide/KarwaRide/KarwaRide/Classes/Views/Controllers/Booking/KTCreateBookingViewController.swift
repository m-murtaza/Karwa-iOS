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

class KTServiceCardCell: ScalingCarouselCell {
    
    @IBOutlet weak var lblServiceType : UILabel!
    @IBOutlet weak var lblBaseFare : UILabel!
    @IBOutlet weak var imgBg : UIImageView!
    @IBOutlet weak var imgVehicleType : UIImageView!
}

class KTCreateBookingViewController: KTBaseDrawerRootViewController, KTCreateBookingViewModelDelegate {
    
    @IBOutlet weak var mapView : GMSMapView!
    @IBOutlet weak var carousel: ScalingCarouselView!
    @IBOutlet weak var btnPickupAddress: UIButton!
    @IBOutlet weak var btnDropoffAddress: UIButton!
    @IBOutlet weak var btnPickDate: UIButton!
    @IBOutlet weak var btnRevealBtn : UIButton!
    
    @IBOutlet weak var constraintBtnRequestBookingHeight : NSLayoutConstraint!
    @IBOutlet weak var constraintBtnRequestBookingBottomSpace : NSLayoutConstraint!
    
    public var pickupAddress : KTGeoLocation?
    public var droffAddress : KTGeoLocation?
    public var pickupHint : String = ""
    
    
    
    override func viewDidLoad() {
        viewModel = KTCreateBookingViewModel(del:self)
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addMap()
        
        self.navigationItem.hidesBackButton = true;
        
        self.btnRevealBtn.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)), for: .touchUpInside)
        
        //button.addTarget(self, action: #selector(pressButton(button:)), for: .touchUpInside)
        
        //revealBarButton.target = self.revealViewController()
        //revealBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.carousel!.scrollToItem(at: IndexPath(row: (viewModel as! KTCreateBookingViewModel).maxCarouselIdx(), section: 0), at: UICollectionViewScrollPosition.right, animated: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){
            self.carousel!.scrollToItem(at: IndexPath(row: 0, section: 0), at: UICollectionViewScrollPosition.right, animated: true)
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    
    
    @IBAction func btnRequestBooking(_ sender: Any) {
        
        //self.carousel!.scrollToItem(at: IndexPath(row: 3, section: 0), at: UICollectionViewScrollPosition.right, animated: true)
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
        constraintBtnRequestBookingHeight.constant = 50
        constraintBtnRequestBookingBottomSpace.constant = 50
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueBookingToAddresspicker" {
            let destination : KTAddressPickerViewController = segue.destination as! KTAddressPickerViewController
            destination.previousView = self
            (viewModel as! KTCreateBookingViewModel).prepareToMoveAddressPicker(addPickerController: destination )
        }
    }
    
    //MARK: - Location & Maps
    private func addMap() {

        let camera = GMSCameraPosition.camera(withLatitude: 25.343899, longitude: 51.511294, zoom: 14.0)
        self.mapView.setMinZoom(15, maxZoom: 500)
        self.mapView!.isMyLocationEnabled = true
        mapView.tintColor = UIColor.red
        
        self.mapView.camera = camera;
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
        //return
        //Update map
        if !(viewModel as! KTCreateBookingViewModel).isVehicleNearBy() {
            let camera = GMSCameraPosition.camera(withLatitude: (location.coordinate.latitude), longitude: (location.coordinate.longitude), zoom: 17.0)
         
            self.mapView?.animate(to: camera)
        }
        
        //self.mapView?.blu
         /*}
         else if gmsMarker.count > 0{
         for i in 0...gmsMarker.count-1
         {
         if gmsMarker[i].zIndex == 1000 {
         gmsMarker.remove(at: i)
         break
         }
         }
         
         let marker = GMSMarker()
         marker.position = location.coordinate
         //marker.map = self.mapView
         marker.zIndex = 1000
         
         gmsMarker.append(marker)
         
         self.focusMapToShowAllMarkers(gsmMarker: gmsMarker)
         }*/
    }
    
    var gmsMarker : Array<GMSMarker> = Array()
    func addMarkerOnMap(vTrack: [VehicleTrack]) {
        mapView.clear()
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

        if gsmMarker.count > 1 {
        
            var bounds = GMSCoordinateBounds()
            for marker: GMSMarker in gsmMarker {
                bounds = bounds.includingCoordinate(marker.position)
            }
            
            var padding = 275.0
            if bounds.northEast.distance(from: bounds.southWest) < 5000 {
             
                print("Bound area : \(bounds.northEast.distance(from: bounds.southWest))")
                padding = 5000.0
            }
            
            let update = GMSCameraUpdate.fit(bounds, withPadding: CGFloat(padding))
            mapView.animate(with: update)
            }
    }
    
    // MARK: - View Model Delegate
    func hintForPickup() -> String {
        return pickupHint
    }
    func pickUpAdd() -> KTGeoLocation? {
       
        return pickupAddress
    }
    
    func dropOffAdd() -> KTGeoLocation? {
        
        return droffAddress
    }
    
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


extension CLLocationCoordinate2D {
    //distance in meters, as explained in CLLoactionDistance definition
    func distance(from: CLLocationCoordinate2D) -> CLLocationDistance {
        let destination=CLLocation(latitude:from.latitude,longitude:from.longitude)
        return CLLocation(latitude: latitude, longitude: longitude).distance(from: destination)
    }
}
