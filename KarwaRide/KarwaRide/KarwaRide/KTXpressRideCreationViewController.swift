//
//  KTXpressRideCreationViewController.swift
//  KarwaRide
//
//  Created by Satheesh Speed Mac on 30/05/21.
//  Copyright © 2021 Karwa. All rights reserved.
//

import UIKit
import Spring
import GoogleMaps

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


class KTXpressRideCreationViewController: KTBaseCreateBookingController, KTXpressRideCreationViewModelDelegate {
    
    @IBOutlet weak var rideServiceView: UIView!
    
    @IBOutlet weak var pickUpAddressButton: SpringButton!
    @IBOutlet weak var dropOffAddressButton: SpringButton!
    @IBOutlet weak var setBookingButton: UIButton!

    @IBOutlet weak var rideServiceTableView: UITableView!
    
    @IBOutlet weak var bookingProgress: UIProgressView!
    
    var operationArea = [Area]()
        
    var rideServicePickDropOffData: RideSerivceLocationData? = nil
    
    var vModel : KTXpressRideCreationViewModel?

    var headerData = [1,2,3,4]
    
    @IBOutlet weak var plusButton: UIButton!

    @IBOutlet weak var minusButton: UIButton!

    @IBOutlet weak var passengerLabel: UILabel!
    
    var countOfPassenger = 1
    var secondsRemaining:Float = 1.0
    
    var expiryTime = 0

    override func viewDidLoad() {
        
        super.viewDidLoad()

        viewModel = KTXpressRideCreationViewModel(del:self)
        vModel = viewModel as? KTXpressRideCreationViewModel
        vModel?.rideServicePickDropOffData = rideServicePickDropOffData
        
        self.vModel?.fetchRideService()
                
        // Do any additional setup after loading the view.
        addMap()
        
        self.navigationItem.hidesBackButton = true;
        
        rideServiceTableView.delegate = self
        rideServiceTableView.dataSource = self
        
        self.pickUpAddressButton.titleLabel?.numberOfLines = 2
        self.dropOffAddressButton.titleLabel?.numberOfLines = 2
        
        self.rideServiceView.isHidden = true

    }
    
    @IBAction func setCountForPassenger(sender: UIButton) {
        
        if sender.tag == 10 {
            countOfPassenger = countOfPassenger == 1 ? (countOfPassenger + 1) : countOfPassenger
        } else {
            countOfPassenger = countOfPassenger > 1 ? (countOfPassenger - 1) : 1
        }
        
        self.passengerLabel.text = "\(countOfPassenger) Passenger"
        
    }
    
    func setPickup(pick: String?) {
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
 
    func setProgressViewCounter(countDown: Int) {
        expiryTime = countDown
        Timer.scheduledTimer(timeInterval: TimeInterval(countDown), target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)

    }
    
    @objc func updateCounter(){
        if self.bookingProgress.progress > 0 {
            print("\(self.bookingProgress.progress) seconds.")
            
            let change: Float = Float(Float(1) / Float(expiryTime))
            let progress = self.bookingProgress.progress - (change)
            self.bookingProgress.setProgress(progress, animated: true)
            
        } else {
            self.bookingProgress.isHidden = true
        }
    }
    
    func showHideRideServiceView(show: Bool) {
        self.rideServiceView.isHidden = !show
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
    }
    
    func updateUI() {
        self.rideServiceTableView.reloadData()
    }

}

extension KTXpressRideCreationViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return (self.viewModel as! KTXpressRideCreationViewModel).rideInfo?.rides.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "KTXpressRideServiceCell") as! KTXpressRideServiceCell
        cell.dropDownButton.addTarget(self, action: #selector(showDetails(sender:)), for: .touchUpInside)
        cell.dropDownButton.tag = section
        cell.lblServiceType.text = (self.viewModel as! KTXpressRideCreationViewModel).getVehicleNo(index: section)
        cell.lblBaseFareOrEstimate.text = (self.viewModel as! KTXpressRideCreationViewModel).getEstimatedTime(index: section)
        return cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "KTFareServiceCell") as! KTFareServiceCell
        
        self.setUpfareBreakDownView(fareBreakDownView: cell.fareStackView, cell: cell)
        
        return cell
    }
    
    @objc func showDetails(sender: UIButton)  {
        
        self.headerData[sender.tag] = (self.headerData[sender.tag] == 0) ? 1 : 0
        self.rideServiceTableView.reloadSections([sender.tag], with: .fade)
        
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
    
    func updateLocationInMap(location: CLLocation) {
        
    }
    
    func updateLocationInMap(location: CLLocation, shouldZoomToDefault withZoom: Bool) {
        
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
