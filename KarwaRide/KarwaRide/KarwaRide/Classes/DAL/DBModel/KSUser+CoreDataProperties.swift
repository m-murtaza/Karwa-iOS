//
//  KSUser+CoreDataProperties.swift
//  
//
//  Created by Muhammad Usman on 11/27/17.
//
//

import Foundation
import CoreData


extension KSUser {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<KSUser> {
        return NSFetchRequest<KSUser>(entityName: "KSUser")
    }

    @NSManaged public var customerType: NSNumber?
    @NSManaged public var email: String?
    @NSManaged public var gender: NSNumber?
    @NSManaged public var language: String?
    @NSManaged public var name: String?
    @NSManaged public var phone: String?
    @NSManaged public var secondaryPhone: String?
    @NSManaged public var bookmarks: NSSet?
    @NSManaged public var trips: NSSet?

}

// MARK: Generated accessors for bookmarks
extension KSUser {

    @objc(addBookmarksObject:)
    @NSManaged public func addToBookmarks(_ value: KSBookmark)

    @objc(removeBookmarksObject:)
    @NSManaged public func removeFromBookmarks(_ value: KSBookmark)

    @objc(addBookmarks:)
    @NSManaged public func addToBookmarks(_ values: NSSet)

    @objc(removeBookmarks:)
    @NSManaged public func removeFromBookmarks(_ values: NSSet)

}

// MARK: Generated accessors for trips
extension KSUser {

    @objc(addTripsObject:)
    @NSManaged public func addToTrips(_ value: KSTrip)

    @objc(removeTripsObject:)
    @NSManaged public func removeFromTrips(_ value: KSTrip)

    @objc(addTrips:)
    @NSManaged public func addToTrips(_ values: NSSet)

    @objc(removeTrips:)
    @NSManaged public func removeFromTrips(_ values: NSSet)

}
