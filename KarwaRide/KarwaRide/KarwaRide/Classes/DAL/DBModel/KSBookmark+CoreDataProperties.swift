//
//  KSBookmark+CoreDataProperties.swift
//  
//
//  Created by Muhammad Usman on 11/27/17.
//
//

import Foundation
import CoreData


extension KSBookmark {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<KSBookmark> {
        return NSFetchRequest<KSBookmark>(entityName: "KSBookmark")
    }

    @NSManaged public var address: String?
    @NSManaged public var bookmarkId: NSNumber?
    @NSManaged public var latitude: NSNumber?
    @NSManaged public var longitude: NSNumber?
    @NSManaged public var name: String?
    @NSManaged public var sortOrder: NSNumber?
    @NSManaged public var bookmarkToGeoLocation: KSGeoLocation?
    @NSManaged public var bookmarkToTrip: KSTrip?
    @NSManaged public var user: KSUser?

}
