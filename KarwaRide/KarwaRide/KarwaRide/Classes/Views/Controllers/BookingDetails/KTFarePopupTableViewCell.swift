//
//  KTFarePopupTableViewCell.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 4/10/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

class KTFarePopupTableViewCell: UITableViewCell {

    @IBOutlet weak var key : UILabel!
    @IBOutlet weak var value : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
