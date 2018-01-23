//
//  KTVehicleType+CoreDataProperties.swift
//  
//
//  Created by Muhammad Usman on 1/23/18.
//
//

import Foundation
import CoreData


extension KTVehicleType {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<KTVehicleType> {
        return NSFetchRequest<KTVehicleType>(entityName: "KTVehicleType")
    }

    @NSManaged public var typeId: Int16
    @NSManaged public var typeName: String?
    @NSManaged public var typeBaseFare: Int32
    @NSManaged public var typeSortOrder: Int16
}
