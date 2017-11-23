//
//  KSSideDrawerModel.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 11/22/17.
//  Copyright © 2017 Karwa. All rights reserved.
//

import UIKit

class KSSideDrawerModel: KSBaseViewModel, KSViewModelDelegate {

    var drawerOptions = [String]()
    
    func ViewDidLoad() {
       drawerOptions = ["Option 1", "Option 2"]
    }
    
    func numberOfRowsInSection() -> Int
    {
        return drawerOptions.count as Int
    }
    
    func textInCell(idx : Int) -> String {
        return drawerOptions[idx]
    }
    
    func segueIdentifireForIdxPath(idx: Int) -> String
    {
        var segueIdentifire: String?
        switch idx
        {
        case 0:
            segueIdentifire = "segueDrawerToBookingNav"
        case 1:
            segueIdentifire = "segueDrawerToSecNav"
        default:
            segueIdentifire = "segueDrawerToBookingNav"
        }
        return segueIdentifire!
    }
}
