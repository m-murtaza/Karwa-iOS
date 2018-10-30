//
//  KTPaymentViewCell.swift
//  KarwaRide
//
//  Created by Sam Ash on 10/30/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

class KTPaymentViewCell: UITableViewCell {

    @IBOutlet weak var cardImage: UIImageView!
    @IBOutlet weak var cardNumber: UILabel!
    @IBOutlet weak var cardExpiry: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
