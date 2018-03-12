//
//  KTMyTripsViewModel.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 3/12/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
protocol KTMyTripsViewModelDelegate {
    
}

class KTMyTripsViewModel: KTBaseViewModel {
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchBookings()
    }
    
    func fetchBookings()  {
        KTBookingManager().syncBookings { (status, response) in
            
        }
        
    }
}
