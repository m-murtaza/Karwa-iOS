//
//  KSGeoLocation+CoreDataProperties.swift
//  
//
//  Created by Muhammad Usman on 11/27/17.
//
//

import Foundation
import CoreData


extension KSGeoLocation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<KSGeoLocation> {
        return NSFetchRequest<KSGeoLocation>(entityName: "KSGeoLocation")
    }

    @NSManaged public var address: String?
    @NSManaged public var area: String?
    @NSManaged public var latitude: NSNumber?
    @NSManaged public var locationId: NSNumber?
    @NSManaged public var longitude: NSNumber?
    @NSManaged public var geoLocationToBookmark: KSBookmark?

}
