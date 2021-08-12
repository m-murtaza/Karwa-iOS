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
    
    @IBOutlet weak var plusButton: UIButton!

    @IBOutlet weak var minusButton: UIButton!

    @IBOutlet weak var passengerLabel: UILabel!
    
    @IBOutlet weak var setDropOffButton: UIButton!
    
    @IBOutlet weak var markerButton: SpringButton!
    
    var vModel : KTXpressDropoffViewModel?

    var dropSet: Bool?
    
    var operationArea = [Area]()
    var destinationsForPickUp = [Area]()
    var pickUpZone: Area?
    var pickUpStation: Area?
    var pickUpStop: Area?
    var countOfPassenger = 1

    var dropOffLocation: Area?
    var picupRect = GMSMutablePath()
    
    var pickUpCoordinate: CLLocationCoordinate2D?
    var dropOffCoordinate: CLLocationCoordinate2D?
    
    var zonalArea = [[String : [Area]]]()

    
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
        vModel?.zonalArea = self.zonalArea

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

        self.setDropOffButton.addTarget(self, action: #selector(clickToSetUpBooking), for: .touchUpInside)

        
    }
    
    
    @IBAction func setCountForPassenger(sender: UIButton) {
        
        if sender.tag == 10 {
            countOfPassenger = countOfPassenger == 1 ? (countOfPassenger + 1) : countOfPassenger
        } else {
            countOfPassenger = countOfPassenger > 1 ? (countOfPassenger - 1) : 1
        }
        
        (viewModel as? KTXpressDropoffViewModel)?.countOfPassenger = countOfPassenger
        
        self.passengerLabel.text = "\(countOfPassenger) Passenger"
        
    }
    
    func setDropOff(pick: String?) {
        guard pick != nil else {
            return
        }
        
        self.dropOffAddressLabel.text = pick
        
    }
    
    @objc func clickToSetUpBooking() {
        (viewModel as! KTXpressDropoffViewModel).didTapSetDropOffButton()
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
    
    func showRideServiceViewController(rideLocationData: RideSerivceLocationData?) {
        let rideService = self.storyboard?.instantiateViewController(withIdentifier: "KTXpressRideCreationViewController") as? KTXpressRideCreationViewController
        rideService!.rideServicePickDropOffData = rideLocationData

        self.navigationController?.pushViewController(rideService!, animated: true)
        
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
