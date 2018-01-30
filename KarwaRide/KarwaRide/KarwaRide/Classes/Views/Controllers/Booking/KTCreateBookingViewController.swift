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
    
    public var pickupAddress : KTGeoLocation?
    public var droffAddress : KTGeoLocation?
    
    override func viewDidLoad() {
        viewModel = KTCreateBookingViewModel(del:self)
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //viewModel?.viewDidLoad()
        let camera = GMSCameraPosition.camera(withLatitude: 25.343899,
                                                          longitude: 51.511294, zoom: 15)
        self.mapView.camera = camera;
        self.mapView!.isMyLocationEnabled = true
        self.navigationItem.hidesBackButton = true;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destination : KTAddressPickerViewController = segue.destination as! KTAddressPickerViewController
        destination.previousView = self
        (viewModel as! KTCreateBookingViewModel).prepareToMoveAddressPicker(addPickerController: destination )
    }


    //Mark: - View Model Delegate
    var allowReset : Bool = true
    func updateLocationInMap(location: CLLocation) {
        
        //Update map
        if allowReset {
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
        }
    }
    var gmsMarker : Array<GMSMarker> = Array()
    func addMarkerOnMap(vTrack: Array<VehicleTrack>) {
        
        vTrack.forEach { track in
            let marker = GMSMarker()
            marker.position = track.position!
            marker.map = self.mapView
            gmsMarker.append(marker)
        }
        self.focusMapToShowAllMarkers(gsmMarker: gmsMarker)
    }
    
    func focusMapToShowAllMarkers(gsmMarker : Array<GMSMarker>) {
        allowReset = false
        var bounds = GMSCoordinateBounds()
        for marker: GMSMarker in gsmMarker {
            bounds = bounds.includingCoordinate(marker.position)
        }
        let update = GMSCameraUpdate.fit(bounds, withPadding: 60)
        mapView.animate(with: update)
    }
    
    // MARK: - View Model Delegate
    func updateCurrentAddress(addressName: String) {
        btnPickupAddress.setTitle(addressName, for: UIControlState.normal)
        
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
    }
}
