//
//  KTCreateBookingViewModel.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 1/16/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
import CoreLocation


protocol KTCreateBookingViewModelDelegate: KTViewModelDelegate {
    func updateLocationInMap(location:CLLocation)
    func addMarkerOnMap(vTrack:Array<VehicleTrack>)
}
class KTCreateBookingViewModel: KTBaseViewModel {
    
    var vehicleType : VehicleType = VehicleType.KTBusinessLimo
    var vechicleTypes : [KTVehicleType]?
    
    override func viewDidLoad() {
        self.fetchVechicleTypes()
        KTLocationManager.sharedInstance.start()
        NotificationCenter.default.addObserver(self, selector: #selector(self.LocationManagerLocaitonUpdate(notification:)), name: Notification.Name("LocationManagerNotificationIdentifier"), object: nil)
    }
    
    //MARK:-  Vehicle Types
    private func fetchVechicleTypes() {
        let vTypeManager: KTVehicleTypeManager = KTVehicleTypeManager()
        vechicleTypes = vTypeManager.VehicleTypes()
    }
    
    func numberOfRowsVType() -> Int {
        guard (vechicleTypes != nil) else {
            return 0;
        }
        return (vechicleTypes?.count)!
    }
    func vTypeTitle(forIndex idx: Int) -> String {
        let vType : KTVehicleType = vechicleTypes![idx]
        return vType.typeName!
    }
    
    func vTypeBaseFare(forIndex idx: Int) -> String {
        let vType : KTVehicleType = vechicleTypes![idx]
        return String(vType.typeBaseFare)
    }
    //MARK:- Location manager
    @objc func LocationManagerLocaitonUpdate(notification: Notification){
        
        let location : CLLocation = notification.userInfo!["location"] as! CLLocation
        (self.delegate as! KTCreateBookingViewModelDelegate).updateLocationInMap(location: location)
        
        self.fetchVehiclesNearCordinates(location: location)
    }
    
    var oneTimeCheck : Bool = true
    func fetchVehiclesNearCordinates(location:CLLocation) {
        
        if oneTimeCheck {
            //Righ now allow only one time.
            oneTimeCheck = false
            KTBookingManager.init().vehiclesNearCordinate(coordinate: location.coordinate, vehicleType: VehicleType(rawValue: 50)!, completion:{
            (status,response) in
                let vTrack: Array<VehicleTrack> = self.parseVehicleTrack(response)
                (self.delegate as! KTCreateBookingViewModelDelegate).addMarkerOnMap(vTrack: vTrack)
            })
        }
    }
    
    func parseVehicleTrack(_ respons: [AnyHashable: Any]) -> Array<VehicleTrack> {
        var vTrack: Array<VehicleTrack> = Array()
        
        let responseArray: Array<[AnyHashable: Any]> = respons[Constants.ResponseAPIKey.Data] as! Array<[AnyHashable: Any]>
        //respons[Constants.ResponseAPIKey.Data] as! [AnyHashable: Any].forEach { track in
        responseArray.forEach { rtrack in
            let track : VehicleTrack = VehicleTrack()
            track.vehicleNo = rtrack["VehicleNo"] as? String
            track.position = CLLocationCoordinate2D(latitude: (rtrack["Lat"] as? CLLocationDegrees)!, longitude: (rtrack["Lon"] as? CLLocationDegrees)!)
            track.vehicleType = rtrack["VehicleType"] as? Int
            track.bearing = rtrack["Bearing"] as? Float
            vTrack.append(track)
        }
        return vTrack
    }
}


