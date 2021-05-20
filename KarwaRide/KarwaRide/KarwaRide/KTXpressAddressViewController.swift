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

class KTXpressAddressViewController: KTBaseCreateBookingController {

    @IBOutlet weak var pickUpAddressHeaderLabel: SpringLabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backButton: SpringButton!

    var fromPickup: Bool?
    var fromDropOff: Bool?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickUpAddressHeaderLabel.duration = 1
        pickUpAddressHeaderLabel.delay = 0.15
        pickUpAddressHeaderLabel.animation = "slideUp"
        pickUpAddressHeaderLabel.animate()
        
//        pickUpAddressHeaderLabel.animation = "squeeze"
//        pickUpAddressHeaderLabel.animate()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = UIColor(hexString: "#F9F9F9")

                
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

extension KTXpressAddressViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 1
        }
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {
            return nil
        }
        let sectionHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 50))
        sectionHeaderView.backgroundColor = UIColor(hexString: "#F9F9F9")
        let headerLabel = UILabel(frame: CGRect(x: 20, y: 20, width: self.tableView.frame.width, height: 30))
        headerLabel.text = "FAVORITES"
        headerLabel.textColor = UIColor(hexString: "#8EA8A7")
        headerLabel.font = UIFont(name: "MuseoSans-500", size: 10.0)!
        sectionHeaderView.addSubview(headerLabel)
        
        return sectionHeaderView
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : KTXpressAddressTableViewCell = tableView.dequeueReusableCell(withIdentifier: "KTXpressAddressTableViewCell") as! KTXpressAddressTableViewCell
        cell.backgroundColor = UIColor(hexString: "#F9F9F9")
//        cell.titleLabel.text = //vModel?.paymentMethodName(forCellIdx: indexPath.row)
//        cell.addressLabel.text = //vModel?.expiry(forCellIdx: indexPath.row)
//        cell.icon.image  = //vModel?.cardIcon(forCellIdx: indexPath.row)
//        cell.selectionStyle = .none
        return cell
    }
    
    
}



class KTXpressAddressTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var moreButton: UIButton!

    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}

