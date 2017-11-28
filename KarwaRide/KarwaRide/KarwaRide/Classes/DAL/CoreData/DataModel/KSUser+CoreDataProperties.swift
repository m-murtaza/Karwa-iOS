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

    @NSManaged public var name: String?
    @NSManaged public var phone: String?
    @NSManaged public var email: String?
    @NSManaged public var customerType: Int32

}
