//
//  KTXpressPickUpViewController.swift
//  KarwaRide
//
//  Created by Satheesh Speed Mac on 14/05/21.
//  Copyright © 2021 Karwa. All rights reserved.
//

import UIKit
import GoogleMaps
import Spring

class KTXpressPickUpViewController: KTBaseCreateBookingController {

    @IBOutlet weak var pickUpAddressLabel: SpringLabel!
    @IBOutlet weak var markerButton: SpringButton!

//
//    @IBOutlet weak var pickUpButton: SpringButton!
//
//    @IBOutlet weak var dropButton: SpringButton!
//
//    @IBOutlet weak var submitButton: SpringButton!
//
//    @IBOutlet weak var rideServiceTableView: UITableView!
//
//    @IBOutlet weak var plusButton: SpringButton!
//
//    @IBOutlet weak var minusButton: SpringButton!
//
//    @IBOutlet weak var passengerLabel: SpringLabel!
//
//    @IBOutlet weak var rideServiceView: SpringView!
//
//    @IBOutlet weak var pickDropUpView: SpringView!
//
//    @IBOutlet weak var backButton: SpringButton!
    
    var vModel : KTXpressPickUpViewModel?

    var pickUpSet: Bool?
    var dropSet: Bool?

    override func viewDidLoad() {
        viewModel = KTXpressPickUpViewModel(del:self)
        vModel = viewModel as? KTXpressPickUpViewModel
        
        if booking != nil {
            vModel?.booking = booking!
            //          (viewModel as! KTCreateBookingViewModel).setRemoveBookingOnReset(removeBookingOnReset: removeBookingOnReset)
        }
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        addMap()
        
        self.navigationItem.hidesBackButton = true;
        self.btnRevealBtn?.addTarget(self, action: #selector(showMenu), for: .touchUpInside)
        
        //TODO: This needs to be converted on Location Call Back
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1)
        {
            self.vModel?.setupCurrentLocaiton()
        }
        
        KTXpressBookingManager().getZoneWithSync { (status, response) in
            
        }
        
    }
    
    func setPickUp(pick: String?) {
        guard pick != nil else {
            return
        }
        
        self.pickUpAddressLabel.text = pick
        
    }
    
    @objc private func showMenu() {
      sideMenuController?.revealMenu()
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



