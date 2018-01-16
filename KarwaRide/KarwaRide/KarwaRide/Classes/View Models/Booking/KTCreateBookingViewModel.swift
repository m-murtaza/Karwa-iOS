//
//  KTCreateBookingViewModel.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 1/16/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
protocol KTCreateBookingViewModelDelegate: KTViewModelDelegate {
    
}
class KTCreateBookingViewModel: KTBaseViewModel {
    
    weak var delegate: KTCreateBookingViewModelDelegate?
    
    init(del: Any) {
        super.init()
        delegate = del as? KTCreateBookingViewModelDelegate
    }
}
