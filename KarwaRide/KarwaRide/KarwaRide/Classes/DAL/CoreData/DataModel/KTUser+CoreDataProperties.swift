//
//  KTUser+CoreDataProperties.swift
//  
//
//  Created by Muhammad Usman on 11/28/17.
//
//

import Foundation
import CoreData


extension KTUser {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<KTUser> {
        return NSFetchRequest<KTUser>(entityName: "KTUser")
    }

    @NSManaged public var name: String?
    @NSManaged public var phone: String?
    @NSManaged public var email: String?
    @NSManaged public var customerType: Int32

}
