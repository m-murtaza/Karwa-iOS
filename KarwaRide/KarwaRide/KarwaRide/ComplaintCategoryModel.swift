//
//  ComplaintCategoryModel.swift
//  KarwaRide
//
//  Created by Sam Ash on 10/9/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import Foundation

class ComplaintCategoryModel: NSObject
{
    var id : Int32
    var image: String
    var title: String
    var desc : String
    
    override init()
    {
        id = -1
        image = ""
        title = ""
        desc = ""
        super.init()
    }
    
    init(_ id : Int32, _ image : String, _ title : String, _ desc : String)
    {
        self.id = id;
        self.image = image
        self.title = title
        self.desc = desc
    }

}
