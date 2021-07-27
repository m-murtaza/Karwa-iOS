//
//  KTXpressRideTrackingViewController.swift
//  KarwaRide
//
//  Created by Apple on 25/07/21.
//  Copyright © 2021 Karwa. All rights reserved.
//

import UIKit
import Spring

class KTXpressRideTrackingViewController: KTBaseCreateBookingController {

    @IBOutlet weak var rideBookView: UIView!
    
    @IBOutlet weak var pickUpAddressButton: SpringButton!
    @IBOutlet weak var dropOffAddressButton: SpringButton!
    @IBOutlet weak var setBookingButton: UIButton!

    @IBOutlet weak var rideServiceTableView: UITableView!
    
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
