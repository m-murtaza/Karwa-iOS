//
//  KSTrip+CoreDataProperties.swift
//  
//
//  Created by Muhammad Usman on 11/27/17.
//
//

import Foundation
import CoreData


extension KSTrip {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<KSTrip> {
        return NSFetchRequest<KSTrip>(entityName: "KSTrip")
    }

    @NSManaged public var bookingType: String?
    @NSManaged public var callerId: String?
    @NSManaged public var dropoffLandmark: String?
    @NSManaged public var dropOffLat: NSNumber?
    @NSManaged public var dropOffLon: NSNumber?
    @NSManaged public var dropOffTime: NSDate?
    @NSManaged public var estimatedTimeOfArival: NSNumber?
    @NSManaged public var jobId: String?
    @NSManaged public var pickupHint: String?
    @NSManaged public var pickupLandmark: String?
    @NSManaged public var pickupLat: NSNumber?
    @NSManaged public var pickupLon: NSNumber?
    @NSManaged public var pickupTime: NSDate?
    @NSManaged public var status: NSNumber?
    @NSManaged public var vehicleType: NSNumber?
    @NSManaged public var driver: KSDriver?
    @NSManaged public var passenger: KSUser?
    @NSManaged public var rating: KSTripRating?
    @NSManaged public var taxi: KSTaxi?
    @NSManaged public var tripToBookmark: KSBookmark?

}
