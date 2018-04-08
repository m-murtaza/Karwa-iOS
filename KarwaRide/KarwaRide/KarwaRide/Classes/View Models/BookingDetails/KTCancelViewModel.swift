//
//  KTCancelViewModel.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 4/5/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

protocol KTCancelViewModelDelegate {
    func getBookingStatii() -> Int32
}

class KTCancelViewModel: KTBaseViewModel {

    var del : KTCancelViewModelDelegate?
    var reasons : [KTCancelReason] = []
    
    override func viewDidLoad() {
        del = self.delegate as? KTCancelViewModelDelegate
        fetchCancelReasons()
    }
    
    private func fetchCancelReasons() {
        
        reasons = KTCancelBookingManager().cencelReasons(forBookingStatii: (del?.getBookingStatii())!)
        
        print(reasons)
    }
}
