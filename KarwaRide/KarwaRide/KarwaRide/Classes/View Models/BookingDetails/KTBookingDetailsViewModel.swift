//
//  KTBookingDetailsViewModel.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 3/15/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
import CoreLocation

protocol KTBookingDetailsViewModelDelegate {
    func initializeMap(location : CLLocationCoordinate2D)
    func showCurrentLocationDot(show: Bool)
    func showVTrackMarker(vTrack: VehicleTrack)
}

class KTBookingDetailsViewModel: KTBaseViewModel {

    var booking : KTBooking?
    var del : KTBookingDetailsViewModelDelegate?
    override func viewDidLoad() {
        del = self.delegate as? KTBookingDetailsViewModelDelegate
        initializeViewWRTBookingStatus()
    }
    
    func initializeViewWRTBookingStatus() {
    
        //Check for booking == nil
        guard let _ = booking else {
            return
        }
        
        updateMap()
        
    }
    
    
    
    
    //MARK:- Map
    
    
    func updateMap() {
        
        del?.initializeMap(location: CLLocationCoordinate2D(latitude: (booking?.pickupLat)!,longitude: (booking?.pickupLon)!))
        del?.showCurrentLocationDot(show: true)
        
        switch booking?.bookingStatus {
        case BookingStatus.ARRIVED.rawValue?, BookingStatus.CONFIRMED.rawValue?:
            fetchTaxiForTracking()
        default:
            print("Defaul case")
        }
        
    }
    
    func fetchTaxiForTracking() {
        KTBookingManager().trackVechicle(jobId: (booking?.bookingId)!,vehicleNumber: (booking?.vehicleNo)!, completion: {
            (status, response) in
            
            let vtrack : VehicleTrack = self.parseVehicleTrack(track: response)
            self.del?.showVTrackMarker(vTrack: vtrack)
        })
    }
    
    func parseVehicleTrack(track rtrack : [AnyHashable:Any]) -> VehicleTrack {
        
        let track : VehicleTrack = VehicleTrack()
        //track.vehicleNo = rtrack["VehicleNo"] as! String
        track.position = CLLocationCoordinate2D(latitude: (rtrack["Lat"] as? CLLocationDegrees)!, longitude: (rtrack["Lon"] as? CLLocationDegrees)!)
        //track.vehicleType = rtrack["VehicleType"] as! Int
        track.bearing = rtrack["Bearing"] as! Float
        track.trackType = VehicleTrackType.vehicle
        return track
    }
    
    func imgForTrackMarker() -> UIImage {
        
        var img : UIImage?
        switch booking?.vehicleType  {
            case VehicleType.KTAiportTaxi.rawValue?, VehicleType.KTAirportSpare.rawValue?, VehicleType.KTCityTaxi.rawValue?,VehicleType.KTSpecialNeedTaxi.rawValue?,VehicleType.KTAiport7Seater.rawValue? :
                img = UIImage(named:"BookingMapTaxiIco")
        
            case VehicleType.KTStandardLimo.rawValue?:
                    img = UIImage(named: "BookingMapStandardIco")
            case VehicleType.KTBusinessLimo.rawValue?:
                img = UIImage(named: "BookingMapBusinessIco")
            
            case VehicleType.KTLuxuryLimo.rawValue?:
                img = UIImage(named: "BookingMapLuxuryIco")
            default:
                img = UIImage(named:"BookingMapTaxiIco")
        }
        return img!
    }
    
}
