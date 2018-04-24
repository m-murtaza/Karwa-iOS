//
//  KTBookmarkManager.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 3/7/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
import CoreLocation

let HOME_GEOLOCATION_ID : Int32 = -101
let WORK_GEOLOCATION_ID : Int32 = -102

class KTBookmarkManager: KTDALManager {

    func fetchHomeWork(completion completionBlock:@escaping KTDALCompletionBlock) {
    
        self.get(url: Constants.APIURL.GetBookmark, param: nil, completion: completionBlock) { (responseData,cBlock) in
            print(responseData)
            
            self.addUpdateHomeWork(responseData: responseData[Constants.ResponseAPIKey.Data] as! [Any])
            cBlock(Constants.APIResponseStatus.SUCCESS,responseData)
        }
    }
    
    func addUpdateHomeWork(responseData : [Any]){
        for  case let bookmark as [AnyHashable: Any] in responseData {
            addupdate(bookmark: bookmark)
        }
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
        
        //var home = getHome()
        //var work = getWork()
    }
    
    func addupdate(bookmark : [AnyHashable: Any]) {
        if bookmark[Constants.BookmarkResponseAPIKey.Name] != nil {
            var bmark : KTBookmark? = getBookmark(with: bookmark[Constants.BookmarkResponseAPIKey.Name] as! String)
            if bmark == nil {
                
                bmark = KTBookmark.mr_createEntity(in: NSManagedObjectContext.mr_default())
            }
            bmark?.name = bookmark[Constants.BookmarkResponseAPIKey.Name] as? String
            bmark?.address = bookmark[Constants.BookmarkResponseAPIKey.Address] as? String
            if bmark?.address == nil || bmark?.address == "" {
                bmark?.address = "Unknown"
            }
            bmark?.latitude = (bookmark[Constants.BookmarkResponseAPIKey.Latitude] as? Double)!
            bmark?.longitude = (bookmark[Constants.BookmarkResponseAPIKey.Longitude] as? Double)!
            
            //Old implementation.
            /*guard var _ = (bookmark[Constants.BookmarkResponseAPIKey.Place]! as AnyObject).count  else {
                return
            }*/
            var geoLocation: KTGeoLocation?
            if let _ = (bookmark[Constants.BookmarkResponseAPIKey.Place]! as AnyObject).count {
                geoLocation = KTBookingManager().saveGeoLocation(location: bookmark[Constants.BookmarkResponseAPIKey.Place] as! [AnyHashable : Any], context: NSManagedObjectContext.mr_default())
            }
            else {
                geoLocation = createGeoLocationFromBookmark(bookmark: bmark!)
            }
            bmark?.bookmarkToGeoLocation = geoLocation!
            geoLocation!.geolocationToBookmark = bmark
        }
    }
    
    func createGeoLocationFromBookmark(bookmark : KTBookmark) -> KTGeoLocation {
        
        var geoLocationID : Int32 = HOME_GEOLOCATION_ID
        var geoLocType : geoLocationType = geoLocationType.Home
        
        if bookmark.name == Constants.BookmarkName.Work {
            geoLocationID = WORK_GEOLOCATION_ID
            geoLocType = geoLocationType.Work
        }
        
        let geoLocation : KTGeoLocation = KTGeoLocation.obj(withValue: geoLocationID , forAttrib: "locationId", inContext: NSManagedObjectContext.mr_default()) as! KTGeoLocation
        
        geoLocation.name = bookmark.name
        geoLocation.area = bookmark.address
        geoLocation.latitude = bookmark.latitude
        geoLocation.longitude = bookmark.longitude
        geoLocation.type = geoLocType.rawValue
        
        return geoLocation
    }
    
    func getBookmark(with name: String) -> KTBookmark? {
        
        let predicate : NSPredicate = NSPredicate(format: "name = %@",name)
        return fetchBookmark(with: predicate)
    }
    
    func getHome() -> KTBookmark? {
        
        let predicate : NSPredicate = NSPredicate(format: "name = %@",Constants.BookmarkName.Home)
        return fetchBookmark(with: predicate)
    }
    
    func getWork() -> KTBookmark? {
        
        let predicate : NSPredicate = NSPredicate(format: "name = %@",Constants.BookmarkName.Work)
        return fetchBookmark(with: predicate)
    }
    
    func fetchBookmark(with predicate: NSPredicate) -> KTBookmark? {
    
        let bookmark = KTBookmark.mr_findFirst(with: predicate, in: NSManagedObjectContext.mr_default())
        
        return bookmark
    }
    
    
    //Mark: - Set home work
    func updateHome(withLocation loc:KTGeoLocation, completion completionBlock:@escaping KTDALCompletionBlock) {
        let url: String = Constants.APIURL.SetHomeBookmark
        let param : [String:Any] = [Constants.UpdateBookmarkParam.LocationID:loc.locationId]
        
        updateBookmark(url: url, param: param) { (status, response) in
            if status == Constants.APIResponseStatus.SUCCESS {
                
                self.saveHome(withLocation: loc)
                
            }
            completionBlock(status,response)
        }
    }
    
    func updateHome(withCoordinate loc: CLLocationCoordinate2D, completion completionBlock:@escaping KTDALCompletionBlock) {
        
        let url: String = Constants.APIURL.SetHomeBookmark
        let param : [String:Any] = [Constants.UpdateBookmarkParam.Latitude:loc.latitude,
                                    Constants.UpdateBookmarkParam.Longitude:loc.longitude]
        updateBookmark(url: url, param: param) { (status, response) in
            if status == Constants.APIResponseStatus.SUCCESS {
                
                self.saveHome(withCoordinate: loc)
                
            }
            completionBlock(status,response)
        }
    }
    
    func updateWork(withCoordinate loc: CLLocationCoordinate2D, completion completionBlock:@escaping KTDALCompletionBlock) {
        
        let url: String = Constants.APIURL.SetWorkBookmark
        let param : [String:Any] = [Constants.UpdateBookmarkParam.Latitude:loc.latitude,
                                    Constants.UpdateBookmarkParam.Longitude:loc.longitude]
        updateBookmark(url: url, param: param) { (status, response) in
            if status == Constants.APIResponseStatus.SUCCESS {
                
                self.saveHome(withCoordinate: loc)
                
            }
            completionBlock(status,response)
        }
    }
    
    func updateWork(withLocation loc:KTGeoLocation, completion completionBlock:@escaping KTDALCompletionBlock) {
        let url: String = Constants.APIURL.SetWorkBookmark
        let param : [String:Any] = [Constants.UpdateBookmarkParam.LocationID:loc.locationId]
        
        updateBookmark(url: url, param: param) { (status, response) in
            if status == Constants.APIResponseStatus.SUCCESS {
                
                self.saveWork(withLocation: loc)
                
            }
            completionBlock(status,response)
        }
    }
    
    private func updateBookmark(url:String, param: [String:Any], completion completionBlock:@escaping KTDALCompletionBlock) {
        self.post(url: url, param: param, completion: completionBlock) { (response, cBlock) in
            
            cBlock(Constants.APIResponseStatus.SUCCESS, response)
        }
    }
    
    private func saveHome(withCoordinate loc: CLLocationCoordinate2D) {
        
        saveBookmark(withCoordinate: loc, name: Constants.BookmarkName.Home)
    }
    
    private func saveWork(withCoordinate loc: CLLocationCoordinate2D) {
        
        saveBookmark(withCoordinate: loc, name: Constants.BookmarkName.Work)
    }
    
    private func saveBookmark(withCoordinate loc: CLLocationCoordinate2D, name: String) {
        
        var bmark : KTBookmark? = getBookmark(with: name)
        if bmark == nil {
            
            bmark = KTBookmark.mr_createEntity(in: NSManagedObjectContext.mr_default())
        }
        bmark?.name = name
        bmark?.address = "Unknown"
        bmark?.latitude = loc.latitude
        bmark?.longitude = loc.longitude
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
        
    }
    private func saveHome(withLocation loc:KTGeoLocation) {
        
        saveBookmark(withLocaiton: loc, name: Constants.BookmarkName.Home)
    }
    
    private func saveWork(withLocation loc:KTGeoLocation) {
        
        saveBookmark(withLocaiton: loc, name: Constants.BookmarkName.Work)
    }
    
    private func saveBookmark(withLocaiton loc:KTGeoLocation, name: String) {
        var bmark : KTBookmark? = getBookmark(with: name)
        if bmark == nil {
            
            bmark = KTBookmark.mr_createEntity(in: NSManagedObjectContext.mr_default())
        }
        bmark?.name = name
        bmark?.address = loc.name
        if bmark?.address == nil || bmark?.address == "" {
            bmark?.address = "Unknown"
        }
        bmark?.latitude = loc.latitude
        bmark?.longitude = loc.longitude
        bmark?.bookmarkToGeoLocation = loc
        loc.geolocationToBookmark = bmark
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
    }
    
}
