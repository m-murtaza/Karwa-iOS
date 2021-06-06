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

class KTXpressPickUpViewController: KTBaseCreateBookingController, KTXpressPickUpViewModelDelegate {

    @IBOutlet weak var pickUpAddressLabel: SpringLabel!
    @IBOutlet weak var markerButton: SpringButton!
    @IBOutlet weak var setPickUpButton: UIButton!

    var vModel : KTXpressPickUpViewModel?

    var pickUpSet: Bool?
    var dropSet: Bool?
    
    var tapOnMarker = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        viewModel = KTXpressPickUpViewModel(del:self)
        vModel = viewModel as? KTXpressPickUpViewModel
        
        (viewModel as! KTXpressPickUpViewModel).fetchOperatingArea()
        
        // Do any additional setup after loading the view.
        addMap()
        
        self.navigationItem.hidesBackButton = true;
        self.btnRevealBtn?.addTarget(self, action: #selector(showMenu), for: .touchUpInside)
        
        //TODO: This needs to be converted on Location Call Back
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1)
        {
            self.vModel?.setupCurrentLocaiton()
        }
        
        self.setPickUpButton.addTarget(self, action: #selector(clickSetPickUp), for: .touchUpInside)
        
    }
    
    @objc func clickSetPickUp() {
        (self.viewModel as! KTXpressPickUpViewModel).didTapSetPickUpButton()
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
    
    func showDropOffViewController(destinationForPickUp: [Area], pickUpStation: Area?, pickUpStop: Area?, pickUpzone: Area?, coordinate: CLLocationCoordinate2D) {
        
        let dropOff = (self.storyboard?.instantiateViewController(withIdentifier: "KTXpressDropOffViewController") as? KTXpressDropOffViewController)!
        dropOff.destinationsForPickUp = destinationForPickUp
        dropOff.pickUpCoordinate = coordinate
        dropOff.pickUpStop = pickUpStop
        dropOff.pickUpStation = pickUpStation
        dropOff.pickUpZone = pickUpzone

        self.navigationController?.pushViewController(dropOff, animated: true)
        
    }
    
    func showStopAlertViewController(stops: [Area], selectedStation: Area) {
        
        let alert = UIAlertController(title: "\(selectedStation.name! + "Stops")", message: "Please Select Stop for Station", preferredStyle: .actionSheet)
        
        
        for item in stops {
            alert.addAction(UIAlertAction(title: item.name!, style: .default , handler:{ (UIAlertAction)in
                self.tapOnMarker = true
                print("User click Approve button")
                (self.viewModel as! KTXpressPickUpViewModel).selectedStop = item
            }))
        }

        self.present(alert, animated: true, completion: {
            print("completion block")
        })
        
    }


}



