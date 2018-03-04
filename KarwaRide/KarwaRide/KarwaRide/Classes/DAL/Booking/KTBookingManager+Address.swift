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
    func goeLocation(forLocation location:CLLocationCoordinate2D ) -> KTGeoLocation {
        let loc : KTGeoLocation = KTGeoLocation.mr_createEntity()!
        loc.name = String(format: "%f-%f",location.latitude,location.longitude )
        loc.area = String(format: "%f-%f",location.latitude,location.longitude )
        loc.locationId = -1
        loc.latitude = location.latitude
        loc.longitude = location.longitude
        return loc
    }
    func address(forLocation location: CLLocationCoordinate2D,Limit limit: Int ,completion completionBlock: @escaping KTDALCompletionBlock ) {
    
        let param : NSDictionary = [Constants.AddressPickParams.Lat: location.latitude,
                                    Constants.AddressPickParams.Lon: location.longitude,
                                    Constants.AddressPickParams.Limit: limit]
        address(fromUrl: Constants.APIURL.AddressPickViaGeoCode, forParam: param, completion: completionBlock)
    }
    
    func address(forLocation location: CLLocationCoordinate2D,completion completionBlock: @escaping KTDALCompletionBlock ) {
        
        let param : NSDictionary = [Constants.AddressPickParams.Lat: location.latitude,
                                    Constants.AddressPickParams.Lon: location.longitude]
        address(fromUrl: Constants.APIURL.AddressPickViaGeoCode, forParam: param, completion: completionBlock)
        
    }
    
    func address(forSearch query: String,completion conpletionBlock: @escaping KTDALCompletionBlock) {
        
        let param : NSDictionary = [Constants.AddressPickParams.Address: query]
        address(fromUrl: Constants.APIURL.AddressPickViaSearch, forParam:param,completion: conpletionBlock)
    }
    
    func address(fromUrl url:String, forParam param:NSDictionary,completion completionBlock: @escaping KTDALCompletionBlock) {
        
        self.get(url: url, param: param as? [String : Any], completion: completionBlock, success: {
            (responseData,cBlock) in
            
                self.removeUnnecessaryLocations()
                self.saveGeoLocations(locations: responseData[Constants.ResponseAPIKey.Data] as! [Any],completion:{(success:Bool,geoLocations:[KTGeoLocation] ) -> Void in
                    if success {
                        completionBlock(Constants.APIResponseStatus.SUCCESS, [Constants.ResponseAPIKey.Data:geoLocations])  //No need to send data, UI need to fetch data as per requirnment.
                    }
                    else {
                        let error : NSDictionary = [Constants.ResponseAPIKey.Title : "Ops!" as Any,
                                                    Constants.ResponseAPIKey.Message : "Something went wrong" as Any]
                        completionBlock(Constants.APIResponseStatus.FAILED_DB,error as! [AnyHashable : Any])
                    }
                })
        })
    }
    
    private func removeUnnecessaryLocations() {
        // TODO: Need to add code to remove specific type of locaiton.
    }
    
    private func saveGeoLocations(locations:[Any],completion: @escaping (Bool,[KTGeoLocation]) -> Void) {
        
        do {
        
            var geolocations : [KTGeoLocation] = []
            let localContext : NSManagedObjectContext = NSManagedObjectContext.mr_default()
            for location in locations {
            
                geolocations.append(self.saveGeoLocation(location:location as! [AnyHashable : Any],context: localContext))
            }
            
            try NSManagedObjectContext.mr_default().save()
            completion(true,geolocations)
        }
        catch _{
            
            completion(false,[])
        }
    }
    
    private func saveGeoLocation(location: [AnyHashable:Any],context localContext: NSManagedObjectContext) -> KTGeoLocation{
        
        let loc : KTGeoLocation = KTGeoLocation.obj(withValue: location[Constants.AddressPickResponseAPIKey.LocationId] as! Int32, forAttrib: "locationId", inContext: localContext) as! KTGeoLocation
        
                loc.latitude = location[Constants.AddressPickResponseAPIKey.Latitude] as! Double
                loc.longitude = location[Constants.AddressPickResponseAPIKey.Longitude] as! Double
                loc.area = location[Constants.AddressPickResponseAPIKey.Area] as? String
                loc.name = location[Constants.AddressPickResponseAPIKey.Name] as? String
                // TODO: Add parser for type
        return loc
    }
    
    func allGeoLocations() -> [KTGeoLocation]? {
        
        return KTGeoLocation.mr_findAll() as? [KTGeoLocation]
    }
    
    
    
}
