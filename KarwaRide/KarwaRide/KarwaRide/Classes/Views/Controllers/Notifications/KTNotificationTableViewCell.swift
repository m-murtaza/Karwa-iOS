//
//  KTNotificationTableViewCell.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 5/1/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

class KTNotificationTableViewCell: UITableViewCell {

    @IBOutlet weak var lblMessage : UILabel!
    @IBOutlet weak var lbldateTime : UILabel!
    @IBOutlet weak var lblAgoTime : UILabel!
    @IBOutlet weak var imgIcon : UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
