//
//  KTFarePopupTableViewCell.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 4/10/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
import Spring

class KTFarePopupTableViewCell: UITableViewCell {

    @IBOutlet weak var key : SpringLabel!
    @IBOutlet weak var value : SpringLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
