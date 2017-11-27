//
//  KSFranchise+CoreDataProperties.swift
//  
//
//  Created by Muhammad Usman on 11/27/17.
//
//

import Foundation
import CoreData


extension KSFranchise {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<KSFranchise> {
        return NSFetchRequest<KSFranchise>(entityName: "KSFranchise")
    }

    @NSManaged public var franchiseId: NSNumber?
    @NSManaged public var logoUrl: String?
    @NSManaged public var name: String?

}
