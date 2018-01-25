//
//  KTGeoLocation+CoreDataProperties.swift
//  
//
//  Created by Muhammad Usman on 1/25/18.
//
//

import Foundation
import CoreData


extension KTGeoLocation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<KTGeoLocation> {
        return NSFetchRequest<KTGeoLocation>(entityName: "KTGeoLocation")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var locationId: Int32
    @NSManaged public var area: String?
    @NSManaged public var name: String?
    @NSManaged public var type: Int32

}
