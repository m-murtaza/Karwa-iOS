//
//  PaymentMethodSelectTableViewCell.swift
//  KarwaRide
//
//  Created by Satheesh Speed Mac on 22/04/21.
//  Copyright © 2021 Karwa. All rights reserved.
//

import UIKit

class PaymentMethodSelectTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel : UILabel!
    @IBOutlet weak var detailLable : UILabel!
    @IBOutlet weak var iconImageView : UIImageView!
    @IBOutlet weak var selectedIconImageView : UIImageView!
    @IBOutlet weak var selectedView : UIView!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
