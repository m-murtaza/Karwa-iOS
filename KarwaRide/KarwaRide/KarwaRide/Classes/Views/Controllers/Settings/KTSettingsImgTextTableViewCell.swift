//
//  KTSettingsImgTextCellTableViewCell.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 2/27/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

class KTSettingsImgTextTableViewCell: UITableViewCell {

    @IBOutlet weak var lblText : UILabel!
    @IBOutlet weak var imgIcon : UIImageView!
    @IBOutlet weak var otpSwitch : UISwitch!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
