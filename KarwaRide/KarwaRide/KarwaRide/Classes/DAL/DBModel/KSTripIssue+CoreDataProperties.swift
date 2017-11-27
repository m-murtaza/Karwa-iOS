//
//  KSTripIssue+CoreDataProperties.swift
//  
//
//  Created by Muhammad Usman on 11/27/17.
//
//

import Foundation
import CoreData


extension KSTripIssue {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<KSTripIssue> {
        return NSFetchRequest<KSTripIssue>(entityName: "KSTripIssue")
    }

    @NSManaged public var issueId: NSNumber?
    @NSManaged public var issueKey: String?
    @NSManaged public var valueAR: String?
    @NSManaged public var valueEN: String?

}
