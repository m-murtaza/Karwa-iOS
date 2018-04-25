//
//  NSOrderedSet+Utils.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 4/25/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import Foundation

extension NSOrderedSet {

    func adding(_ anObject: Any) -> NSOrderedSet {
        
        let mutableItems = self.mutableCopy() as! NSMutableOrderedSet
        mutableItems.add(anObject)
        return mutableItems.copy() as! NSOrderedSet
    }
}
