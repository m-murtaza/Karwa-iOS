//
//  KSTripRating+CoreDataProperties.swift
//  
//
//  Created by Muhammad Usman on 11/27/17.
//
//

import Foundation
import CoreData


extension KSTripRating {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<KSTripRating> {
        return NSFetchRequest<KSTripRating>(entityName: "KSTripRating")
    }

    @NSManaged public var comments: String?
    @NSManaged public var issue: String?
    @NSManaged public var serviceRating: NSNumber?
    @NSManaged public var trip: KSTrip?

}
