//
//  KSTaxi+CoreDataProperties.swift
//  
//
//  Created by Muhammad Usman on 11/27/17.
//
//

import Foundation
import CoreData


extension KSTaxi {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<KSTaxi> {
        return NSFetchRequest<KSTaxi>(entityName: "KSTaxi")
    }

    @NSManaged public var make: String?
    @NSManaged public var model: String?
    @NSManaged public var number: String?
    @NSManaged public var year: NSNumber?
    @NSManaged public var trips: NSSet?

}

// MARK: Generated accessors for trips
extension KSTaxi {

    @objc(addTripsObject:)
    @NSManaged public func addToTrips(_ value: KSTrip)

    @objc(removeTripsObject:)
    @NSManaged public func removeFromTrips(_ value: KSTrip)

    @objc(addTrips:)
    @NSManaged public func addToTrips(_ values: NSSet)

    @objc(removeTrips:)
    @NSManaged public func removeFromTrips(_ values: NSSet)

}
