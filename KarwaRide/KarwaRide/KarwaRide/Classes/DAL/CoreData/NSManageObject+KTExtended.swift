//
//  NSManageObject+KTExtended.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 1/24/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import MagicalRecord
extension NSManagedObject {
    class func obj(withValue value: Any, forAttrib attrib: String) -> NSManagedObject {
        var obj: NSManagedObject? = self.mr_findFirst(byAttribute: attrib, withValue: value)
        if obj == nil {
            obj = self.mr_createEntity()
            obj?.setValue(value, forKey: attrib)
        }
        return obj ?? NSManagedObject()
    }
    
    class func obj(withValue value: Any, forAttrib attrib: String,inContext context:NSManagedObjectContext) -> NSManagedObject {
        var obj: NSManagedObject? = self.mr_findFirst(byAttribute: attrib, withValue: value,in:context)
        
        if obj == nil {
            obj = self.mr_createEntity(in: context)
            obj?.setValue(value, forKey: attrib)
        }
        return obj ?? NSManagedObject()
    }
}
