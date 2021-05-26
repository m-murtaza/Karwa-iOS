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
    
    var areas = [Area]()
    var destinations = [Destination]()
    var dropOffArea = [Area]()
    var metroStopsArea = [Area]()
    
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
//        self.btnRevealBtn?.addTarget(self, action: #selector(showMenu), for: .touchUpInside)
        
        //TODO: This needs to be converted on Location Call Back
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1)
        {
            self.vModel?.setupCurrentLocaiton()
        }
        
        KTXpressBookingManager().getZoneWithSync { (string, response) in
                        
            if let totalOperatingResponse = response["Response"] as? [String: Any] {
                
                print(totalOperatingResponse)
                
                if let totalAreas = totalOperatingResponse["Areas"] as? [[String:Any]] {

                    for item in totalAreas {
                        
                        let area = Area(code: (item["Code"] as? Int)!, vehicleType:(item["VehicleType"] as? Int)!, name: (item["Name"] as? String)!, parent: (item["Parent"] as? Int)!, bound: (item["Bound"] as? String)!, type: (item["Type"] as? String)!, isActive: (item["IsActive"] as? Bool)!)
                        
                        self.areas.append(area)
                                                
                    }
                                        
                    self.polygon()
                    
                }
                
                if let totalDestinations = totalOperatingResponse["Destinations"] as? [[String:Any]] {

                    for item in totalDestinations {
                        
                        let destination = Destination(source: (item["Source"] as? Int)!, destination: (item["Destination"] as? Int)!, isActive: (item["IsActive"] as? Bool)!)
                        
                        self.destinations.append(destination)
                                                
                    }
                                        
                                
                }
                
                self.metroStopsArea = self.areas.filter{$0.type! == "MetroStop"}
                
                for item in self.metroStopsArea {
                    
                    if let dropOffLocation = self.destinations.filter({$0.destination! == item.parent!}).first {
                        if self.dropOffArea.contains(where: {$0.parent! == dropOffLocation.destination }) {
                            
                        } else {
                            self.dropOffArea.append(item)
                        }
                    }
                                        
                }
                
                print(self.dropOffArea)
                
                self.addDropOffLocations()
                
            }
            
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



