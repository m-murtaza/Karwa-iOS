//
//  KSDriver+CoreDataProperties.swift
//  
//
//  Created by Muhammad Usman on 11/27/17.
//
//

import Foundation
import CoreData


extension KSDriver {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<KSDriver> {
        return NSFetchRequest<KSDriver>(entityName: "KSDriver")
    }

    @NSManaged public var driverId: String?
    @NSManaged public var name: String?
    @NSManaged public var phone: String?
    @NSManaged public var trips: NSSet?

}

// MARK: Generated accessors for trips
extension KSDriver {

    @objc(addTripsObject:)
    @NSManaged public func addToTrips(_ value: KSTrip)

    @objc(removeTripsObject:)
    @NSManaged public func removeFromTrips(_ value: KSTrip)

    @objc(addTrips:)
    @NSManaged public func addToTrips(_ values: NSSet)

    @objc(removeTrips:)
    @NSManaged public func removeFromTrips(_ values: NSSet)

}
