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
    @IBOutlet weak var setPickUpButton: UIButton!

    var vModel : KTXpressPickUpViewModel?

    var pickUpSet: Bool?
    var dropSet: Bool?
    
    

    override func viewDidLoad() {
        
        super.viewDidLoad()

        viewModel = KTXpressPickUpViewModel(del:self)
        vModel = viewModel as? KTXpressPickUpViewModel
        
        (viewModel as! KTXpressPickUpViewModel).fetchOperatingArea()
        
        // Do any additional setup after loading the view.
        addMap()
        
        self.navigationItem.hidesBackButton = true;
//        self.btnRevealBtn?.addTarget(self, action: #selector(showMenu), for: .touchUpInside)
        
        //TODO: This needs to be converted on Location Call Back
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1)
        {
            self.vModel?.setupCurrentLocaiton()
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
    
    */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
    }

}



