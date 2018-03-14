//
//  KTMyTripsCellTableViewCell.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 3/13/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

class KTMyTripsTableViewCell: UITableViewCell {

    @IBOutlet weak var lblPickAddress : UILabel!
    @IBOutlet weak var viewCard : KTShadowView!
    @IBOutlet weak var lblDayOfMonth: UILabel!
    @IBOutlet weak var lblMonth: UILabel!
    @IBOutlet weak var lblYear: UILabel!
    @IBOutlet weak var lblDropoffAddress: UILabel!
    @IBOutlet weak var lblDayAndTime: UILabel!
    @IBOutlet weak var lblServiceType: UILabel!
    @IBOutlet weak var imgBookingStatus: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
