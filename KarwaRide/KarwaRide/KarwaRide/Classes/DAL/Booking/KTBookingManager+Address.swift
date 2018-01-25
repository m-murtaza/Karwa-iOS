//
//  KTBookingManager+Address.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 1/24/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import CoreLocation
import MagicalRecord

extension KTBookingManager
{
    func addressForLocation(location: CLLocationCoordinate2D,completion completionBlock: @escaping KTDALCompletionBlock ) {
        
        let param : NSDictionary = [Constants.AddressPickParams.Lat: location.latitude,
                                    Constants.AddressPickParams.Lon: location.longitude]
        self.get(url: Constants.APIURL.AddressPick, param: param as? [String : Any], completion: completionBlock, success: {
            (responseData,cBlock) in
            print(responseData)
            
            self.removeUnnecessaryLocations()
            self.saveGeoLocations(locations: responseData[Constants.ResponseAPIKey.Data] as! [Any],completion:{(success:Bool) -> Void in
                if success {
                    completionBlock(Constants.APIResponseStatus.SUCCESS, [:])  //No need to send data, UI need to fetch data as per requirnment.
                }
                else {
                    let error : NSDictionary = [Constants.ResponseAPIKey.Title : "Ops!" as Any,
                                                Constants.ResponseAPIKey.Message : "Something went wrong" as Any]
                    completionBlock(Constants.APIResponseStatus.FAILED_DB,error as! [AnyHashable : Any])
                }
                
            })
            //cBlock(Constants.APIResponseStatus.SUCCESS,responseData)
        })
    }
    
    private func removeUnnecessaryLocations() {
        // TODO: Need to add code to remove specific type of locaiton.
    }
    
    
    private func saveGeoLocations(locations:[Any],completion: @escaping (Bool) -> Void) {
        MagicalRecord.save({(_ localContext: NSManagedObjectContext) -> Void in
           for location in locations {
                self.saveGeoLocation(location:location as! [AnyHashable : Any],context: localContext)
            }
        }, completion: {(_ success: Bool, _ error: Error?) -> Void in
            if success == false && error != nil {
                completion(false)
            }
            else{
                completion(true)
            }
        })
    }
    
    private func saveGeoLocation(location: [AnyHashable:Any],context localContext: NSManagedObjectContext) {

        let loc : KTGeoLocation = KTGeoLocation.obj(withValue: location[Constants.AddressPickResponseAPIKey.LocationId] as! Int32, forAttrib: "locationId", inContext: localContext) as! KTGeoLocation
        
                loc.latitude = location[Constants.AddressPickResponseAPIKey.Latitude] as! Double
                loc.longitude = location[Constants.AddressPickResponseAPIKey.Longitude] as! Double
                loc.area = location[Constants.AddressPickResponseAPIKey.Area] as? String
                loc.name = location[Constants.AddressPickResponseAPIKey.Name] as? String
                // TODO: Add parser for type
    }
    
    func VehicleTypes() -> [KTVehicleType]? {
        var vTypes : [KTVehicleType] = []
        
        vTypes = (KTVehicleType.mr_findAll() as? [KTVehicleType])!
        return vTypes.sorted(by: { (this, that) -> Bool in
            this.typeSortOrder < that.typeSortOrder
        })
    }
    
    func allGeoLocations() -> [KTGeoLocation]? {
        return KTGeoLocation.mr_findAll() as? [KTGeoLocation]
    }
    
    
    
}
