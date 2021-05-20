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

class KTXpressDropOffViewController: KTBaseCreateBookingController {

    @IBOutlet weak var dropOffAddressLabel: SpringLabel!
    
    @IBOutlet weak var plusButton: SpringButton!

    @IBOutlet weak var minusButton: SpringButton!

    @IBOutlet weak var passengerLabel: SpringLabel!
    
    @IBOutlet weak var setDropOffButton: SpringButton!

    @IBOutlet weak var submitButton: SpringButton!
    
    var vModel : KTXpressDropoffViewModel?

    var dropSet: Bool?

    override func viewDidLoad() {
        viewModel = KTXpressDropoffViewModel(del:self)
        vModel = viewModel as? KTXpressDropoffViewModel
        
        if booking != nil {
            vModel?.booking = booking!
            //          (viewModel as! KTCreateBookingViewModel).setRemoveBookingOnReset(removeBookingOnReset: removeBookingOnReset)
        }
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        addMap()
        
        self.navigationItem.hidesBackButton = true;
        
        //TODO: This needs to be converted on Location Call Back
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1)
        {
            self.vModel?.setupCurrentLocaiton()
        }
        
    }
    
    func setDropOff(pick: String?) {
        guard pick != nil else {
            return
        }
        
        self.dropOffAddressLabel.text = pick
        
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



