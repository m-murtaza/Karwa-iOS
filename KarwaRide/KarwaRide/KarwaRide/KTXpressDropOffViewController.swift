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
    
    @IBOutlet weak var setDropOffButton: UIButton!
    
    @IBOutlet weak var markerButton: SpringButton!
    
    var vModel : KTXpressDropoffViewModel?

    var dropSet: Bool?
    
    var operationArea = [Area]()
    var destinationsForPickUp = [Area]()
    var pickUpZone: Area?
    var pickUpStation: Area?
    var pickUpStop: Area?

    var dropOffLocation: Area?
    var picupRect = GMSMutablePath()
    
    var pickUpCoordinate: CLLocationCoordinate2D?
    var dropOffCoordinate: CLLocationCoordinate2D?
    
    var tapOnMarker = false

    override func viewDidLoad() {
        viewModel = KTXpressDropoffViewModel(del:self)
        
        vModel = viewModel as? KTXpressDropoffViewModel
        
        vModel?.operationArea = self.operationArea
        vModel?.destinationsForPickUp = self.destinationsForPickUp
        vModel?.pickUpZone = self.pickUpZone
        vModel?.pickUpStation = self.pickUpStation
        vModel?.pickUpStop = self.pickUpStop
        vModel?.pickUpCoordinate = self.pickUpCoordinate

        super.viewDidLoad()
        
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
    
    func setDropOff(pick: String?) {
        guard pick != nil else {
            return
        }
        
        self.dropOffAddressLabel.text = pick
        
    }
    
    @objc private func showMenu() {
      sideMenuController?.revealMenu()
    }
    
    func showStopAlertViewController(stops: [Area], selectedStation: Area) {
        
        let alert = UIAlertController(title: "\(selectedStation.name! + "Stops")", message: "Please Select Stop for Station", preferredStyle: .actionSheet)
        
        
        for item in stops {
            alert.addAction(UIAlertAction(title: item.name!, style: .default , handler:{ (UIAlertAction)in
                self.tapOnMarker = true
                (self.viewModel as! KTXpressDropoffViewModel).selectedStop = item
            }))
        }

        self.present(alert, animated: true, completion: {
            print("completion block")
        })
        
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
