//
//  KTXpressLocationPickerViewController.swift
//  KarwaRide
//
//  Created by Apple on 24/10/21.
//  Copyright © 2021 Karwa. All rights reserved.
//

import UIKit
import CoreLocation
import Spring

class KTXpressLocationPickerViewController:  KTBaseCreateBookingController {
   
    @IBOutlet weak var addressLabel: SpringLabel!
    @IBOutlet weak var markerButton: SpringButton!
    @IBOutlet weak var setLocationButton: SpringButton!
    
    @IBOutlet weak var plusBtn: UIButton!
    @IBOutlet weak var minuBtn: UIButton!
    @IBOutlet weak var passengerLabel: UILabel!
    @IBOutlet weak var showAddressPickerBtn: UIButton!
    
    @IBOutlet weak var arrowImage: UIImageView!

    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

