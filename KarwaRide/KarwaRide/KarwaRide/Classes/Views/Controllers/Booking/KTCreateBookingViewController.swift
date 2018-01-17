//
//  KTCreateBookingViewController.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 1/16/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
import GoogleMaps

class KTCreateBookingViewController: KTBaseDrawerRootViewController, KTCreateBookingViewModelDelegate {
    let viewModel : KTCreateBookingViewModel = KTCreateBookingViewModel(del: self)
    @IBOutlet weak var mapView : GMSMapView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        viewModel.delegate = self
        
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
    
//    @objc func methodOfReceivedNotification(notification: Notification){
//        print(notification.userInfo!["location"] as Any)
//        let location : CLLocation = notification.userInfo!["location"] as! CLLocation
//        let camera = GMSCameraPosition.camera(withLatitude: (location.coordinate.latitude), longitude: (location.coordinate.longitude), zoom: 17.0)
//        
//        self.mapView?.animate(to: camera)
//        
//    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    //Mark: - View Model Delegate
    func updateLocationInMap(location: CLLocation) {
        
        //Update map
        let camera = GMSCameraPosition.camera(withLatitude: (location.coordinate.latitude), longitude: (location.coordinate.longitude), zoom: 17.0)
        
        self.mapView?.animate(to: camera)
    }
}
