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
    func updateCurrentAddress(addressName:String)
    func pickUpAdd() -> KTGeoLocation?
    func dropOffAdd() -> KTGeoLocation?
    func setPickUp(pick: String?)
    func setDropOff(drop: String?)
}
class KTCreateBookingViewModel: KTBaseViewModel {
    
    var vehicleType : VehicleType = VehicleType.KTBusinessLimo
    var vechicleTypes : [KTVehicleType]?
    private var pickUpAddress : KTGeoLocation?
    private var dropOffAddress : KTGeoLocation?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.fetchVechicleTypes()
        KTLocationManager.sharedInstance.start()
        
    }
    
    override func viewWillAppear() {
        
        super.viewWillAppear()
        NotificationCenter.default.addObserver(self, selector: #selector(self.LocationManagerLocaitonUpdate(notification:)), name: Notification.Name("LocationManagerNotificationIdentifier"), object: nil)
        
        pickUpAddress = (delegate as! KTCreateBookingViewModelDelegate).pickUpAdd()
        dropOffAddress = (delegate as! KTCreateBookingViewModelDelegate).dropOffAdd()
        
        if pickUpAddress != nil {
            
            (delegate as! KTCreateBookingViewModelDelegate).setPickUp(pick: pickUpAddress?.name)
        }
        
        if(dropOffAddress != nil) {
            
            (delegate as! KTCreateBookingViewModelDelegate).setDropOff(drop: dropOffAddress?.name)
        }
    }
    
    override func viewWillDisappear() {
        
        super.viewWillDisappear()
        NotificationCenter.default.removeObserver(self)
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
        //Show user Location on map
        (self.delegate as! KTCreateBookingViewModelDelegate).updateLocationInMap(location: location)
        
        //Fetch location name (from Server) for current location.
        self.fetchLocationName(forGeoCoordinate: location.coordinate)
        
        //Fetch Vehicles to show on map
        self.fetchVehiclesNearCordinates(location: location)
    }
    
    var oneTimeCheck : Bool = true
    private func fetchVehiclesNearCordinates(location:CLLocation) {
        
        if oneTimeCheck {
            //Righ now allow only one time.
            oneTimeCheck = false
            KTBookingManager.init().vehiclesNearCordinate(coordinate: location.coordinate, vehicleType: VehicleType(rawValue: 50)!, completion:{
            (status,response) in
                if status == Constants.APIResponseStatus.SUCCESS {
                    let vTrack: Array<VehicleTrack> = self.parseVehicleTrack(response)
                    (self.delegate as! KTCreateBookingViewModelDelegate).addMarkerOnMap(vTrack: vTrack)
                }
            })
        }
    }
    
    private func parseVehicleTrack(_ respons: [AnyHashable: Any]) -> Array<VehicleTrack> {
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
    
    
    private func fetchLocationName(forGeoCoordinate coordinate: CLLocationCoordinate2D) {
        
        KTBookingManager().address(forLocation: coordinate, Limit: 1) { (status, response) in
            if status == Constants.APIResponseStatus.SUCCESS && response[Constants.ResponseAPIKey.Data] != nil && (response[Constants.ResponseAPIKey.Data] as! [KTGeoLocation]).count > 0{
                
                self.pickUpAddress = (response[Constants.ResponseAPIKey.Data] as! [KTGeoLocation])[0]
                DispatchQueue.main.async {
                    
                    (self.delegate as! KTCreateBookingViewModelDelegate).updateCurrentAddress(addressName: (self.pickUpAddress?.name!)!)
                }
                
                
            }
        }
    }
    
    func prepareToMoveAddressPicker(addPickerController: KTAddressPickerViewController) {
        
        addPickerController.pickupAddress = pickUpAddress
    }
}


