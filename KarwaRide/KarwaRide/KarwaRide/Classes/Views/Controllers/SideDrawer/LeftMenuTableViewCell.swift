//
//  LeftMenuTableViewCell.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 2/25/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

class LeftMenuTableViewCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgTypeIcon: UIImageView!
    @IBOutlet weak var imgSelected: UIImageView!
    @IBOutlet weak var sideView: UIView!
    @IBOutlet weak var lblNew: UIImageView!
    @IBOutlet weak var lblWarning: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
