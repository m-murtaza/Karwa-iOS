//
//  KTTransactions+CoreDataProperties.swift
//  
//
//  Created by Satheesh Speed Mac on 11/04/21.
//
//

import Foundation
import CoreData


extension KTTransactions {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<KTTransactions> {
        return NSFetchRequest<KTTransactions>(entityName: "KTTransactions")
    }

    @NSManaged public var primaryMethod: String?
    @NSManaged public var transactionType: String?
    @NSManaged public var date: String?
    @NSManaged public var amount: String?

}
