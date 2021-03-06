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
    func geoLocation(forLocation location:CLLocationCoordinate2D ) -> KTGeoLocation {
        let loc : KTGeoLocation = KTGeoLocation.obj(withValue: -1, forAttrib: "locationId", inContext: NSManagedObjectContext.mr_default()) as! KTGeoLocation
        loc.name = "Unknown"//String(format: "%f-%f",location.latitude,location.longitude )
        loc.area = "Unknown"//String(format: "%f-%f",location.latitude,location.longitude )
        //loc.locationId = -1
        loc.latitude = location.latitude
        loc.longitude = location.longitude
        return loc
    }
    
    func geoLocation(forLocationId locationId: Int32) -> KTGeoLocation? {
        guard locationId > 0 else {
            return nil
        }
        let predicate : NSPredicate = NSPredicate(format: "locationId == %d", locationId)
        let geoLocation = KTGeoLocation.mr_findFirst(with: predicate)
        return geoLocation
        
    }
    
    func geoLocaiton(forLocationId locationId: Int32, latitude: Double, longitude: Double, name: String) -> KTGeoLocation {
        var location : KTGeoLocation? = geoLocation(forLocationId: locationId)
        if location == nil {
            location = KTGeoLocation.obj(withValue: locationId, forAttrib: "locationId", inContext: NSManagedObjectContext.mr_default()) as? KTGeoLocation
            location?.name = name
            location?.area = name
            location?.latitude = latitude
            location?.longitude = longitude
        }
        return location!
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
        address(fromUrl: Constants.APIURL.getAllAddress, forParam: param, completion: completionBlock)
        
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
                                                Constants.ResponseAPIKey.Message : "please_dialog_msg_went_wrong".localized() as Any]
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
    
    public func saveGeoLocation(location: [AnyHashable:Any],context localContext: NSManagedObjectContext) -> KTGeoLocation{
        
        let loc : KTGeoLocation = KTGeoLocation.obj(withValue: location[Constants.GeoLocationResponseAPIKey.LocationId] as! Int32, forAttrib: "locationId", inContext: localContext) as! KTGeoLocation
        
        loc.latitude = location[Constants.GeoLocationResponseAPIKey.Latitude] as! Double
        loc.longitude = location[Constants.GeoLocationResponseAPIKey.Longitude] as! Double
        loc.area = location[Constants.GeoLocationResponseAPIKey.Area] as? String
        loc.name = location[Constants.GeoLocationResponseAPIKey.Name] as? String
        if(loc.type != geoLocationType.Home.rawValue && loc.type != geoLocationType.Work.rawValue) {
            if(location[Constants.GeoLocationResponseAPIKey.LocationType] != nil){
                loc.type = location[Constants.GeoLocationResponseAPIKey.LocationType] as! Int32
            }
            else{
                loc.type = geoLocationType.Unknown.rawValue
            }
        }
        // TODO: Add parser for type
        return loc
    }
    
    func removeType(forType type: geoLocationType){
        
        let predicate : NSPredicate = NSPredicate(format: "type == %d", type.rawValue)
        for loc in (KTGeoLocation.mr_findAll(with: predicate) as? [KTGeoLocation])! {
            loc.type = geoLocationType.Unknown.rawValue
        }
        do {
            
            try NSManagedObjectContext.mr_default().save()
        }
        catch _{
            
            print("Unable to save")
        }
    }
    
    func allGeoLocations() -> [KTGeoLocation]? {
        
        let predicate : NSPredicate = NSPredicate(format: "locationId != -1")
        return KTGeoLocation.mr_findAll(with: predicate) as? [KTGeoLocation]
        //return KTGeoLocation.mr_findAll() as? [KTGeoLocation]
    }
    
    
    
}
