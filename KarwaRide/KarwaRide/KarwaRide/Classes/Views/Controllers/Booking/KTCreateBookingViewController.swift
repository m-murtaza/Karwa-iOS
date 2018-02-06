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

class Cell: ScalingCarouselCell {}

class KTCreateBookingViewController: KTBaseDrawerRootViewController, KTCreateBookingViewModelDelegate {
    
    @IBOutlet weak var mapView : GMSMapView!
    @IBOutlet weak var carousel: ScalingCarouselView!
    @IBOutlet weak var btnPickupAddress: UIButton!
    @IBOutlet weak var btnDropoffAddress: UIButton!
    @IBOutlet weak var btnPickDate: UIButton!
    
    public var pickupAddress : KTGeoLocation?
    public var droffAddress : KTGeoLocation?
    public var pickupHint : String = ""
    
    override func viewDidLoad() {
        viewModel = KTCreateBookingViewModel(del:self)
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addMap()
        
        self.navigationItem.hidesBackButton = true;
        
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
    
    func addMap() {
        
        /*let camera = GMSCameraPosition.camera(withLatitude: 25.343899,
                                              longitude: 51.511294, zoom: 15)
        
        self.mapView.camera = camera;
        
        self.mapView.setMinZoom(15, maxZoom: 500)
        self.mapView!.isMyLocationEnabled = true*/
        
        let camera = GMSCameraPosition.camera(withLatitude: 25.343899, longitude: 51.511294, zoom: 14.0)
        self.mapView.setMinZoom(15, maxZoom: 500)
        self.mapView!.isMyLocationEnabled = true
        
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
        
        //self.view = mapView
    }
    
    @IBAction func btnRequestBooking(_ sender: Any) {
        
        //self.carousel!.scrollToItem(at: IndexPath(row: 3, section: 0), at: UICollectionViewScrollPosition.right, animated: true)
        (viewModel as! KTCreateBookingViewModel).btnRequestBookingTapped()
    }
    func bookRide()  {
        (viewModel as! KTCreateBookingViewModel).bookRide()
    }
    
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
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueBookingToAddresspicker" {
            let destination : KTAddressPickerViewController = segue.destination as! KTAddressPickerViewController
            destination.previousView = self
            (viewModel as! KTCreateBookingViewModel).prepareToMoveAddressPicker(addPickerController: destination )
        }
    }
    
    //Mark: - View Model Delegate
    var allowReset : Bool = true
    func updateLocationInMap(location: CLLocation) {
        //return
        //Update map
        /*if allowReset {
            let camera = GMSCameraPosition.camera(withLatitude: (location.coordinate.latitude), longitude: (location.coordinate.longitude), zoom: 17.0)
            
            self.mapView?.animate(to: camera)
        }
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
            if !track.position.isZeroCoordinate  {
                let marker = GMSMarker()
                marker.position = track.position
                marker.map = self.mapView
                gmsMarker.append(marker)
            }
        }
        self.focusMapToShowAllMarkers(gsmMarker: gmsMarker)
    }
    
    func focusMapToShowAllMarkers(gsmMarker : Array<GMSMarker>) {
        allowReset = false
        var bounds = GMSCoordinateBounds()
        for marker: GMSMarker in gsmMarker {
            bounds = bounds.includingCoordinate(marker.position)
        }
        let update = GMSCameraUpdate.fit(bounds, withPadding: 275)
        //print(mapView.minZoom)
        mapView.animate(with: update)
    }
    
    // MARK: - View Model Delegate
    func updateCurrentAddress(addressName: String) {
        
        btnPickupAddress.setTitle(addressName, for: UIControlState.normal)
    }
    
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
        
        if let scalingCell = cell as? ScalingCarouselCell {
            let title: UILabel = scalingCell.mainView.viewWithTag(1001) as! UILabel
            title.text = (viewModel as! KTCreateBookingViewModel).vTypeTitle(forIndex: indexPath.row)
            
            let baseFare :UILabel = scalingCell.mainView.viewWithTag(1002) as! UILabel
            baseFare.text = (viewModel as! KTCreateBookingViewModel).vTypeBaseFare(forIndex: indexPath.row)
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
