//
//  KTXpressRideCreationViewController.swift
//  KarwaRide
//
//  Created by Satheesh Speed Mac on 30/05/21.
//  Copyright © 2021 Karwa. All rights reserved.
//

import UIKit
import Spring

class KTXpressRideServiceCell: UITableViewCell {
    
    @IBOutlet weak var lblServiceType : UILabel!
    @IBOutlet weak var lblBaseFareOrEstimate : UILabel!
    @IBOutlet weak var imgBg : UIImageView!
    @IBOutlet weak var imgVehicleType : UIImageView!
    @IBOutlet weak var dropDownButton : UIButton!
    @IBOutlet weak var informationButton : UIButton!

    override class func awakeFromNib() {
        
    }
    
}

class KTFareServiceCell: UITableViewCell {
    
    @IBOutlet weak var fareTitleLabel : UILabel!
    @IBOutlet weak var fareStackView : UIStackView!

    override class func awakeFromNib() {
        
    }
    
}


class KTXpressRideCreationViewController: KTBaseCreateBookingController {
    
    @IBOutlet weak var pickUpAddressButton: SpringButton!
    @IBOutlet weak var dropOffAddressButton: SpringButton!
    @IBOutlet weak var markerButton: SpringButton!
    @IBOutlet weak var setBookingButton: UIButton!

    @IBOutlet weak var rideServiceTableView: UITableView!

    
    var vModel : KTXpressRideCreationViewModel?

    var pickUpSet: Bool?
    var dropSet: Bool?
        
    override func viewDidLoad() {
        
        super.viewDidLoad()

        viewModel = KTXpressRideCreationViewModel(del:self)
        vModel = viewModel as? KTXpressRideCreationViewModel
                
        // Do any additional setup after loading the view.
        addMap()
        
        self.navigationItem.hidesBackButton = true;
        
        //TODO: This needs to be converted on Location Call Back
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1)
        {
            self.vModel?.setupCurrentLocaiton()
        }
        
        rideServiceTableView.delegate = self
        rideServiceTableView.dataSource = self
        
    }
    
    
    
    func setPickUp(pick: String?) {
        guard pick != nil else {
            return
        }
        
        self.pickUpAddressButton.setTitle(pick, for: .normal)
        
    }
    
    func setDropOff(pick: String?) {
        guard pick != nil else {
            return
        }
        
        self.dropOffAddressButton.setTitle(pick, for: .normal)
        
    }
 
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
    }

}

extension KTXpressRideCreationViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "KTXpressRideServiceCell") as! KTXpressRideServiceCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "KTFareServiceCell") as! KTFareServiceCell
        
        self.setUpfareBreakDownView(fareBreakDownView: cell.fareStackView, cell: cell)
        
        return cell
    }
    
    //MARK:- FARE DETAILS BREAKDOWN VIEW
    fileprivate func setUpfareBreakDownView(fareBreakDownView: UIStackView, cell: KTFareServiceCell) {
                
        for i in 0 ..< (vModel?.fareDetailsHeader()?.count ?? 0) {
            setFarDetails(fareDetail: vModel?.fareDetailsHeader()?[i] ?? KTKeyValue(), fareBreakDownView: fareBreakDownView)
        }
        
        for i in 0 ..< 5 {
            setFarDetails(fareDetail: KTKeyValue(), fareBreakDownView: fareBreakDownView)
        }
                        
        fareBreakDownView.backgroundColor = UIColor.clear
        
//        let totalDetailsCount = (vModel?.fareDetailsBody()?.count ?? 0) + 2

    }
    
    fileprivate func setFarDetails(fareDetail: KTKeyValue, fareBreakDownView: UIStackView ) {
        
        guard fareBreakDownView.arrangedSubviews.count < 5 else {
            return
        }
        
        print("Device.language() -> ", Device.language())
        
        let keyLbl = UILabel()
        keyLbl.translatesAutoresizingMaskIntoConstraints = false
        keyLbl.heightAnchor.constraint(equalToConstant: 15).isActive = true
        keyLbl.text = "Basic pay"//fareDetail.key ?? ""
        keyLbl.textAlignment = .right
        keyLbl.textColor = UIColor(hexString: "#006170")
        keyLbl.font = UIFont(name: "MuseoSans-500", size: 14.0)!
        
        let valueLbl = UILabel()
        valueLbl.translatesAutoresizingMaskIntoConstraints = false
        valueLbl.heightAnchor.constraint(equalToConstant: 15).isActive = true
        valueLbl.text = "0.0 QAR"//fareDetail.value ?? ""
        
        if Device.language().contains("ar") {
            valueLbl.textAlignment = .left
            keyLbl.textAlignment = .right
        } else {
            keyLbl.textAlignment = .left
            valueLbl.textAlignment = .right
        }
        
        valueLbl.textColor = UIColor(hexString: "#006170")
        valueLbl.font = UIFont(name: "MuseoSans-500", size: 14.0)!

        let stackView = UIStackView(arrangedSubviews: [keyLbl, valueLbl])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        fareBreakDownView.addArrangedSubview(stackView)
    }
    
}

extension UIStackView {
    
    func removeFully(view: UIView) {
        removeArrangedSubview(view)
        view.removeFromSuperview()
    }
    
    func removeFullyAllArrangedSubviews() {
        arrangedSubviews.forEach { (view) in
            removeFully(view: view)
        }
    }
    
}
