//
//  KTBookmarkManager.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 3/7/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

class KTBookmarkManager: KTDALManager {

    func fetchHomeWork(completion completionBlock:@escaping KTDALCompletionBlock) {
    
        self.get(url: Constants.APIURL.GetBookMark, param: nil, completion: completionBlock) { (responseData,cBlock) in
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
            bmark?.latitude = (bookmark[Constants.BookmarkResponseAPIKey.Latitude] as? Double)!
            bmark?.longitude = (bookmark[Constants.BookmarkResponseAPIKey.Longitude] as? Double)!
            
            guard var _ = (bookmark[Constants.BookmarkResponseAPIKey.Place]! as AnyObject).count  else {
                return
            }
            
            let geoLocation: KTGeoLocation = KTBookingManager().saveGeoLocation(location: bookmark[Constants.BookmarkResponseAPIKey.Place] as! [AnyHashable : Any], context: NSManagedObjectContext.mr_default())
            bmark?.bookmarkToGeoLocation = geoLocation
        }
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
    
        var bookmark = KTBookmark.mr_findFirst(with: predicate, in: NSManagedObjectContext.mr_default())
        
        return bookmark
    }
    
}
